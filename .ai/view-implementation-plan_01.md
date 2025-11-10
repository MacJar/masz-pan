## API Endpoint Implementation Plan: GET /api/profile

### 1. Przegląd punktu końcowego

Punkt końcowy zwraca profil aktualnie uwierzytelnionego użytkownika. Wspiera tylko odczyt, bez parametrów wejściowych. Autoryzacja przez Supabase Auth (cookies na serwerze). Zwraca pełny rekord profilu (`ProfileDTO`).

### 2. Szczegóły żądania

- **Metoda HTTP**: GET
- **URL**: `/api/profile`
- **Parametry**:
  - **Wymagane**: brak
  - **Opcjonalne**: brak
- **Nagłówki**:
  - Cookies Supabase Auth (zalecane w SSR)
  - Opcjonalnie `Authorization: Bearer <access_token>` do testów narzędziowych
- **Request Body**: brak
- **Routing/Astro**:
  - Plik: `src/pages/api/profile.ts`
  - `export const prerender = false`
  - Handler: `export async function GET({ locals, cookies }) { ... }`

### 3. Wykorzystywane typy

- **DTOs** (z `src/types.ts`):
  - `ProfileDTO` – pełny rekord z tabeli `profiles`
  - `ApiErrorDTO` – standardowa forma błędu `{ error: { code, message, details? } }`
- **Typy DB** (z `src/db/database.types.ts`):
  - `Database` – generowane typy Supabase
- **Klient Supabase**:
  - Używamy klienta z `locals.supabase` (patrz middleware). Docelowo per-request server client.

### 4. Szczegóły odpowiedzi

- **200 OK**: `ProfileDTO`
  - Przykład:

```json
{
  "id": "d2e6c8f4-5a1a-4f8b-bc6f-8d2a1c7e0a10",
  "username": "jan_kowalski",
  "location_text": "Warszawa, Polska",
  "location_geog": null,
  "rodo_consent": true,
  "created_at": "2025-11-07T10:00:00.000Z",
  "updated_at": "2025-11-07T10:00:00.000Z"
}
```

- **401 Unauthorized**: `ApiErrorDTO` – użytkownik nie jest zalogowany
- **404 Not Found**: `ApiErrorDTO` – brak profilu dla uwierzytelnionego użytkownika
- **500 Internal Server Error**: `ApiErrorDTO` – błąd po stronie serwera/DB

Nagłówki odpowiedzi:
- `content-type: application/json; charset=utf-8`
- `cache-control: no-store` (dane wrażliwe)

### 5. Przepływ danych

1. Żądanie trafia do Astro middleware `src/middleware/index.ts` – do `locals` wstrzykiwany jest klient Supabase.
2. Handler `GET` pobiera klienta z `locals.supabase` oraz sesję użytkownika:
   - SSR: preferowane użycie `@supabase/ssr` i cookies (patrz Kroki implementacji).
3. Jeśli brak uwierzytelnienia → zwróć 401.
4. Zapytanie `select` do tabeli `profiles` z filtrem po `id = user.id`.
5. Jeśli rekord nie istnieje → zwróć 404.
6. Zwróć `ProfileDTO` (200) i nagłówki anty-cache.
7. Opcjonalnie: wpis do `audit_log` (np. `event_type: 'profile_read'` lub `'security'` przy 401).

### 6. Względy bezpieczeństwa

- **Uwierzytelnienie**: Supabase Auth; SSR z cookies (server-side) – brak ekspozycji tokenów do przeglądarki w tym endpointzie.
- **Autoryzacja/RLS**: Zapytanie ograniczone do `profiles.id = user.id`. RLS powinny dodatkowo egzekwować dostęp tylko do własnego rekordu.
- **Brak danych nadmiarowych**: Zwracamy wyłącznie `ProfileDTO` (dane własne użytkownika).
- **Nagłówki**: `cache-control: no-store` dla PII.
- **Ochrona przed wyciekiem**: Jednoznaczne kody błędów (401/404) bez ujawniania szczegółów implementacyjnych w `message`.
- **Logowanie bezpieczeństwa**: opcjonalny wpis do `audit_log` dla 401 (próba dostępu bez autoryzacji).

### 7. Obsługa błędów

- **401 Unauthorized**: brak sesji użytkownika w Supabase; zwrócić `ApiErrorDTO` z `code: 'auth_required'`.
- **404 Not Found**: brak wiersza w `profiles` dla `user.id`; `code: 'profile_not_found'`.
- **500 Internal Server Error**: błędy połączenia z DB lub inne wyjątki; `code: 'internal_error'`, `details` z bezpiecznym wycinkiem błędu (bez wrażliwych danych).
- **RLS violations**: traktować jako 403/500 w zależności od zachowania supabase-js; w tym endpointzie nie powinny wystąpić przy właściwym filtrze. Mapować na 500 z generycznym komunikatem, bez zdradzania polityk.

