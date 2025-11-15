## API Endpoint Implementation Plan: GET /api/tools/:id

### 1. Przegląd punktu końcowego

Punkt końcowy zwraca szczegóły pojedynczego narzędzia wraz z uporządkowanymi obrazami. Dane są publicznie dostępne wyłącznie, gdy `tools.status = 'active'`. Dla statusów innych niż `active` zasób jest dostępny wyłącznie dla właściciela narzędzia (autoryzowany użytkownik, którego `profiles.id = tools.owner_id`). Zwracamy uporządkowane obrazy wg `tool_images.position`.

### 2. Szczegóły żądania

- **Metoda HTTP**: GET
- **Struktura URL**: `/api/tools/:id`
- **Parametry**:
  - **Wymagane**:
    - `id` (path) — identyfikator narzędzia, `UUID`
  - **Opcjonalne**: brak
- **Request Body**: brak

### 3. Wykorzystywane typy

- **Z DB/Types** (`src/types.ts`):
  - `ToolDTO = Omit<Row<"tools">, "search_name_tsv">`
  - `ToolImageDTO = Row<"tool_images">`
  - `ToolWithImagesDTO = ToolDTO & { images: ToolImageDTO[] }`
  - `ToolStatus = Enums<"tool_status">` (`'draft' | 'inactive' | 'active' | 'archived'`)
- **DTOs** (odpowiedź): `ToolWithImagesDTO`
- **Command/Params** (wejście):
  - `GetToolPathParams = { id: string }`
- **Błędy**: `ApiErrorDTO` z `src/lib/api/responses.ts` (użycie `jsonError`/`jsonOk`)

### 4. Szczegóły odpowiedzi

- **200 OK**: `ToolWithImagesDTO`
  - Pola `tools` bez `search_name_tsv` + `images: ToolImageDTO[]` posortowane rosnąco po `position`.
- **401 Unauthorized**: gdy narzędzie istnieje, lecz nie jest `active` i użytkownik nie jest zalogowany lub nie jest właścicielem.
- **404 Not Found**: gdy `id` nie istnieje.
- **400 Bad Request**: niepoprawne `id` (nie-UUID).
- **500 Internal Server Error**: błąd serwera lub zapytania do DB.

Nagłówki domyślnie z `JSON_HEADERS` → `cache-control: no-store`. Dla publicznego zasobu (`active`) można nadpisać cache, patrz sekcja Wydajność.

### 5. Przepływ danych

1. Parsowanie `:id` i walidacja (Zod: `string().uuid()`).
2. Pobranie `supabase` z `context.locals` (ustawiane w `src/middleware/index.ts`).
3. Pobranie bieżącego użytkownika (opcjonalnie) przez istniejące `getAuthenticatedUserId`.
4. Zapytanie do DB o narzędzie i jego obrazy w jednym wywołaniu.
5. Autoryzacja odczytu: `status === 'active'` → publiczne; w innym przypadku wymagany właściciel.
6. Zwrócenie `200` z `ToolWithImagesDTO` lub odpowiedni błąd (`401/404/400/500`).
7. Zapisy audytu (best-effort) przy odczycie i odmowie dostępu.

### 6. Względy bezpieczeństwa

- **Uwierzytelnienie**: Supabase session z `locals.supabase.auth.getUser()` (wspierane przez middleware SSR). Brak sesji → tylko zasoby `active` są dostępne.
- **Autoryzacja aplikacyjna**: jawny warunek: jeśli `status !== 'active'`, to `userId === owner_id`, inaczej `401`.
- **Audyt**: zapisy do `audit_log` przez istniejące `logAuditEvent` (service-role, best-effort), np. `event_type: 'tool_read' | 'tool_not_found' | 'security'`.
- **RLS (zalecane)**: polityki w DB:
  - `tools`: `SELECT` dla `status = 'active'` dla wszystkich; `SELECT` dla `owner_id = auth.uid()` dla nie-`active`.
  - `tool_images`: `SELECT` powiązany z widocznością `tools` (policy z subselectem).
