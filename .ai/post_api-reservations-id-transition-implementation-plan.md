# API Endpoint Implementation Plan: POST /api/reservations/:id/transition

## 1. Przegląd punktu końcowego

Ten punkt końcowy jest odpowiedzialny za zarządzanie cyklem życia rezerwacji poprzez zmianę jej statusu. Każda zmiana statusu jest realizowana jako oddzielne żądanie POST, co pozwala na hermetyzację logiki biznesowej i walidacji dla każdego przejścia w maszynie stanów. Logika ta jest egzekwowana przez dedykowaną funkcję w bazie danych (`reservation_transition`), a API pełni rolę bezpiecznej bramy walidującej i autoryzującej żądania.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `POST`
-   **Struktura URL:** `/api/reservations/{id}/transition`
-   **Parametry:**
    -   **Ścieżki (Path):**
        -   `id` (string, UUID): Unikalny identyfikator rezerwacji. **Wymagane**.
    -   **Ciała (Body):**
        -   `new_status` (string): Nowy status rezerwacji. Musi być jedną z wartości: `owner_accepted`, `borrower_confirmed`, `picked_up`, `returned`, `cancelled`, `rejected`. **Wymagane**.
        -   `price_tokens` (number): Uzgodniona cena za wypożyczenie. **Wymagane tylko wtedy, gdy `new_status` to `owner_accepted`**.
-   **Przykładowe ciało żądania (Request Body):**

    ```json
    // Przykład dla akceptacji przez właściciela
    {
      "new_status": "owner_accepted",
      "price_tokens": 5
    }

    // Przykład dla potwierdzenia odbioru
    {
      "new_status": "picked_up"
    }
    ```

## 3. Wykorzystywane typy

-   **`ReservationStatus` (z `database.types.ts`):** Typ enum generowany przez Supabase, zawierający wszystkie możliwe statusy rezerwacji.
-   **`ReservationTransitionCommandSchema` (nowy schemat Zod):**
    -   Obiekt walidujący ciało żądania.
    -   `new_status`: `z.enum([...])` z dopuszczalnymi statusami przejść.
    -   `price_tokens`: `z.number().int().positive().optional()`
    -   Użycie `.refine()` do zapewnienia, że `price_tokens` jest zdefiniowane, gdy `new_status` jest równe `owner_accepted`.
-   **`ReservationTransitionResponseDto` (nowy typ TS):**
    -   `reservation`: Pełny, zaktualizowany obiekt rezerwacji.
    -   `ledger_effects`: Opcjonalny obiekt podsumowujący operacje na tokenach (np. `hold_created`, `transfer_executed`).

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (200 OK):** Zwraca obiekt zawierający zaktualizowaną rezerwację.

    ```json
    {
      "reservation": {
        "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
        "tool_id": "...",
        "owner_id": "...",
        "borrower_id": "...",
        "status": "owner_accepted",
        "agreed_price_tokens": 5,
        "created_at": "...",
        "updated_at": "..."
      }
    }
    ```

-   **Odpowiedzi błędów:** Zobacz sekcję "Obsługa błędów".

## 5. Przepływ danych

1.  Użytkownik (właściciel lub wypożyczający) inicjuje akcję w interfejsie użytkownika (np. klika "Akceptuj rezerwację").
2.  Frontend wysyła żądanie `POST` na adres `/api/reservations/{id}/transition` z odpowiednim ciałem.
3.  Middleware Astro weryfikuje sesję użytkownika. Jeśli sesja jest nieprawidłowa, zwraca `401 Unauthorized`.
4.  Handler API w `src/pages/api/reservations/[id]/transition.ts` jest wywoływany.
5.  Handler parsuje i waliduje parametr `id` (musi być UUID) oraz ciało żądania za pomocą `ReservationTransitionCommandSchema`. W przypadku błędu zwraca `400 Bad Request`.
6.  Handler wywołuje metodę `reservationsService.transitionReservationState()` przekazując ID rezerwacji, dane z ciała żądania oraz ID zalogowanego użytkownika (aktora).
7.  `ReservationsService`:
    a. Pobiera rezerwację z bazy danych na podstawie `id`. Jeśli nie istnieje, zwraca błąd `NotFound`.
    b. **Autoryzuje** użytkownika. Sprawdza, czy ID aktora jest równe `owner_id` lub `borrower_id` i czy ma on uprawnienia do wykonania danego przejścia w aktualnym stanie rezerwacji. W przypadku braku uprawnień, zwraca błąd `Forbidden`.
    c. Wywołuje funkcję RPC w Supabase: `supabase.rpc('reservation_transition', { reservation_id: id, new_status: '...', price_tokens: ... })`.
    d. Przechwytuje błędy z RPC. Błędy PostgREST (np. naruszenie `CHECK` lub `RAISE EXCEPTION` w funkcji) są mapowane na odpowiednie błędy HTTP (`409 Conflict`, `422 Unprocessable Entity`).
    e. Jeśli RPC zakończy się sukcesem, pobiera zaktualizowany stan rezerwacji.
