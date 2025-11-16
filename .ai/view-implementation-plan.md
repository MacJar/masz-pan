# API Endpoint Implementation Plan: GET /api/tools/:id

## 1. Przegląd punktu końcowego
Ten punkt końcowy służy do pobierania szczegółowych informacji o konkretnym narzędziu na podstawie jego unikalnego identyfikatora (UUID). Odpowiedź zawiera pełne dane narzędzia oraz listę powiązanych z nim zdjęć, posortowaną według ich pozycji. Dostęp do zasobu jest warunkowy: narzędzia o statusie `active` są publicznie dostępne, natomiast narzędzia w innych statusach (np. `draft`, `inactive`) mogą być odczytane wyłącznie przez ich właściciela.

## 2. Szczegóły żądania
- **Metoda HTTP:** `GET`
- **Struktura URL:** `/api/tools/[id]`
- **Parametry:**
  - **Wymagane:**
    - `id` (parametr ścieżki): Unikalny identyfikator narzędzia w formacie UUID.
  - **Opcjonalne:** Brak.
- **Request Body:** Brak.

## 3. Wykorzystywane typy
- `ToolWithImagesDTO`: Główny obiekt transferu danych (DTO) w odpowiedzi, zawierający dane narzędzia i zagnieżdżoną listę zdjęć.
- `ToolDTO`: Reprezentuje dane narzędzia (bez pól wewnętrznych jak `search_name_tsv`).
- `ToolImageDTO`: Reprezentuje dane pojedynczego zdjęcia narzędzia.

## 4. Szczegóły odpowiedzi
- **Sukces (200 OK):**
  ```json
  {
    "id": "c3e4a5f6-b789-12d3-e456-426614174000",
    "owner_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "name": "Wiertarka udarowa",
    "description": "Mocna wiertarka do betonu i metalu.",
    "suggested_price_tokens": 3,
    "status": "active",
    "created_at": "2025-11-10T10:00:00Z",
    "updated_at": "2025-11-10T10:00:00Z",
    "archived_at": null,
    "images": [
      {
        "id": "f1e2d3c4-b5a6-7890-12d3-e45642661417",
        "tool_id": "c3e4a5f6-b789-12d3-e456-426614174000",
        "storage_key": "public/tools/c3e4a5f6.../image1.webp",
        "position": 0,
        "created_at": "2025-11-10T10:01:00Z"
      }
    ]
  }
  ```
- **Błędy:**
  - `400 Bad Request`: Gdy `id` nie jest prawidłowym UUID.
  - `404 Not Found`: Gdy narzędzie o podanym `id` nie istnieje lub użytkownik nie ma uprawnień do jego wyświetlenia.
  - `500 Internal Server Error`: W przypadku nieoczekiwanych błędów serwera.

## 5. Przepływ danych
1.  Klient wysyła żądanie `GET` na adres `/api/tools/[id]`.
2.  Router Astro kieruje żądanie do handlera w pliku `src/pages/api/tools/[id].ts`.
3.  Handler API waliduje parametr `id` przy użyciu schematu Zod, sprawdzając, czy jest to prawidłowy UUID.
4.  Jeśli walidacja się powiedzie, handler wywołuje metodę `findToolWithImagesById(id)` z serwisu `ToolsService`.
5.  `ToolsService` wykonuje pojedyncze zapytanie do bazy danych Supabase, aby pobrać rekord z tabeli `tools` i jednocześnie dołączyć (`JOIN`) powiązane rekordy z tabeli `tool_images`.
6.  Zapytanie jest chronione przez politykę RLS (Row-Level Security) na tabeli `tools`, która zezwala na dostęp, jeśli `status = 'active'` LUB `owner_id = auth.uid()`.
7.  Jeśli zapytanie zwróci dane, `ToolsService` mapuje wynik na DTO `ToolWithImagesDTO` i zwraca go do handlera. Zdjęcia są sortowane rosnąco według pola `position`.
8.  Jeśli zapytanie nie zwróci danych (z powodu braku rekordu lub blokady RLS), serwis zwraca `null` lub rzuca błąd "Not Found".
9.  Handler API odbiera wynik z serwisu i w zależności od niego:
    - Wysyła odpowiedź `200 OK` z obiektem `ToolWithImagesDTO`.
    - Wysyła odpowiedź `404 Not Found`.
