## API Endpoint Implementation Plan: POST /api/profile/geocode

### 1. Przegląd punktu końcowego
- Cel: Wymusić geokodowanie `location_text` dla zalogowanego użytkownika i zapisać wynik do `profiles.location_geog` (geography(Point, 4326)).
- Zwraca: GeoJSON Point `[lon, lat]` potwierdzający zapisane współrzędne.
- Uwagi: Brak request body (operacja bazuje na stanie profilu); logowanie zdarzeń w `audit_log`.

### 2. Szczegóły żądania
- **Metoda HTTP**: POST
- **URL**: `/api/profile/geocode`
- **Parametry**:
  - **Wymagane**: brak (kontekst użytkownika z sesji)
  - **Opcjonalne**: brak
- **Request Body**: pusty (`{}`) – walidacja twarda na puste ciało
- **Nagłówki**: `content-type: application/json` (chociaż brak treści), autoryzacja via Supabase sesja cookie/headers

### 3. Wykorzystywane typy
- DTO (istniejące w `src/types.ts`):
  - `GeoJSONPoint` – `{ type: "Point", coordinates: [number, number] /* [lon, lat] */ }`
  - `ProfileGeocodeResultDTO` – `{ location_geog: GeoJSONPoint }`
  - `ApiErrorDTO` – standardowy envelope błędu
- Command modele: brak (operacja bez body)

### 4. Szczegóły odpowiedzi
- 200 OK: `ProfileGeocodeResultDTO`
  ```json
  { "location_geog": { "type": "Point", "coordinates": [lon, lat] } }
  ```
- 400 Bad Request: `ApiErrorDTO` – brak/nieprawidłowe `location_text`
- 401 Unauthorized: `ApiErrorDTO` – brak sesji
- 404 Not Found: `ApiErrorDTO` – brak wiersza w `profiles`
- 422 Unprocessable Entity: `ApiErrorDTO` – geocoder failed/zero-results
- 500 Internal Server Error: `ApiErrorDTO` – błąd serwera/DB
- Nagłówki: `cache-control: no-store`, `content-type: application/json; charset=utf-8`

### 5. Przepływ danych
1. API route (`src/pages/api/profile/geocode.ts`) odbiera POST.
2. Autoryzacja: pobierz `locals.supabase` i `userId` via `getAuthenticatedUserId(supabase)`.
3. Odczyt profilu: `fetchProfileById(supabase, userId)`; walidacja, że `location_text` istnieje i niepuste.
4. Geokodowanie: `geocodeLocationText(location_text)` (nowy serwis) → `{ lon, lat }`.
5. Persist: aktualizacja `profiles.location_geog` na GeoJSON Point `[lon, lat]` via Supabase update (GeoJSON → geography) lub funkcja RPC jeśli polityki/typy wymagają.
6. Audit log: zapis zdarzeń (security/validation/failure/success) via `logAuditEvent`.
7. Response: `jsonOk({ location_geog })`.

### 6. Względy bezpieczeństwa
- **Auth**: obowiązkowe – 401 gdy brak sesji.
- **RLS**: aktualizacja `profiles` musi być dozwolona dla właściciela; fallback do service-role tylko po stronie serwera (jeśli polityki tak wymagają). Nie ujawniać key.
- **Secret management**: klucze do geokodera w zmiennych środowiskowych (server-only). Zaktualizować `src/env.d.ts` o np. `OPENCAGE_API_KEY`/`MAPBOX_TOKEN`.
- **Input hardening**: puste body, walidacja `location_text` (trim, długość, białe znaki).
- **Rate limiting/abuse**: potencjalnie dodać throttle na użytkownika (poza zakresem tej iteracji).
- **PII**: nie logować pełnego `location_text` w szczegółach błędów w produkcji.
- **SSRF**: żądania tylko do zaufanego dostawcy (stały endpoint), timeouts i ograniczenie redirectów.

### 7. Obsługa błędów
- 401 `auth_required`: brak sesji.
- 404 `profile_not_found`: brak wiersza profilu dla `userId`.
- 400 `bad_location`: `location_text` null/""/whitespace.
- 422 `geocode_failed`: zewnętrzny geocoder błąd/zero-results.
- 500 `internal_error`: wyjątek serwera/Supabase błąd update’u.
- Audit trail:
  - `security` (401), `profile_missing` (404), `profile_geocode_bad_location` (400), `profile_geocode_failed` (422), `profile_geocode_success` (200).

### 8. Rozważania dotyczące wydajności
- Cache geokodowania (opcjonalnie) po stronie serwera (np. hash `location_text` → coords) z TTL, by ograniczyć koszty.
- Timeout i retry (bez powielania zapisów) dla providerów.
- Minimalizacja alokacji: używaj bezpiecznego update jednego wiersza (`.eq("id", userId).limit(1).single()`).

### 9. Kroki implementacji
1. Endpoint plik i szkielety
   - Utwórz `src/pages/api/profile/geocode.ts` z `export const prerender = false` i `export async function POST(...)`.
   - Wykorzystaj istniejące helpery: `jsonOk/jsonError` z `src/lib/api/responses.ts` oraz `getAuthenticatedUserId`, `fetchProfileById`, `logAuditEvent` z `src/lib/services/profile.service.ts`.

2. Walidacja wejścia (Zod)
   - Schemat body: `z.object({}).strict()` – odrzuć pola nieznane; brak treści → OK.
   - Walidacja profilu: `location_text` wymagane, `location_text.trim().length > 0`.

