## API Endpoint Implementation Plan: PUT /api/profile

### 1. Przegląd punktu końcowego

Punkt końcowy umożliwia utworzenie lub aktualizację profilu zalogowanego użytkownika. Jeżeli pole `location_text` uległo zmianie względem poprzedniej wartości, wykonuje się geokodowanie po stronie backendu i zapis współrzędnych w `location_geog`. Zwraca aktualny stan profilu.

### 2. Szczegóły żądania

- **Metoda HTTP**: PUT
- **Struktura URL**: `/api/profile`
- **Parametry**:
  - **Wymagane**: `username` (string, non-empty), `rodo_consent` (boolean)
  - **Opcjonalne**: `location_text` (string; pusta wartość traktowana jako brak lokalizacji)
- **Nagłówki**:
  - `Content-Type: application/json`
- **Request Body (JSON)**:

```json
{
  "username": "string",
  "location_text": "string",
  "rodo_consent": true
}
```

- **Walidacja** (Zod):
  - `username`: string, trim, min 1, np. `z.string().trim().min(1)`
  - `location_text`: `z.string().trim().optional()`; jeżeli `""` → normalizuj do `null`
  - `rodo_consent`: `z.boolean()` (na create wymagane `true` dla zgodności z wymogami prywatności)

### 3. Wykorzystywane typy

- `ProfileDTO` (z `src/types.ts`): reprezentacja wiersza `profiles` w odpowiedzi
- `ProfileUpsertCommand` (z `src/types.ts`): `{ username, location_text, rodo_consent }`
- (opcjonalnie w serwisie) `ProfileGeocodeResultDTO`: `{ location_geog: GeoJSONPoint }`

### 4. Szczegóły odpowiedzi

- **200 OK**: Profil zaktualizowany; body: `ProfileDTO`
- **201 Created**: Profil utworzony; body: `ProfileDTO`
- **400 Bad Request**: Błędny input (Zod), niespójne dane
- **401 Unauthorized**: Brak sesji
- **409 Conflict**: `username` zajęty przez innego użytkownika
- **500 Internal Server Error**: Błąd serwera/Supabase/Edge Function

- **Nagłówki odpowiedzi**: z `jsonOk/jsonError` → `content-type: application/json; charset=utf-8`, `cache-control: no-store`

### 5. Przepływ danych

1. Autoryzacja: pobierz `locals.supabase` i `userId` przez `getAuthenticatedUserId`.
2. Odczyt profilu bieżącego użytkownika: `fetchProfileById(supabase, userId)`.
3. Walidacja payloadu Zod + normalizacja (`location_text` pusty → `null`).
4. Unikalność `username` (CITEXT): sprawdź `profiles` po `username` z warunkiem `id != userId`.
5. Upsert:
   - Brak istniejącego profilu → INSERT (id = userId, `username`, `rodo_consent`, opcjonalnie `location_text`).
   - Istniejący profil → UPDATE pól zmienionych.
6. Geokodowanie (tylko gdy `location_text` zmieniło się semantycznie):
   - Wywołaj Edge Function/serwis geokodowania z `location_text` (timeout i retry z backoff).
   - Po sukcesie zapisz `location_geog` (Point 4326) i zachowaj `location_text`.
   - Po błędzie: nie blokuj całej operacji; zwróć profil bez `location_geog` i zaloguj błąd.
7. Audit log:
   - `profile_create` lub `profile_update` (detale: zmienione pola, `geocode_triggered`).
   - Przy błędach bezpieczeństwa: `security` z powodem.
8. Odpowiedź: odczytaj aktualny profil i zwróć 201/200.

### 6. Względy bezpieczeństwa

- Uwierzytelnienie: wyłącznie zalogowany użytkownik (401 gdy brak).
- Autoryzacja i RLS: zapisy tylko na wierszu profilu bieżącego użytkownika (RLS po stronie DB).
- Walidacja wejścia Zod + normalizacja whitespace; brak wstrzyknięć SQL (Supabase client parametryzuje zapytania).
- Unikalność `username`: przed zapisem jawny check oraz spodziewany konflikt transakcyjny → mapowanie do 409.
- Edge geocoding:
  - Tylko po stronie serwera (Edge Function), z sekretem i limitem czasu.
  - Rate-limit per użytkownik; cache (np. hash `location_text`).
  - Nigdy nie zapisuj surowych odpowiedzi zewnętrznych do logów bez sanizacji.
- Audyt: rejestruj istotne akcje i próby nieudane (np. `security`, `profile_update_failed`).

### 7. Obsługa błędów

