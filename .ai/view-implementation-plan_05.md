## API Endpoint Implementation Plan: POST /api/tools

### 1. Przegląd punktu końcowego

Tworzy szkic ogłoszenia narzędzia (status = `draft`) przypisanego do zalogowanego użytkownika. Endpoint przyjmuje nazwę, opcjonalny opis oraz sugerowaną cenę w tokenach (1–5). Zwraca utworzony rekord narzędzia.

### 2. Szczegóły żądania

- **Metoda HTTP**: POST
- **URL**: `/api/tools`
- **Nagłówki**:
  - **Content-Type**: `application/json`
  - Odpowiedzi: `cache-control: no-store` (spójnie z istniejącą infrastrukturą `jsonOk/jsonError`)
- **Parametry**:
  - **Wymagane**:
    - `name: string` — nazwa narzędzia, niepusta po `trim()`
    - `suggested_price_tokens: number` — całkowita liczba z zakresu [1, 5]
  - **Opcjonalne**:
    - `description: string | null` — opis; dopuszczalne puste, ale mapowane do `null`
- **Request Body (JSON)**:
```json
{ "name": "string", "description": "string|null", "suggested_price_tokens": 1 }
```

### 3. Wykorzystywane typy

- Z `src/types.ts`:
  - `CreateToolCommand = Pick<Insert<"tools">, "name" | "description" | "suggested_price_tokens">`
  - `ToolDTO = Omit<Row<"tools">, "search_name_tsv">`
  - `ApiErrorDTO` dla koperty błędu
- Nowe (jeśli chcemy wyraźnie rozdzielić wejście API od Command):
  - `CreateToolRequestDTO` (input DTO – opcjonalne, można użyć `CreateToolCommand` bezpośrednio)

### 4. Szczegóły odpowiedzi

- **201 Created** — ciało: `ToolDTO`
```json
{
  "id": "uuid",
  "owner_id": "uuid",
  "name": "string",
  "description": "string|null",
  "suggested_price_tokens": 1,
  "status": "draft",
  "created_at": "timestamptz",
  "updated_at": "timestamptz",
  "archived_at": null
}
```
- **Błędy** (koperta `ApiErrorDTO`):
  - 400 `invalid_payload` — błędny JSON, zły typ pola, pusta nazwa itp.
  - 401 `auth_required` — brak sesji
  - 404 `profile_not_found` — brak wiersza profilu dla zalogowanego użytkownika (FK tools.owner_id ➝ profiles.id)
  - 422 `price_out_of_range` — `suggested_price_tokens` poza [1, 5]
  - 500 `internal_error` — pozostałe błędy serwera

### 5. Przepływ danych

1. Klient wysyła POST `/api/tools` z JSON body.
2. Endpoint:
   - Pobiera `locals.supabase` (Astro middleware zapewnia klienta Supabase w `context.locals`).
   - Ustala `userId` przez `getAuthenticatedUserId(supabase)`.
   - Waliduje body Zod-em, rozróżniając: ogólne naruszenia (400) vs zakres ceny (422).
   - Opcjonalnie weryfikuje istnienie profilu: `fetchProfileById(supabase, userId)` (czytelniejsze błędy 404, zamiast łapać wyłącznie błąd FK).
   - Deleguje do serwisu: `createToolDraft(supabase, userId, command)`.
   - Zapisuje wpis w `audit_log` (security / tool_created / tool_create_failed).
   - Zwraca `201` i `ToolDTO`.

### 6. Względy bezpieczeństwa

- **Uwierzytelnianie**: wymagane; stosuj `getAuthenticatedUserId` (wspiera dev `AUTH_BYPASS`).
- **Autoryzacja / RLS**: polityka DB powinna pozwalać na `INSERT` do `tools` tylko gdy `owner_id = auth.uid()`. Plan zakłada korzystanie z `locals.supabase` (RLS on) bez klucza serwisowego.
- **Walidacja wejścia**: Zod — ogranicz długość pól (`name`, `description`) i zakres wartości (`suggested_price_tokens`).
- **Ochrona przed nadużyciami**: limit rozmiaru JSON (np. 32KB), `no-store` w odpowiedzi, ewentualny rate-limit na warstwie edge/proxy (poza zakresem tego repo).
- **Logowanie bezpieczeństwa**: zapis do `audit_log` zdarzeń typu `security` przy 401 (próba bez sesji).

### 7. Obsługa błędów

- 400 `invalid_payload`: błędny JSON, typy pól, `name.trim().length === 0`.
- 401 `auth_required`: brak sesji użytkownika.
- 404 `profile_not_found`: brak wiersza `profiles` dla `userId`.
- 422 `price_out_of_range`: `suggested_price_tokens` poza [1, 5] — zarówno z walidacji Zod, jak i naruszenia CHECK `23514` (mapowane na 422).
- 500 `internal_error`: inne wyjątki / niespodziewane kody Supabase.

Zachowaj spójność koperty błędów (`ApiErrorDTO`) i nagłówków (`cache-control: no-store`).

### 8. Rozważania dotyczące wydajności

- Pojedynczy `INSERT` — O(1); narzut minimalny.
- Zbędne dodatkowe `SELECT` (weryfikacja profilu) można pominąć i mapować `FK violation 23503` na 404 — jednak rekomendowane jest jawne sprawdzenie profilu dla lepszej ergonomii błędów.
- Indeksy z planu DB (np. `(owner_id, status)`) ułatwią dalsze listowanie; nie wpływają na `INSERT`.