8.  Serwis zwraca zaktualizowaną rezerwację do handlera API.
9.  Handler API formatuje odpowiedź i wysyła ją do klienta ze statusem `200 OK`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Dostęp do endpointu jest chroniony przez middleware Astro, które weryfikuje token JWT użytkownika i dołącza sesję do `context.locals`. Żądania bez ważnej sesji są odrzucane.
-   **Autoryzacja:** To kluczowy aspekt. Logika w `ReservationsService` musi bezwzględnie weryfikować, czy zalogowany użytkownik jest stroną w danej rezerwacji (`owner_id` lub `borrower_id`) i czy jego rola pozwala na wykonanie żądanej zmiany stanu. Należy stworzyć mapę uprawnień (kto może wykonać jakie przejście w jakim stanie).
-   **Walidacja danych wejściowych:** Użycie Zod (`ReservationTransitionCommandSchema`) chroni przed niepoprawnymi lub złośliwymi danymi wejściowymi. Walidowany jest zarówno typ, format, jak i logika warunkowa.

## 7. Obsługa błędów

Endpoint będzie zwracał następujące kody statusu w przypadku błędów:
-   `400 Bad Request`: Błąd walidacji Zod (np. brak wymaganego pola, zły typ danych, `price_tokens` wymagane, ale niepodane) lub nieprawidłowy format UUID.
-   `401 Unauthorized`: Użytkownik nie jest zalogowany.
-   `403 Forbidden`: Użytkownik jest zalogowany, ale nie jest uprawniony do modyfikacji tej rezerwacji (nie jest właścicielem ani wypożyczającym).
-   `404 Not Found`: Rezerwacja o podanym `id` nie została znaleziona.
-   `409 Conflict`: Żądane przejście stanu jest niemożliwe z obecnego stanu rezerwacji (np. próba akceptacji rezerwacji, która została już anulowana).
-   `422 Unprocessable Entity`: Błąd logiki biznesowej po stronie bazy danych, np. niewystarczająca liczba tokenów na koncie wypożyczającego.
-   `500 Internal Server Error`: Ogólny błąd serwera, np. problem z połączeniem z bazą danych.

## 8. Etapy wdrożenia

1.  **Schematy i Typy:**
    -   Zdefiniować schemat `ReservationTransitionCommandSchema` w pliku `src/lib/schemas/reservation.schema.ts`.
    -   Zdefiniować typ `ReservationTransitionResponseDto` w pliku `src/types.ts`.
2.  **Warstwa serwisowa (`src/lib/services/reservations.service.ts`):**
    -   Stworzyć lub rozszerzyć `ReservationsService`.
    -   Zaimplementować metodę `transitionReservationState(command: { reservationId: string, newStatus: ReservationStatus, priceTokens?: number, actorId: string })`.
    -   Wewnątrz metody zaimplementować pobieranie rezerwacji, logikę autoryzacji oraz wywołanie `supabase.rpc('reservation_transition', ...)` z obsługą błędów.
3.  **Warstwa API (`src/pages/api/reservations/[id]/transition.ts`):**
    -   Stworzyć nowy plik dla endpointu.
    -   Dodać `export const prerender = false;`.
    -   Zaimplementować handler `POST({ params, request, locals })`.
    -   Dodać logikę walidacji `params.id` oraz `request.body` przy użyciu Zod.
    -   Wywołać serwis `reservationsService.transitionReservationState`.
    -   Obsłużyć potencjalne błędy rzucane przez serwis i zmapować je na odpowiednie odpowiedzi `Response` z kodami statusu.
    -   Zwrócić `Response.json(...)` z poprawną odpowiedzią w przypadku sukcesu.


