## API Endpoint Implementation Plan: GET /api/profiles/:id/public

### 1. Przegląd punktu końcowego

Publiczny, tylko-do-odczytu endpoint zwracający zwięzły, bezpieczny do publikacji widok profilu użytkownika wraz z podsumowaniem ocen. Źródłem danych jest widok `public.public_profiles` (lub alternatywnie join na `profiles` + `rating_stats`). Brak wymogu uwierzytelnienia.

### 2. Szczegóły żądania

- **Metoda HTTP**: GET
- **URL**: `/api/profiles/:id/public`
- **Parametry**:
  - **Wymagane**:
    - `id` (path) – UUID profilu
  - **Opcjonalne**: brak
- **Request body**: brak

Walidacja wejścia: Zod `z.object({ id: z.string().uuid() })` na parametrze ścieżki.

### 3. Wykorzystywane typy

- **DTO**:
  - `PublicProfileDTO` (z `src/types.ts`):
    - `id: string`
    - `username: string | null`
    - `location_text: string | null`
    - `avg_rating: number | null` (mapowane z `avg_stars` w widoku)
    - `ratings_count: number | null`

- **Błędy**: `ApiErrorDTO` (z `src/types.ts`), zwracany przez helper `jsonError`.

- (Jeśli potrzebne do audytu) `AuditEventDTO` (tylko zapis, brak zwrotu w tym endpoincie).

### 4. Szczegóły odpowiedzi

- **200 OK**: `PublicProfileDTO` zgodnie z kształtem powyżej. Pola `avg_rating` i `ratings_count` mogą być `null`, jeżeli brak ocen; opcjonalnie można rozważyć koalescencję w warstwie API (np. `0`), ale rekomendujemy pozostać zgodnym z typami w `src/types.ts`.
- **400 Bad Request**: nieprawidłowy `id` (nie-UUID).
- **404 Not Found**: profil nie istnieje w `public_profiles`.
- **500 Internal Server Error**: niespodziewany błąd serwera lub błąd bazy.

Struktura błędu: `jsonError(status, code, message, details?)`.

### 5. Przepływ danych

1. Router (Astro server endpoint) odbiera żądanie GET z `:id`.
2. Walidacja `:id` (Zod uuid).
3. Pobranie klienta Supabase z `locals.supabase` (zgodnie z regułami backendowymi).
4. Warstwa serwisowa (`profile.service`) odpyta widok `public_profiles` po `id`:
   - `supabase.from("public_profiles").select("id, username, location_text, avg_stars, ratings_count").eq("id", id).single()`
   - Mapowanie `avg_stars` -> `avg_rating`.
   - Obsługa błędu not-found po kodzie PGRST116.
5. Zwrócenie `jsonOk(PublicProfileDTO)` lub odpowiedniego błędu przez `jsonError`.
6. (Opcjonalnie) Zapis do `audit_log` zdarzenia: `public_profile_read` / `public_profile_not_found` z `actor_id = null` (publiczny dostęp).

### 6. Względy bezpieczeństwa

- Brak wymogu autoryzacji – endpoint jest publiczny, ale odczytuje wyłącznie bezpieczny widok `public_profiles` ograniczający pola.
- RLS: upewnić się, że widok `public_profiles` jest czytelny publicznie lub przez anon-key zgodnie z polityką. Alternatywnie użyć service-role wyłącznie po stronie serwera (niezalecane dla publicznego endpointu), lepiej utrzymać odpowiednie RLS/GRANT.
- Walidacja UUID zapobiega zapytaniom złośliwym/niepoprawnym.
- Nie zwracać dodatkowych pól ani PII ponad `PublicProfileDTO`.
- Nagłówki odpowiedzi: korzystamy z `JSON_HEADERS` (w tym `cache-control: no-store`) z `src/lib/api/responses.ts`. Jeśli potrzebne publiczne cache, rozważyć per-endpoint override (np. krótki `public, max-age=60, stale-while-revalidate=300`). Na start pozostajemy przy `no-store` dla spójności.

### 7. Obsługa błędów