### 9. Kroki implementacji

1) Zależności i helpery

- Zainstaluj Zod:
```bash
npm i zod
```
- Dodaj helper `jsonCreated` w `src/lib/api/responses.ts`:
```ts
export function jsonCreated<T>(body: T): Response {
  return new Response(JSON.stringify(body), { status: 201, headers: JSON_HEADERS });
}
```

2) Serwis narzędzi `src/lib/services/tools.service.ts`

- Publiczna funkcja:
```ts
import type { SupabaseClient } from "../../db/supabase.client.ts";
import type { CreateToolCommand, ToolDTO } from "../../types.ts";

export async function createToolDraft(
  supabase: SupabaseClient,
  ownerId: string,
  command: CreateToolCommand
): Promise<ToolDTO> {
  const payload = { ...command, owner_id: ownerId, status: "draft" as const };
  const { data, error } = await supabase.from("tools").insert(payload).select("*").single();
  if (error) {
    // Mapowanie wybranych kodów: CHECK (23514) => 422, FK (23503) => 404; reszta => 500 (wyżej)
    throw error;
  }
  return data as ToolDTO;
}
```
- W razie potrzeby dodaj klasę błędu (analogicznie do `SupabaseQueryError`) i mapuj `error.code` na kody HTTP w warstwie endpointu.

3) Endpoint `src/pages/api/tools.ts`

- Struktura:
```ts
import type { APIContext } from "astro";
import { z } from "zod";
import { jsonError } from "../../lib/api/responses.ts";
import { jsonCreated } from "../../lib/api/responses.ts";
import { getAuthenticatedUserId, logAuditEvent, fetchProfileById } from "../../lib/services/profile.service.ts";
import { createToolDraft } from "../../lib/services/tools.service.ts";

export const prerender = false;

const CreateToolSchema = z.object({
  name: z.string().trim().min(1).max(200),
  description: z.string().max(5000).nullable().optional()
    .transform((v) => (v === undefined ? null : v)),
  suggested_price_tokens: z.number().int()
    .refine((n) => n >= 1 && n <= 5, { message: "price_out_of_range" })
});

export async function POST({ locals, request }: APIContext): Promise<Response> {
  const supabase = locals.supabase;
  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  let parsed;
  try {
    const body = await request.json();
    parsed = CreateToolSchema.safeParse(body);
  } catch {
    return jsonError(400, "invalid_payload", "Invalid JSON body.");
  }

  if (!parsed.success) {
    const issue = parsed.error.issues.find((i) => i.message === "price_out_of_range");
    if (issue) {
      return jsonError(422, "price_out_of_range", "suggested_price_tokens must be between 1 and 5.");
    }
    return jsonError(400, "invalid_payload", "Request body validation failed.");
  }

  try {
    const userId = await getAuthenticatedUserId(supabase);
    if (!userId) {
      await logAuditEvent(supabase, "security", null, { endpoint: "/api/tools", reason: "auth_required" });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    // (Opcjonalnie) weryfikuj istnienie profilu, by uzyskać 404 zamiast błędu FK
    const profile = await fetchProfileById(supabase, userId);
    if (!profile) {
      return jsonError(404, "profile_not_found", "Profile not found.");
    }

    const tool = await createToolDraft(supabase, userId, parsed.data);
    await logAuditEvent(supabase, "tool_created", userId, { tool_id: tool.id });
    return jsonCreated(tool);
  } catch (error: any) {
    // Mapuj wybrane kody Postgres/PGREST
    const code = error?.code as string | undefined;
    if (code === "23514") {
      return jsonError(422, "price_out_of_range", "suggested_price_tokens must be between 1 and 5.");
    }
    if (code === "23503") {
      return jsonError(404, "profile_not_found", "Profile not found.");
    }
    await logAuditEvent(supabase, "tool_create_failed", null, { reason: code ?? "unknown" });
    return jsonError(500, "internal_error", "Unexpected server error.", code ? { code } : undefined);
  }
}
```

4) Polityki RLS (w DB/migracjach)

- Upewnij się, że istnieje polityka: `INSERT INTO tools` dozwolone, gdy `owner_id = auth.uid()`.
- CHECK: `suggested_price_tokens BETWEEN 1 AND 5` (z planu DB) — już egzekwowane w schemacie.

5) Testy i weryfikacja manualna

- Scenariusze:
  - POST bez sesji ➝ 401 `auth_required`
  - POST z niepoprawnym JSON ➝ 400 `invalid_payload`
  - POST z `suggested_price_tokens = 0|6` ➝ 422 `price_out_of_range`
  - POST z pustym `name` ➝ 400 `invalid_payload`
  - POST z poprawnymi danymi i istniejącym profilem ➝ 201 + `ToolDTO`
- Przykładowy cURL:
```bash
curl -X POST http://localhost:4321/api/tools \
  -H "Content-Type: application/json" \
  -d '{"name":"Wiertarka","description":"","suggested_price_tokens":3}'
```

6) Zgodność z regułami projektu

- Astro Server Endpoints, `export const prerender = false`, handler `POST` (uppercase).
- Walidacja Zod, logika w serwisie w `src/lib/services`, użycie `locals.supabase`.
- Typy wspólne w `src/types.ts`.



