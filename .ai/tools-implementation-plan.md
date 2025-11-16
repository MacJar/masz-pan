## API Endpoint Implementation Plan: GET /api/tools/search

### 1. Przegląd punktu końcowego
Wyszukiwanie aktywnych narzędzi po tekście w promieniu 10 km od lokalizacji profilu zalogowanego użytkownika. Wynik posortowany rosnąco po odległości i stronicowany kursorem.

### 2. Szczegóły żądania
- Metoda HTTP: GET
- Struktura URL: `/api/tools/search`
- Parametry zapytania:
  - Wymagane:
    - `q` (string): fraza wyszukiwania (pełnotekstowo po nazwie).
  - Opcjonalne:
    - `cursor` (string): nieprzezroczysty kursor (base64 JSON), do stronicowania.
    - `limit` (number): 1..100, domyślnie 20.
- Nagłówki:
  - `Authorization: Bearer <token>` (wymagane – endpoint wymaga zalogowanego użytkownika).
- Treść żądania: brak.
- Zasady i kody statusu:
  - 200 – sukces, zwraca stronę wyników.
  - 401 – brak autentykacji (profil wymagany).
  - 400 – brak/nieprawidłowe dane wejściowe (np. brak `location_geog` u profilu, nieprawidłowy `cursor`, zbyt duże/małe `limit`).
  - 500 – błąd serwera.

### 3. Wykorzystywane typy
- `ToolSearchItemDTO` (z `src/types.ts`):
  - Pola: `id: string`, `name: string`, `distance_m: number`
- `ToolSearchPageDTO` (z `src/types.ts`):
  - Pola: `items: ToolSearchItemDTO[]`, `next_cursor: string | null`
- `ApiErrorDTO` (z `src/types.ts`):
  - Pola: `{ error: { code: string; message: string; details?: unknown } }`

### 4. Szczegóły odpowiedzi
- Sukces 200:
```json
{
  "items": [
    { "id": "uuid", "name": "Wiertarka", "distance_m": 1234 }
  ],
  "next_cursor": "opaque-or-null"
}
```
- Błędy:
```json
{ "error": { "code": "UNAUTHORIZED", "message": "Authentication required" } }
```
```json
{ "error": { "code": "MISSING_LOCATION", "message": "Profile location required" } }
```
```json
{ "error": { "code": "BAD_REQUEST", "message": "Invalid cursor" } }
```
```json
{ "error": { "code": "INTERNAL", "message": "Unexpected error" } }
```

### 5. Przepływ danych
1. Autentykacja:
   - W Astro API route pobierz `supabase` z `locals` (`context.locals.supabase`).
   - Odczytaj `user` (`supabase.auth.getUser()` lub identyfikator z `locals`) – brak użytkownika → 401.
2. Odczyt profilu:
   - Pobierz rekord z tabeli `profiles` po `id = auth.user.id`.
   - Wymagane: `location_geog` – gdy `NULL` → 400 `MISSING_LOCATION`.
3. Walidacja parametrów:
   - `q`: niepusty string (po `trim()`), maks. długość np. 128.
   - `limit`: domyślnie 20, zakres 1..100.
   - `cursor`: base64(JSON) → `{ lastDistance: number, lastId: string }`; niepoprawny → 400.
4. Wyszukiwanie:
   - Baza danych: `tools` (status = 'active', GIN na `search_name_tsv`), `profiles` (lokalizacja użytkownika).
   - Odległość: `ST_DWithin(tool_location, profile_location, 10000)` oraz `ST_Distance` (geography) do sortowania.
   - Filtrowanie pełnotekstowe: `plainto_tsquery('simple', q)` na `search_name_tsv`.
   - Cursor-based pagination: sortowanie po `(distance_m ASC, id ASC)`, kursor trzyma (lastDistance, lastId).
5. Zwrócenie odpowiedzi:
   - Zmapuj do `ToolSearchItemDTO[]`, zbuduj `next_cursor` (base64 JSON) albo `null`.
   - Nagłówki: `Cache-Control: no-store`.

Uwaga implementacyjna: zapytanie przestrzenne i ranking po odległości są najwygodniejsze w funkcji SQL wywoływanej przez `rpc`. Alternatywa (złożony PostgREST join) jest mniej ergonomiczna i trudniej zarządzać kursorem.