10. W przypadku błędu walidacji lub błędu serwera, handler wysyła odpowiednio `400 Bad Request` lub `500 Internal Server Error`.

## 6. Względy bezpieczeństwa
- **Autoryzacja:** Dostęp do zasobu jest w pełni kontrolowany przez polityki RLS w bazie danych PostgreSQL. Aplikacja polega na bazie w kwestii egzekwowania reguł dostępu, co jest bezpiecznym i zalecanym podejściem w architekturze Supabase.
- **Walidacja danych wejściowych:** Parametr `id` jest ściśle walidowany jako UUID, co zapobiega błędom zapytań i potencjalnym atakom (np. próbom odgadnięcia ścieżek).
- **Ujawnianie informacji:** Zastosowanie `404 Not Found` zarówno w przypadku braku zasobu, jak i braku uprawnień, zapobiega możliwości wyliczenia (enumeration) istniejących, ale niedostępnych zasobów.

## 7. Rozważania dotyczące wydajności
- **Zapytanie do bazy danych:** Użycie jednego zapytania z `JOIN` (realizowanego przez Supabase jako `select('*, tool_images(*)')`) jest wysoce wydajne i minimalizuje opóźnienie (latency) związane z komunikacją z bazą danych.
- **Indeksowanie:** Klucz główny `tools.id` oraz klucz obcy `tool_images.tool_id` są domyślnie indeksowane, co zapewnia szybkie wyszukiwanie i łączenie tabel.
- **Rozmiar odpowiedzi:** Rozmiar odpowiedzi jest zazwyczaj mały. W przyszłości, w przypadku bardzo dużej liczby zdjęć, można rozważyć paginację, ale dla MVP nie jest to konieczne.

## 8. Etapy wdrożenia
1.  **Utworzenie pliku endpointu:** Stworzyć plik `src/pages/api/tools/[id].ts`.
2.  **Implementacja handlera `GET`:** W nowym pliku zaimplementować `export const GET: APIRoute = async ({ params, locals }) => { ... }`.
3.  **Walidacja parametru:** W handlerze zaimplementować walidację `params.id` za pomocą Zod (`z.string().uuid()`). W przypadku błędu zwrócić odpowiedź `400`.
4.  **Aktualizacja serwisu `ToolsService`:** W pliku `src/lib/services/tools.service.ts` dodać nową, asynchroniczną metodę publiczną `findToolWithImagesById(toolId: string)`.
5.  **Implementacja zapytania w serwisie:** Wewnątrz nowej metody użyć klienta Supabase do wykonania zapytania:
    ```typescript
    const { data, error } = await this.supabase
      .from("tools")
      .select("*, tool_images(*)")
      .eq("id", toolId)
      .order("position", { foreignTable: "tool_images", ascending: true })
      .single();
    ```
6.  **Obsługa wyniku w serwisie:** Sprawdzić `error` i `data`. Jeśli `data` jest `null`, zwrócić `null`, co oznacza brak zasobu lub uprawnień.
7.  **Integracja z handlerem API:** W handlerze `GET` wywołać nową metodę serwisu.
8.  **Obsługa odpowiedzi:**
    - Jeśli serwis zwróci obiekt narzędzia, zwrócić odpowiedź `200 OK` z `JsonResponse(tool)`.
    - Jeśli serwis zwróci `null`, zwrócić odpowiedź `404 Not Found` z odpowiednim komunikatem błędu.
    - Całość opakować w blok `try...catch` do obsługi nieoczekiwanych błędów i zwrócenia `500 Internal Server Error`.
9.  **Weryfikacja RLS:** Upewnić się, że polityka RLS dla odczytu w tabeli `tools` jest poprawnie zdefiniowana w migracji SQL:
    ```sql
    CREATE POLICY "Enable read access for active tools and owners"
    ON tools FOR SELECT USING (
      status = 'active' OR owner_id = auth.uid()
    );
    ```