- 400: Błąd Zod (`validation_error`) z listą pól w `details` (zachowaj minimalizm – nazwy pól i komunikaty).
- 401: `auth_required` przy braku sesji.
- 409: `username_taken` gdy `profiles.username` koliduje z innym `id`.
- 500: `internal_error` dla nieoczekiwanych wyjątków oraz błędów Supabase/Edge; `details` ograniczone (np. kody Supabase).
- Rejestrowanie w `audit_log` przy 401/409/500 (best-effort; porażki zapisu audytu są ignorowane, zgodnie ze wzorcem w istniejącym kodzie).

### 8. Rozważania dotyczące wydajności

- Zmniejsz liczbę round-tripów: łącz check unikalności i update w zwięzłą sekwencję; tylko jedno końcowe SELECT.
- Geokodowanie:
  - Debounce na poziomie serwisu (nie wywołuj ponownie dla identycznego `location_text`).
  - Timeout (np. 2–3 s) i at-most-once per request; nie blokuj odpowiedzi na timeout.
  - Cache rezultatu (np. w KV/Storage) kluczowany znormalizowanym `location_text`.
- Indeksy DB: GIST na `location_geog` (już w planie DB), indeks na `username` (CITEXT UNIQUE – już w planie DB).

### 9. Kroki implementacji

1. Route: `src/pages/api/profile.ts`
   - Dodaj `export async function PUT({ locals, request }: APIContext)` i `export const prerender = false` (już istnieje).
   - Zdefiniuj schemat Zod (`ProfileUpsertCommandSchema`).
   - Wczytaj JSON, zwróć 400 przy błędach walidacji.
   - Użyj `getAuthenticatedUserId(locals.supabase)` → 401 jeśli brak.
   - Wywołaj serwis upsertu (pkt 2) i zmapuj wynik do 201/200.
   - Audit log dla powodzenia/porażek (wzorzec jak w GET).

2. Serwis profilu: `src/lib/services/profile.service.ts`
   - Dodaj funkcję `upsertOwnProfile(supabase, userId, cmd: ProfileUpsertCommand)`:
     - Pobierz `current = fetchProfileById(...)`.
     - Sprawdź unikalność `username` (`select id where username = cmd.username and id != userId`).
     - INSERT/UPDATE odpowiednio; normalizuj `location_text` do `null` gdy puste.
     - Jeżeli `location_text` zmienione: wywołaj `geocodeLocation(cmd.location_text)` i zapisz `location_geog`.
     - Zwróć aktualny `ProfileDTO`.
   - Dodaj pomocnicze: `hasLocationChanged(prev, next)`, `normalizeLocationText(text)`.

3. Serwis geokodowania: `src/lib/services/geocoding.service.ts` (nowy)
   - `geocodeLocation(text: string): Promise<ProfileGeocodeResultDTO>` – wywołanie Edge Function (URL + key z env), timeout, proste cache.
   - Mapuj odpowiedź do GeoJSON Point ([lon, lat]) i waliduj.
   - W razie błędu rzucaj własny `GeocodingError` lub zwracaj `null` i odnotuj w audycie.

4. Reużycie odpowiedzi: `src/lib/api/responses.ts`
   - Wykorzystaj istniejące `jsonOk/jsonError` i `JSON_HEADERS`.

5. Środowisko i konfiguracja
   - `src/env.d.ts`: dopisz typy dla Edge Function (np. `GEOCODING_URL`, `GEOCODING_KEY`).
   - W `.env`/sekretach CI: wartości powyższych.

6. Mapowanie kodów statusu
   - Create (brak rekordu) → 201
   - Update (rekord istniał) → 200
   - Konflikt nazwy → 409 (`username_taken`)
   - Błędne dane → 400 (`validation_error`)
   - Brak sesji → 401 (`auth_required`)
   - Inne → 500 (`internal_error`)

7. Testy ręczne (quick checks)
   - PUT bez sesji → 401
   - PUT z sesją, nowy profil → 201, audit `profile_create`
   - PUT z sesją, zmiana `username` na zajęty → 409
   - PUT z sesją, zmiana `location_text` → wywołanie geokodowania, 200, audit `profile_update` + `geocode_triggered`
   - PUT z sesją, błąd geokodowania → 200/201 bez `location_geog`, audit z błędem geokodowania

### 10. Pseudokod głównego przepływu (wysoki poziom)

```ts
// Route PUT /api/profile
const userId = await getAuthenticatedUserId(supabase) // 401 if null
const cmd = ProfileUpsertCommandSchema.parse(await request.json()) // 400 on fail
const { profile, created } = await upsertOwnProfile(supabase, userId, cmd)
await logAuditEvent(supabase, created ? "profile_create" : "profile_update", userId, { geocode_triggered: ... })
return created ? jsonOk201(profile) : jsonOk(profile)
```

Uwagi: `jsonOk201` można zaimplementować lokalnie (odpowiednik `jsonOk` z `status: 201`).