Standardowa forma błędów (`ApiErrorDTO`):

```json
{ "error": { "code": "auth_required", "message": "Authentication required." } }
```

### 8. Rozważania dotyczące wydajności

- Pojedyncze, proste zapytanie po PK (`profiles.id`) – znikomy koszt.
- Brak potrzeby cache (dane usera, dynamiczne) – ustaw `no-store`.
- Minimalizuj alokacje: krótka ścieżka błędów, wczesne zwroty.

### 9. Etapy wdrożenia

1) Middleware – per-request Supabase Server Client (SSR)
- Zmień `src/middleware/index.ts` na użycie `@supabase/ssr`:
  - Twórz klienta przez `createServerClient<Database>(SUPABASE_URL, SUPABASE_ANON_KEY, { cookies: { get, set, remove } })` korzystając z `context.cookies`.
  - Wstaw do `context.locals.supabase` per-request.
  - Typ `locals.supabase` bazuj na typie eksportowanym z `src/db/supabase.client.ts` (np. `type SupabaseClient = typeof supabaseClient`).

2) Service: `src/lib/services/profile.service.ts`
- Utwórz funkcje:
  - `getAuthenticatedUserId(supabase): Promise<string | null>` – przez `supabase.auth.getUser()`.
  - `fetchProfileById(supabase, userId: string): Promise<ProfileDTO | null>` – `from('profiles').select('*').eq('id', userId).single()` z obsługą `not found`.
  - (Opcjonalnie) `logAuditEvent(supabase, eventType: string, details?: Record<string, unknown>): Promise<void>` – INSERT do `audit_log`.

3) API Route: `src/pages/api/profile.ts`
- `export const prerender = false`.
- `export async function GET({ locals, cookies })`:
  - Pobierz `supabase` z `locals`.
  - `userId = await getAuthenticatedUserId(supabase)` → gdy `null` zwróć 401 (`auth_required`).
  - `profile = await fetchProfileById(supabase, userId)` → gdy `null` zwróć 404 (`profile_not_found`).
  - Zwróć 200 z `profile` i nagłówkami `content-type` oraz `cache-control: no-store`.
  - (Opcjonalnie) loguj zdarzenia do `audit_log`.

4) Walidacja/Zod
- Wejście: brak (GET, bez parametrów) – walidacja nie wymagana.
- Wyjście: nie jest wymagane, ale można dodać lekki guard (np. podstawowa walidacja kluczowych pól) jeśli potrzebne.

5) Typy i ergonomia
- Upewnij się, że importujesz `Database` z `src/db/database.types.ts` i stosujesz typowanie generyczne w kliencie Supabase.
- Korzystaj z `ProfileDTO` i `ApiErrorDTO` z `src/types.ts` w sygnaturach usług i handlera.

6) Testy ręczne (quick checks)
- Niezalogowany: `curl -i http://localhost:4321/api/profile` → 401.
- Zalogowany bez profilu: 404.
- Zalogowany z profilem: 200 + JSON profilu.

7) Jakość i DX
- Lint/Typecheck: napraw ewentualne błędy TS/ESLint.
- Krótki kod, wczesne zwroty, jasne komunikaty błędów.

### 10. Pseudokod (orientacyjny)

```ts
// src/pages/api/profile.ts
export const prerender = false;

export async function GET({ locals }: APIContext) {
  const supabase = locals.supabase; // server client per-request

  const { data: authData, error: authError } = await supabase.auth.getUser();
  if (authError || !authData?.user?.id) {
    return jsonError(401, 'auth_required', 'Authentication required.');
  }

  const userId = authData.user.id;
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();

  if (error?.code === 'PGRST116' /* not found */) {
    return jsonError(404, 'profile_not_found', 'Profile not found.');
  }
  if (error) {
    return jsonError(500, 'internal_error', 'Unexpected server error.', { db: error.code });
  }

  return jsonOk(profile);
}

function jsonOk(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store'
    }
  });
}

function jsonError(status: number, code: string, message: string, details?: unknown): Response {
  return new Response(JSON.stringify({ error: { code, message, details } }), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' }
  });
}
```

Uwaga: Finalna implementacja powinna korzystać z serwerowego klienta Supabase utworzonego per-request w middleware z użyciem cookies (`@supabase/ssr`).