- **Walidacja**: nie-UUID → 400 `invalid_id`.
- **Nie znaleziono**: Supabase `single()` z kodem `PGRST116` → 404 `public_profile_not_found`.
- **Błędy bazy/połączeń**: 500 `internal_error` + `details: { code?: string }` jeśli dostępny kod błędu.
- **Rejestrowanie**: użyć `logAuditEvent` (best-effort, błędy logowania pomijane):
  - `public_profile_read` (200), `public_profile_not_found` (404), `security` (400 niepoprawny UUID, kategoria input/security), `internal_error` (500).

### 8. Rozważania dotyczące wydajności

- Zapytanie single-row po PK `id` jest O(1); z widoku `public_profiles` minimalne koszty.
- Ewentualny cache HTTP (po weryfikacji polityk danych) może ograniczyć obciążenie – można wprowadzić po pierwszym wdrożeniu.
- Utrzymywać selekcję tylko wymaganych kolumn, co już robimy.
- Brak pętli N+1 (pojedyncze zapytanie).

### 9. Kroki implementacji

1) Warstwa serwisowa (`src/lib/services/profile.service.ts`)
- Dodać funkcję `fetchPublicProfileById(supabase, userId): Promise<PublicProfileDTO | null>`:
  - Select: `id, username, location_text, avg_stars, ratings_count` z `public_profiles`.
  - Mapowanie do `PublicProfileDTO` (`avg_stars` → `avg_rating`).
  - Obsłużyć `NOT_FOUND_ERROR_CODE = "PGRST116"` (zwrócić `null`).
  - Inne błędy → rzucić `SupabaseQueryError` (istniejąca klasa).

2) Endpoint HTTP (nowy plik: `src/pages/api/profiles/[id]/public.ts`)
- `export const prerender = false;`
- `export async function GET({ locals, params }: APIContext)`:
  - Walidacja `params` Zod: uuid dla `id`; w razie błędu → 400 `invalid_id`.
  - `const supabase = locals.supabase;` guard + 500, jeśli brak.
  - Wywołanie `fetchPublicProfileById(supabase, id)`.
  - `null` → `logAuditEvent(..., "public_profile_not_found", null, { endpoint, profile_id: id })` + 404.
  - Sukces → `logAuditEvent(..., "public_profile_read", null, { endpoint, profile_id: id })` + `jsonOk(dto)`.
  - W `catch`→ mapowanie błędów do 500 `internal_error` z `details` (jak w `src/pages/api/profile.ts`).

3) Walidacja/typy
- Wykorzystać już istniejące `PublicProfileDTO` z `src/types.ts`.
- Drobne sprawdzenie payloadu (opcjonalnie) w stylu `validateProfilePayload` – dla publicznego widoku wystarczy weryfikacja kluczowych pól (`id`, `username`).

4) Testy ręczne (Quick checks)
- `GET /api/profiles/<valid-uuid>/public` istniejący → 200 body
- `GET /api/profiles/<valid-uuid>/public` nieistniejący → 404
- `GET /api/profiles/<invalid>/public` → 400

5) (Opcjonalnie później) Cache
- Jeżeli ruch publiczny jest wysoki i dane mogą być krótko cache’owane: rozważyć nadpisanie nagłówków dla tego endpointu na np. `public, max-age=60, stale-while-revalidate=300`.

### 10. Szczegóły implementacyjne (wzorce i zgodność z regułami)

- Zgodnie z regułami backendowymi i Astro:
  - Używamy `locals.supabase`, nie importujemy `supabaseClient` bezpośrednio w endpointach.
  - Handlery w UPPERCASE (`GET`).
  - `export const prerender = false` w pliku endpointu.
  - Walidacja wejścia Zod.
  - Logika domenowa w serwisie (`src/lib/services/profile.service.ts`).
  - Odpowiedzi przez `jsonOk`/`jsonError` (`src/lib/api/responses.ts`).

### 11. Mapowanie kodów statusu

- 200 – udany odczyt
- 400 – nieprawidłowy parametr `id` (UUID)
- 401 – nie dotyczy (publiczny endpoint)
- 404 – brak profilu w `public_profiles`
- 500 – błąd serwera/bazy