3. Serwis geokodujący
   - Dodaj `src/lib/services/geocoding.service.ts`:
     - `export interface GeocodeResult { lon: number; lat: number; }`
     - `export async function geocodeLocationText(q: string): Promise<GeocodeResult>` – implementacja via provider:
       - Prefer OpenCage/Mapbox/Nominatim. Użyj `fetch` z timeoutem i twardą walidacją odpowiedzi (status, struktura, zakresy współrzędnych).
     - Obsłuż: `429`, `5xx`, `0 results` -> sygnalizuj błąd do warstwy API.
   - Zmienne środowiskowe (server-only): dodać do `src/env.d.ts` np. `OPENCAGE_API_KEY?: string` (wpis do `.env` w README).

4. Zapis do DB
   - Bezpośredni update GeoJSON → geography:
     - `await supabase.from("profiles").update({ location_geog: { type: "Point", coordinates: [lon, lat] } as any }).eq("id", userId).single();`
     - W PostgREST typ geography akceptuje GeoJSON (rzutowanie przez PostGIS do `geometry` i dalej do `geography`).
   - Fallback (jeśli RLS/typ odmawia): RPC `set_profile_location_geog(p_user_id uuid, p_lon numeric, p_lat numeric)` (SECURITY DEFINER), implementacja SQL: `UPDATE profiles SET location_geog = ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326)::geography WHERE id = p_user_id;` – wywołanie przez `createServiceClient()`.

5. Struktura odpowiedzi
   - Zwracaj `ProfileGeocodeResultDTO` konstruowane lokalnie z `{ lon, lat }`.

6. Kody statusu i komunikaty
   - Zgodnie z sekcją 7 – używaj `jsonError(status, code, message, details?)`.

7. Audit log
   - W każdym rozgałęzieniu dodaj `logAuditEvent` z właściwym `event_type` i skróconymi `details` (bez PII), np. `{ endpoint: "/api/profile/geocode" }`.

8. Testy ręczne (quick checks)
   - POST bez sesji → 401 `auth_required`.
   - POST z sesją i brakiem profilu → 404 `profile_not_found`.
   - POST z sesją i pustym `location_text` → 400 `bad_location`.
   - POST z sesją i poprawnym `location_text` → 200 i GeoJSON point.
   - Symulacja geocoder failure → 422 `geocode_failed`.

9. Dokumentacja i środowisko
   - Uzupełnij `README.md` o konfigurację kluczy geokodera i przykład odpowiedzi.
   - Dopisz nowe env keys do `src/env.d.ts` i `.env.example`.

### 10. Szkic kontrolera (orientacyjny, bez pełnej implementacji)
```ts
// src/pages/api/profile/geocode.ts
import type { APIContext } from "astro";
import { z } from "zod";
import { jsonOk, jsonError } from "../../lib/api/responses.ts";
import { getAuthenticatedUserId, fetchProfileById, logAuditEvent } from "../../lib/services/profile.service.ts";
import type { GeoJSONPoint } from "../../types.ts";
import { geocodeLocationText } from "../../lib/services/geocoding.service.ts";

export const prerender = false;

const EmptyBodySchema = z.object({}).strict();

export async function POST({ locals, request }: APIContext): Promise<Response> {
  const supabase = locals.supabase;
  if (!supabase) return jsonError(500, "internal_error", "Unexpected server configuration error.");

  try {
    // body is optional/empty; validate extra fields
    const body = await request.json().catch(() => ({}));
    const parse = EmptyBodySchema.safeParse(body);
    if (!parse.success) {
      return jsonError(400, "bad_request", "Unexpected body payload.");
    }

    const userId = await getAuthenticatedUserId(supabase);
    if (!userId) {
      await logAuditEvent(supabase, "security", null, { endpoint: "/api/profile/geocode", reason: "auth_required" });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    const profile = await fetchProfileById(supabase, userId);
    if (!profile) {
      await logAuditEvent(supabase, "profile_missing", userId, { endpoint: "/api/profile/geocode" });
      return jsonError(404, "profile_not_found", "Profile not found.");
    }

    const locationText = (profile.location_text ?? "").trim();
    if (!locationText) {
      await logAuditEvent(supabase, "profile_geocode_bad_location", userId, { endpoint: "/api/profile/geocode" });
      return jsonError(400, "bad_location", "Location text is required.");
    }

    const { lon, lat } = await geocodeLocationText(locationText).catch(() => ({ lon: NaN, lat: NaN }));
    if (!Number.isFinite(lon) || !Number.isFinite(lat)) {
      await logAuditEvent(supabase, "profile_geocode_failed", userId, { endpoint: "/api/profile/geocode" });
      return jsonError(422, "geocode_failed", "Could not geocode the provided location.");
    }

    const location_geog: GeoJSONPoint = { type: "Point", coordinates: [lon, lat] };

    const { error } = await supabase
      .from("profiles")
      .update({ location_geog: location_geog as unknown as any })
      .eq("id", userId)
      .single();

    if (error) {
      await logAuditEvent(supabase, "profile_geocode_failed", userId, { endpoint: "/api/profile/geocode", code: error.code });
      return jsonError(500, "internal_error", "Failed to persist geocoded location.");
    }

    await logAuditEvent(supabase, "profile_geocode_success", userId, { endpoint: "/api/profile/geocode" });
    return jsonOk({ location_geog });
  } catch {
    return jsonError(500, "internal_error", "Unexpected server error.");
  }
}
```
