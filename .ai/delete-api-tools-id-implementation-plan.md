# API Endpoint Implementation Plan: Archiwizacja Narzędzia

## 1. Przegląd punktu końcowego

Ten punkt końcowy obsługuje miękkie usuwanie (archiwizację) narzędzia. Zamiast fizycznie usuwać dane, zmienia status narzędzia na `archived` i zapisuje datę archiwizacji. Operacja jest dostępna tylko dla właściciela narzędzia i jest blokowana, jeśli istnieją aktywne rezerwacje.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `DELETE`
-   **Struktura URL:** `/api/tools/:id`
-   **Parametry:**
    -   **Wymagane:**
        -   `id` (w ścieżce): UUID narzędzia do zarchiwizowania.
-   **Request Body:** Brak.

## 3. Wykorzystywane typy

-   **Odpowiedź (DTO):**
    ```typescript
    // src/types.ts
    export interface ToolArchivedResponseDto {
      archived: true;
      archivedAt: string; // Data w formacie ISO 8601
    }
    ```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (200 OK):**
    ```json
    {
      "archived": true,
      "archivedAt": "2025-11-12T10:00:00.000Z"
    }
    ```
-   **Odpowiedzi błędów:**
    -   `400 Bad Request`: Gdy `id` nie jest poprawnym UUID.
    -   `401 Unauthorized`: Gdy użytkownik nie jest zalogowany.
    -   `403 Forbidden`: Gdy użytkownik próbuje zarchiwizować nie swoje narzędzie.
    -   `404 Not Found`: Gdy narzędzie o podanym `id` nie istnieje.
    -   `409 Conflict`: Gdy narzędzie ma aktywne rezerwacje.
    -   `500 Internal Server Error`: W przypadku nieoczekiwanego błędu serwera.

## 5. Przepływ danych

1.  Klient wysyła żądanie `DELETE` na adres `/api/tools/:id`.
2.  Middleware Astro weryfikuje sesję użytkownika Supabase.
3.  Handler API w `src/pages/api/tools/[id].ts` odbiera żądanie.
4.  Handler waliduje parametr `:id` przy użyciu `zod`, sprawdzając, czy jest to poprawny UUID.
5.  Handler wywołuje funkcję `archiveTool(id, userId)` z serwisu `ToolsService` (`src/lib/services/tools.service.ts`).
6.  `ToolsService`:
    a.  Pobiera narzędzie z bazy danych na podstawie `id`. Jeśli nie istnieje, rzuca `ToolNotFoundError`.
    b.  Sprawdza, czy `tool.owner_id` jest zgodne z `userId` przekazanym do funkcji. Jeśli nie, rzuca `ForbiddenError`.
    c.  Sprawdza w tabeli `reservations`, czy istnieją rezerwacje dla danego `tool_id` ze statusami aktywnymi (np. `requested`, `owner_accepted`, `borrower_confirmed`, `picked_up`). Jeśli tak, rzuca `ToolHasActiveReservationsError`.
    d.  Aktualizuje rekord narzędzia w tabeli `tools`, ustawiając `status = 'archived'` i `archived_at = now()`.
    e.  Zapisuje zdarzenie w tabeli `audit_log` (`event_type: 'tool_archived'`).
    f.  Zwraca datę archiwizacji.
7.  Handler API formatuje pomyślną odpowiedź (status 200) lub przechwytuje błędy z serwisu i mapuje je na odpowiednie kody statusu HTTP (403, 404, 409).
8.  Odpowiedź JSON jest zwracana do klienta.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint musi być chroniony. Handler API sprawdzi istnienie aktywnej sesji użytkownika w `context.locals.session`. W przypadku braku sesji zwróci status `401 Unauthorized`.
-   **Autoryzacja:** Logika w `ToolsService` musi bezwzględnie weryfikować, czy zalogowany użytkownik jest właścicielem narzędzia (`tools.owner_id`). Próba archiwizacji cudzego narzędzia musi zwrócić `403 Forbidden`.
-   **Walidacja danych wejściowych:** Parametr `id` musi być walidowany jako UUID, aby zapobiec błędom zapytań SQL i potencjalnym atakom.

## 7. Rozważania dotyczące wydajności

-   Zapytanie sprawdzające aktywne rezerwacje powinno być zoptymalizowane. Należy upewnić się, że istnieje indeks na kolumnie `reservations.tool_id` oraz `reservations.status`.
-   Operacje na bazie danych (odczyt, sprawdzenie rezerwacji, aktualizacja) powinny być wykonane w ramach jednej transakcji, aby zapewnić spójność danych.

## 8. Etapy wdrożenia

1.  **Aktualizacja Serwisu (`src/lib/services/tools.service.ts`):**
    -   Zdefiniuj nowe, niestandardowe typy błędów w `src/lib/services/errors.service.ts`: `ToolHasActiveReservationsError`.
    -   Dodaj nową metodę `archiveTool(toolId: string, userId: string): Promise<{ archivedAt: Date }>` do klasy `ToolsService`.
    -   Zaimplementuj wewnątrz metody logikę opisaną w sekcji "Przepływ danych", włączając w to sprawdzanie właściciela i aktywnych rezerwacji.
    -   Użyj transakcji Supabase (`supabase.rpc('function_with_transaction', ...)` lub zarządzaj nią manualnie po stronie serwisu), aby zapewnić atomowość operacji aktualizacji narzędzia i zapisu do `audit_log`.

2.  **Implementacja Handlera API (`src/pages/api/tools/[id].ts`):**
    -   Utwórz (jeśli nie istnieje) lub zaktualizuj plik, aby zawierał handler dla metody `DELETE`.
    -   Dodaj `export const prerender = false;`
    -   Pobierz sesję użytkownika z `context.locals.session`. Jeśli brak, zwróć 401.
    -   Zwaliduj `context.params.id` przy użyciu `zod.string().uuid()`. Jeśli błąd, zwróć 400.
    -   Wywołaj `toolsService.archiveTool()` w bloku `try...catch`.
    -   W bloku `catch` obsłuż specyficzne błędy (`ToolNotFoundError`, `ForbiddenError`, `ToolHasActiveReservationsError`) i zwróć odpowiednie kody statusu (404, 403, 409).
    -   W przypadku pomyślnego wykonania, zwróć obiekt `ToolArchivedResponseDto` ze statusem 200.

3.  **Aktualizacja Typów (`src/types.ts`):**
    -   Dodaj definicję typu `ToolArchivedResponseDto`, jeśli jest potrzebna w warstwie klienta.

4.  **Testowanie:**
    -   Napisz testy jednostkowe dla logiki w `ToolsService`.
    -   Przeprowadź testy integracyjne dla endpointu API, symulując różne scenariusze:
        -   Pomyślna archiwizacja.
        -   Próba archiwizacji bez logowania (oczekiwany 401).
        -   Próba archiwizacji nie swojego narzędzia (oczekiwany 403).
        -   Próba archiwizacji narzędzia z aktywną rezerwacją (oczekiwany 409).
        -   Próba archiwizacji nieistniejącego narzędzia (oczekiwany 404).
        -   Próba archiwizacji z niepoprawnym UUID (oczekiwany 400).