Proponowana funkcja w DB (schemat poglądowy):
```sql
-- SECURITY DEFINER z odpowiednim ograniczeniem uprawnień!
create or replace function public.search_tools(
  p_user_id uuid,
  p_q text,
  p_limit int default 20,
  p_after jsonb default null
) returns table (
  id uuid,
  name text,
  distance_m integer,
  cursor_key jsonb
) language sql stable as $$
  with caller as (
    select location_geog from profiles where id = p_user_id and location_geog is not null
  ),
  base as (
    select
      t.id,
      t.name,
      round(ST_Distance(t.location_geog, c.location_geog))::int as distance_m
    from tools t
    cross join caller c
    where t.status = 'active'
      and t.search_name_tsv @@ plainto_tsquery('simple', p_q)
      and ST_DWithin(t.location_geog, c.location_geog, 10000)
  ),
  paged as (
    select *
    from base
    where (
      p_after is null
      or (distance_m, id) > (coalesce((p_after->>'lastDistance')::int, 0), coalesce((p_after->>'lastId')::uuid, '00000000-0000-0000-0000-000000000000'))
    )
    order by distance_m asc, id asc
    limit greatest(1, least(p_limit, 100))
  )
  select
    id,
    name,
    distance_m,
    jsonb_build_object('lastDistance', distance_m, 'lastId', id) as cursor_key
  from paged;
$$;
```

Wywołanie z API: `supabase.rpc('search_tools', { p_user_id, p_q, p_limit, p_after })`.

### 6. Względy bezpieczeństwa
- Autentykacja: wymagany zalogowany użytkownik (401 w przeciwnym razie).
- Autoryzacja/RLS:
  - Dane narzędzi są publiczne, ale wymuszamy `status = 'active'`.
  - Funkcja SQL powinna być `SECURITY DEFINER` z kontrolą uprawnień lub odpowiednio zawężonym zapytaniem respektującym RLS.
- Walidacja wejścia (Zod) – chroni przed nadużyciami i błędami:
  - Ogranicz długości i zakresy wartości (`q`, `limit`).
  - `cursor` parsowany jako bezpieczny base64(JSON) – odrzucać nieprawidłowe.
- Ochrona przed SQL injection:
  - Wyłącznie parametryzowane wywołania `rpc`; użycie `plainto_tsquery` eliminuje składnię ręczną TSQuery po stronie klienta.
- Prywatność:
  - Wyniki zależą od lokalizacji profilu użytkownika; nie ujawniamy lokalizacji innych użytkowników, tylko odległość do narzędzia.
- Rate limiting (zalecane):
  - Do rozważenia: proste ograniczenia per IP/user na warstwie edge/route.

### 7. Obsługa błędów
- 401 `UNAUTHORIZED`: brak sesji użytkownika.
- 400 `BAD_REQUEST`: nieprawidłowe parametry (`q` puste, `limit` poza zakresem, `cursor` niepoprawny JSON/base64).
- 400 `MISSING_LOCATION`: profil bez `location_geog`.
- 500 `INTERNAL`: nieoczekiwany błąd (np. błąd funkcji DB).

Logowanie:
- Błędy walidacyjne – logi serwera (konsola/observability).
- Zdarzenia „walidacja lokalizacji” można okazjonalnie rejestrować w `audit_log` (np. `event_type = 'search_missing_location'`, `actor_id=user_id`) – opcjonalnie, gdy potrzebne KPI/diagnostyka.

Struktura błędu: `ApiErrorDTO`.

### 8. Rozważania dotyczące wydajności
- Indeksy:
  - `tools.search_name_tsv` – GIN dla pełnotekstowego.
  - `tools.location_geog` – GIST dla zapytań przestrzennych.
  - `profiles.location_geog` – GIST.
- Zapytania przestrzenne:
  - `ST_DWithin` (geography) dla prefiltra 10 km.
  - `ST_Distance` liczone tylko dla kandydatów (po prefiltrze).
- Stronicowanie kursorem:
  - Stabilny porządek `(distance_m, id)`.
  - Kursor zawiera ostatni wiersz; `limit` max 100.
- Ograniczenie odpowiedzi:
  - Zwracamy tylko pola potrzebne dla listy (`id`, `name`, `distance_m`).
- Cache:
  - Brak cache ze względu na personalizację (nagłówek `Cache-Control: no-store`).