- **Nagłówki cache**: dla prywatnych odpowiedzi nie stosować public cache; rozważyć `Vary: Authorization` dla aktywnych odpowiedzi z publicznym cache.

### 7. Obsługa błędów

- **400 invalid_id**: `id` nie jest `UUID`.
- **401 auth_required / owner_only**: brak sesji albo sesja nie jest właścicielem dla nie-`active`.
- **404 tool_not_found**: brak rekordu `tools.id`.
- **500 internal_error**: nieoczekiwany błąd (np. Supabase error, serializacja).

Mapowanie na `jsonError(status, code, message, details?)` zgodnie ze wzorcem w `src/pages/api/profile.ts`.

### 8. Rozważania dotyczące wydajności

- **Jedno zapytanie**: pobierz narzędzie wraz z obrazami w jednym wywołaniu Supabase, posortuj przez `foreignTable`.
- **Indeksy**: wykorzystywać `UNIQUE(tool_id, position)` w `tool_images`; dodatkowo `INDEX (owner_id, status)` w `tools` już w planie DB.
- **Selektowanie pól**: wybieraj tylko potrzebne kolumny; pomiń `search_name_tsv`.
- **Cache dla publicznych**: dla `active` można zwrócić:
  - `cache-control: public, max-age=60, stale-while-revalidate=120`
  - `Vary: Authorization`
  Wymaga własnej odpowiedzi zamiast `jsonOk`, aby nadpisać nagłówki.

### 9. Kroki implementacji

1) **Schematy Zod** (`src/lib/utils.ts` lub nowy plik `src/lib/validators.ts`):

```ts
import { z } from "zod";

export const GetToolPathParamsSchema = z.object({
  id: z.string().uuid(),
});
export type GetToolPathParams = z.infer<typeof GetToolPathParamsSchema>;
```

2) **Warstwa serwisowa** `src/lib/services/tools.service.ts`:

```ts
import type { SupabaseClient } from "../../db/supabase.client";
import type { ToolWithImagesDTO, ToolImageDTO, ToolDTO } from "../../types";
import { SupabaseQueryError } from "./profile.service"; // reuse wspólnych klas błędów

const NOT_FOUND = "PGRST116";

export async function fetchToolWithImagesById(
  supabase: SupabaseClient,
  toolId: string
): Promise<ToolWithImagesDTO | null> {
  const { data, error } = await supabase
    .from("tools")
    .select(
      "id, owner_id, name, description, suggested_price_tokens, status, created_at, updated_at, archived_at, " +
        "tool_images (id, tool_id, storage_key, position, created_at)"
    )
    .eq("id", toolId)
    .order("position", { foreignTable: "tool_images", ascending: true })
    .single();

  if (error) {
    if (error.code === NOT_FOUND) return null;
    throw new SupabaseQueryError("Failed to fetch tool.", error.code, error);
  }

  const images: ToolImageDTO[] = Array.isArray((data as any).tool_images)
    ? (data as any).tool_images
    : [];

  const tool: ToolDTO = {
    id: data.id,
    owner_id: data.owner_id,
    name: data.name,
    description: data.description,
    suggested_price_tokens: data.suggested_price_tokens,
    status: data.status,
    created_at: data.created_at,
    updated_at: data.updated_at,
    archived_at: data.archived_at,
  };

  return { ...tool, images };
}
```

3) **Endpoint** `src/pages/api/tools/[id].ts`:

