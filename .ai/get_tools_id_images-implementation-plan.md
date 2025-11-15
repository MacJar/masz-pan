# API Endpoint Implementation Plan: GET /api/tools/:id/images

## 1. Przegląd punktu końcowego

Celem tego punktu końcowego jest pobranie i zwrócenie listy wszystkich obrazów powiązanych z określonym narzędziem. Dostęp do zasobów jest warunkowy: publiczny dla narzędzi o statusie 'active' oraz ograniczony do właściciela dla narzędzi w innych statusach.

## 2. Szczegóły żądania

- **Metoda HTTP**: `GET`
- **Struktura URL**: `/api/tools/{id}/images`
- **Parametry**:
  - **Wymagane**:
    - `id` (parametr ścieżki, UUID): Unikalny identyfikator narzędzia.
  - **Opcjonalne**: Brak.
- **Request Body**: Brak.

## 3. Wykorzystywane typy

- **DTO (Data Transfer Object)**:
  - `ToolImageDTO`: Reprezentuje pojedynczy obraz narzędzia. Struktura odpowiedzi będzie tablicą tego typu: `ToolImageDTO[]`.
    ```typescript:src/types.ts
    export type ToolImageDTO = Row<"tool_images">;
    ```
  - `ApiErrorDTO`: Standardowy format odpowiedzi w przypadku błędu.

## 4. Przepływ danych

1.  Klient wysyła żądanie `GET` na adres `/api/tools/{id}/images`.
2.  Astro API Route (`src/pages/api/tools/[id]/images.ts`) odbiera żądanie.
3.  Waliduje parametr `id` przy użyciu `zod`, sprawdzając, czy jest to poprawny UUID. W razie błędu zwraca `400`.
4.  Pobiera ID bieżącego użytkownika z `Astro.locals.session`.
5.  Wywołuje funkcję `getToolImagesForTool(toolId, userId)` z serwisu `ToolsService` (`src/lib/services/tools.service.ts`).
6.  `ToolsService` wykonuje następujące operacje w ramach pojedynczej logiki:
    a. Pobiera dane narzędzia (`tools`) o zadanym `id` w celu weryfikacji jego statusu i właściciela. Jeśli narzędzie nie istnieje, rzuca `NotFoundError`.
    b. Sprawdza uprawnienia dostępu:
        - Zezwala na dostęp, jeśli `tool.status === 'active'`.
        - Zezwala na dostęp, jeśli `userId === tool.owner_id`.
        - W przeciwnym razie rzuca `ForbiddenError`.
    c. Jeśli dostęp jest dozwolony, pobiera wszystkie powiązane rekordy z tabeli `tool_images`, sortując je rosnąco według pola `position`.
    d. Zwraca listę obrazów do handlera API.
7.  Handler API serializuje listę `ToolImageDTO` do formatu JSON i zwraca ją z kodem statusu `200 OK`.
8.  W przypadku błędów rzuconych przez serwis, handler przechwytuje je i mapuje na odpowiednie kody statusu HTTP (404, 403, 500).

## 5. Względy bezpieczeństwa

- **Uwierzytelnianie**: Sesja użytkownika jest zarządzana przez middleware Astro i dostępna w `Astro.locals.session`. ID użytkownika jest niezbędne do weryfikacji własności.
- **Autoryzacja**:
  - Logika autoryzacji musi być zaimplementowana w `ToolsService`, aby zapobiec dostępowi do obrazów narzędzi nieaktywnych (`draft`, `archived`) przez użytkowników innych niż właściciel.
  - Jako druga linia obrony, zostanie zaimplementowana polityka **Row-Level Security (RLS)** na tabeli `tool_images`. Polityka ta będzie zezwalać na operację `SELECT` tylko wtedy, gdy status powiązanego narzędzia to `active` LUB ID zalogowanego użytkownika (`auth.uid()`) jest zgodne z `tools.owner_id`.
- **Walidacja danych wejściowych**: Parametr `id` musi być walidowany jako UUID, aby zapobiec błędom zapytań do bazy danych i potencjalnym atakom.

## 6. Obsługa błędów

Punkt końcowy będzie obsługiwał następujące scenariusze błędów:

- **400 Bad Request**: Zwracany, gdy `id` w ścieżce URL nie jest prawidłowym formatem UUID.
  ```json
  { "error": { "code": "INVALID_INPUT", "message": "Tool ID must be a valid UUID" } }
  ```
- **401 Unauthorized**: Zwracany, gdy użytkownik jest niezalogowany i próbuje uzyskać dostęp do narzędzia, które nie ma statusu `active`.
- **403 Forbidden**: Zwracany, gdy zalogowany użytkownik próbuje uzyskać dostęp do nieaktywnego narzędzia, którego nie jest właścicielem.
- **404 Not Found**: Zwracany, gdy narzędzie o podanym `id` nie istnieje w bazie danych.
  ```json
  { "error": { "code": "NOT_FOUND", "message": "Tool not found" } }
  ```
- **500 Internal Server Error**: Zwracany w przypadku nieoczekiwanych błędów serwera, np. problemów z połączeniem z bazą danych.

## 7. Rozważania dotyczące wydajności

- Zapytanie do bazy danych o obrazy powinno być wydajne dzięki indeksowi na kluczu obcym `tool_images.tool_id`.
- Sortowanie po kolumnie `position` również powinno być szybkie, ponieważ liczba obrazów na narzędzie jest ograniczona (zgodnie z PRD).
- Obrazy zwracane w DTO zawierają `storage_key`, a nie same dane binarne. Klient będzie odpowiedzialny za pobranie obrazów z usługi Supabase Storage, co odciąża API.

## 8. Etapy wdrożenia

1.  **Baza danych**: Zdefiniować i wdrożyć politykę RLS dla tabeli `tool_images`, która ogranicza dostęp do odczytu zgodnie z logiką autoryzacji (status `active` lub własność).
2.  **Serwis**:
    - W `src/lib/services/tools.service.ts` utworzyć nową metodę asynchroniczną `getToolImagesForTool(toolId: string, currentUserId?: string): Promise<ToolImageDTO[]>`.
    - Zaimplementować w niej logikę pobierania narzędzia, weryfikacji uprawnień (status lub własność) oraz pobierania posortowanej listy obrazów.
    - Dodać obsługę błędów, rzucając niestandardowe wyjątki (np. `NotFoundError`, `ForbiddenError`).
3.  **API Route**:
    - Utworzyć nowy plik `src/pages/api/tools/[id]/images.ts`.
    - Dodać `export const prerender = false;`.
    - Zaimplementować handler `GET({ params, locals })`.
    - Dodać walidację `params.id` za pomocą `zod`.
    - Wywołać metodę z `ToolsService` i przekazać jej `id` oraz ID zalogowanego użytkownika.
    - Zaimplementować blok `try...catch` do obsługi błędów z warstwy serwisowej i mapowania ich na odpowiednie odpowiedzi `Response` z kodami statusu.
    - W przypadku sukcesu, zwrócić dane jako JSON z kodem `200 OK`.
4.  **Testy**: Dodać testy (jeśli dotyczy) weryfikujące poprawność działania endpointu w różnych scenariuszach:
    - Dostęp publiczny do aktywnego narzędzia.
    - Dostęp właściciela do narzędzia w stanie `draft`.
    - Odmowa dostępu dla niezalogowanego użytkownika do narzędzia w stanie `draft`.
    - Odmowa dostępu dla zalogowanego użytkownika (nie-właściciela) do narzędzia w stanie `draft`.
    - Poprawna obsługa nieistniejącego `id` (404).
    - Poprawna obsługa niepoprawnego `id` (400).