### 9. Kroki implementacji
1. Typy i walidacja (FE/BE):
   - Potwierdź użycie istniejących typów `ToolSearchItemDTO`, `ToolSearchPageDTO`, `ApiErrorDTO`.
   - Utwórz Zod schemat dla query: `q`, `limit`, `cursor`.
2. Warstwa DB (SQL):
   - Dodać funkcję `public.search_tools(...)` wg szkicu powyżej (migration).
   - Zapewnić indeksy GIN/GIST zgodnie z planem DB (jeśli brak).
3. Logika domenowa (Service):
   - `src/lib/services/tools.service.ts` (nowy plik): `searchActiveToolsNearProfile(supabase, userId, params): Promise<ToolSearchPageDTO>`.
   - Odpowiada za: pobranie profilu, walidację `location_geog`, wywołanie `rpc`, budowę kursora.
4. Endpoint (Astro API):
   - Plik: `src/pages/api/tools/search.ts`.
   - `export const prerender = false`.
   - `export async function GET(context) { ... }`:
     - Pobierz `supabase` z `context.locals`.
     - Parsuj query przez Zod.
     - Weryfikuj sesję użytkownika (401).
     - Wywołaj metodę serwisu.
     - Zwróć `200` z `ToolSearchPageDTO`.
     - Ustaw `Cache-Control: no-store`.
     - Mapuj błędy do `ApiErrorDTO` (400/401/500).
5. Testy:
   - Jednostkowe: walidacja Zod (limity, kursory), mapowanie błędów.
   - Integracyjne: scenariusze z danymi testowymi w DB (przynajmniej 3 narzędzia, różne odległości).
6. Telemetria i logi:
   - Dodaj strukturalne logi dla niepowodzeń i czasu wykonania zapytań (pomiar czasu od punktu wejścia do DB).
   - Opcjonalnie: zapis zdarzeń wybranych błędów do `audit_log`.
7. Dokumentacja:
   - Opis parametrów i przykładów odpowiedzi w README/API docs.
8. Wdrożenie:
   - Kolejność: migracja DB → deploy backend (Astro SSR) → smoke test.

### 10. Szkic interfejsów (serwis + endpoint)
Service (`src/lib/services/tools.service.ts`):
```ts
export interface ToolSearchParams {
  q: string;
  limit: number;
  cursor?: string | null;
}

export async function searchActiveToolsNearProfile(
  supabase: SupabaseClient,
  userId: string,
  params: ToolSearchParams
): Promise<ToolSearchPageDTO> {
  // 1) Pobierz profil i zweryfikuj location_geog
  // 2) Zdekoduj cursor -> p_after (JSON) lub null
  // 3) Wywołaj RPC: search_tools(p_user_id, p_q, p_limit, p_after)
  // 4) Zbuduj next_cursor z ostatniego rekordu (cursor_key) lub null
  // 5) Zwróć ToolSearchPageDTO
}
```

Endpoint (`src/pages/api/tools/search.ts`):
```ts
export const prerender = false;

import { z } from "zod";
import type { APIRoute } from "astro";
import { searchActiveToolsNearProfile } from "@/lib/services/tools.service";

const QuerySchema = z.object({
  q: z.string().trim().min(1).max(128),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  cursor: z.string().optional()
});

export const GET: APIRoute = async (context) => {
  const supabase = context.locals.supabase;
  const { data: authData } = await supabase.auth.getUser();
  if (!authData?.user) {
    return new Response(JSON.stringify({ error: { code: "UNAUTHORIZED", message: "Authentication required" } }), { status: 401 });
  }
  const parse = QuerySchema.safeParse(Object.fromEntries(context.url.searchParams));
  if (!parse.success) {
    return new Response(JSON.stringify({ error: { code: "BAD_REQUEST", message: "Invalid query", details: parse.error.flatten() } }), { status: 400 });
  }
  try {
    const result = await searchActiveToolsNearProfile(supabase, authData.user.id, parse.data);
    return new Response(JSON.stringify(result), { status: 200, headers: { "Cache-Control": "no-store" } });
  } catch (err: any) {
    // Mapowanie błędów domenowych: MISSING_LOCATION -> 400, itd.
    return new Response(JSON.stringify({ error: { code: "INTERNAL", message: "Unexpected error" } }), { status: 500 });
  }
};
```