```ts
import type { APIContext } from "astro";
import { z } from "zod";
import { jsonError } from "../../../lib/api/responses";
import { fetchToolWithImagesById } from "../../../lib/services/tools.service";
import { getAuthenticatedUserId, logAuditEvent, SupabaseAuthError, SupabaseQueryError } from "../../../lib/services/profile.service";

export const prerender = false;

const PathParams = z.object({ id: z.string().uuid() });

export async function GET({ params, locals }: APIContext): Promise<Response> {
  const supabase = locals.supabase;
  if (!supabase) return jsonError(500, "internal_error", "Unexpected server configuration error.");

  const parse = PathParams.safeParse(params);
  if (!parse.success) {
    return jsonError(400, "invalid_id", "Invalid tool id.");
  }
  const { id } = parse.data;

  try {
    const userId = await getAuthenticatedUserId(supabase); // może być null
    const tool = await fetchToolWithImagesById(supabase, id);
    if (!tool) {
      await logAuditEvent(supabase, "tool_not_found", userId, { endpoint: "/api/tools/:id", tool_id: id });
      return jsonError(404, "tool_not_found", "Tool not found.");
    }

    const isPublic = tool.status === "active";
    const isOwner = userId && userId === tool.owner_id;
    if (!isPublic && !isOwner) {
      await logAuditEvent(supabase, "security", userId, { endpoint: "/api/tools/:id", reason: "owner_only", tool_id: id });
      return jsonError(401, "owner_only", "Only the owner can access this tool.");
    }

    const body = JSON.stringify(tool);
    // Opcjonalne: public cache dla aktywnych
    if (isPublic) {
      return new Response(body, {
        status: 200,
        headers: {
          "content-type": "application/json; charset=utf-8",
          "cache-control": "public, max-age=60, stale-while-revalidate=120",
          Vary: "Authorization",
        },
      });
    }

    // Domyślnie no-store z jsonOk, ale utrzymujemy ręcznie aby uniknąć duplikatu importu
    return new Response(body, {
      status: 200,
      headers: {
        "content-type": "application/json; charset=utf-8",
        "cache-control": "no-store",
      },
    });
  } catch (error) {
    const details = error instanceof SupabaseQueryError ? (error.code ? { code: error.code } : undefined) : undefined;
    if (error instanceof SupabaseAuthError) {
      // Brak sesji nie jest błędem tutaj — już mapujemy to na 401 owner_only wyżej
    }
    return jsonError(500, "internal_error", "Unexpected server error.", details);
  }
}
```

4) **Logika audytu**: użyj istniejącego `logAuditEvent` (service-role fallback). Zdarzenia sugerowane:
   - `tool_read` (sukces), `tool_not_found` (404), `security` (401 owner-only). W `details` umieścić `tool_id` oraz `endpoint`.

5) **Testy manualne** (komentarz w pliku endpointu, jak w `profile.ts`):
   - GET `/api/tools/:id` nieistniejący → 404
   - GET `/api/tools/:id` `status=active` (bez sesji) → 200, public cache
   - GET `/api/tools/:id` `status!=active` (bez sesji) → 401 owner_only
   - GET `/api/tools/:id` `status!=active` (inna sesja) → 401 owner_only
   - GET `/api/tools/:id` `status!=active` (sesja właściciela) → 200, no-store

### 10. Kody stanu i mapowanie

- **200**: poprawny odczyt narzędzia
- **400**: niepoprawne `id` (nie-UUID)
- **401**: brak autoryzacji do odczytu zasobu niepublicznego
- **404**: brak zasobu
- **500**: błąd serwera

### 11. Uwagi dot. zgodności z regułami projektu

- **Astro API**: `export const prerender = false`, `export async function GET(...)`.
- **Supabase**: użycie `locals.supabase` (middleware SSR). Typ `SupabaseClient` z `src/db/supabase.client.ts`.
- **Walidacja**: Zod dla parametrów ścieżki.
- **Serwisy**: cała logika dostępu do DB w `src/lib/services/tools.service.ts`.
- **Błędy**: klasy `SupabaseQueryError/SupabaseAuthError` ponownie użyte, spójne z innymi endpointami.
- **Zgodność DB**: `suggested_price_tokens` mieści się w `[1,5]` — db constraint, bez potrzeby dodatkowej walidacji tutaj (tylko odczyt).



