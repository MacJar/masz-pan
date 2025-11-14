# API Endpoint Implementation Plan: POST /api/ratings

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia uwierzytelnionym użytkownikom tworzenie oceny (w skali 1-5 gwiazdek) dla zakończonej rezerwacji. Ocena może być dodana tylko wtedy, gdy rezerwacja ma status `returned`, a oceniający jest jedną ze stron transakcji (właścicielem lub wypożyczającym).

## 2. Szczegóły żądania

-   **Metoda HTTP**: `POST`
-   **Struktura URL**: `/api/ratings`
-   **Nagłówki**:
    -   `Content-Type: application/json`
    -   `Authorization: Bearer <SESSION_TOKEN>`
-   **Ciało żądania**:
    ```json
    {
      "reservation_id": "string (uuid)",
      "stars": "number (integer)"
    }
    ```
-   **Parametry**:
    -   **Wymagane**:
        -   `reservation_id`: `string` - Unikalny identyfikator rezerwacji.
        -   `stars`: `number` - Ocena w skali od 1 do 5.

## 3. Wykorzystywane typy

-   **DTO (Data Transfer Object)**: `CreateRatingSchema` (Zod) do walidacji danych wejściowych.
-   **Model / Encja**: `Rating` z `src/db/database.types.ts` jako typ odpowiedzi.
-   **Command Model**: `CreateRatingCommand` `{ reservationId: string; stars: number; raterId: string; }` do przekazania do warstwy serwisowej.

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (201 Created)**:
    ```json
    {
      "id": "string (uuid)",
      "reservation_id": "string (uuid)",
      "rater_id": "string (uuid)",
      "rated_user_id": "string (uuid)",
      "stars": 5,
      "created_at": "string (timestamptz)"
    }
    ```
-   **Odpowiedzi błędów**: Szczegółowe kody stanu i komunikaty opisane w sekcji "Obsługa błędów".

## 5. Przepływ danych

1.  Klient wysyła żądanie `POST` na `/api/ratings` z tokenem sesji i danymi oceny.
2.  Middleware Astro weryfikuje token i uwierzytelnia użytkownika, udostępniając jego sesję w `context.locals`.
3.  Handler API w `src/pages/api/ratings.ts` jest wywoływany.
4.  Ciało żądania jest parsowane i walidowane przy użyciu schematu Zod `CreateRatingSchema`.
5.  Handler wywołuje funkcję `RatingsService.createRating`, przekazując zwalidowane dane oraz ID oceniającego (`raterId`) z sesji.
6.  `RatingsService` wykonuje logikę biznesową:
    a. Pobiera rezerwację z bazy danych na podstawie `reservation_id`.
    b. Weryfikuje, czy rezerwacja istnieje, jej status to `returned` i czy `raterId` jest jej uczestnikiem.
    c. Sprawdza, czy użytkownik nie dodał już oceny dla tej rezerwacji.
    d. Ustala `rated_user_id` (druga strona transakcji).
    e. Wstawia nowy wiersz do tabeli `ratings` za pomocą klienta Supabase.
7.  Serwis zwraca nowo utworzony obiekt oceny.
8.  Handler API serializuje odpowiedź i wysyła ją do klienta ze statusem `201 Created`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie**: Dostęp do punktu końcowego jest ograniczony wyłącznie do uwierzytelnionych użytkowników. Middleware odrzuci wszystkie żądania bez ważnej sesji.
-   **Autoryzacja**: Warstwa serwisowa musi rygorystycznie sprawdzić, czy zalogowany użytkownik (`rater_id`) jest właścicielem (`owner_id`) lub wypożyczającym (`borrower_id`) w ramach danej rezerwacji. Próba oceny cudzej rezerwacji musi skutkować błędem `403 Forbidden`.
-   **Walidacja danych**: Użycie Zod do walidacji ciała żądania chroni przed nieprawidłowymi typami danych, wartościami spoza zakresu i potencjalnymi atakami. Supabase ORM zapobiega SQL Injection.
-   **Ochrona przed duplikatami**: Unikalny indeks `(reservation_id, rater_id)` w bazie danych oraz dodatkowa weryfikacja w serwisie zapewniają, że jeden użytkownik może ocenić daną rezerwację tylko raz.

## 7. Obsługa błędów

-   `400 Bad Request`: Zwracany, gdy ciało żądania jest nieprawidłowym JSON-em lub dane nie przechodzą walidacji Zod (np. `stars: 0`, `reservation_id` nie jest UUID).
-   `401 Unauthorized`: Zwracany, gdy żądanie nie zawiera ważnego tokena sesji.
-   `403 Forbidden`: Zwracany, gdy uwierzytelniony użytkownik próbuje ocenić rezerwację, w której nie brał udziału.
-   `404 Not Found`: Zwracany, gdy rezerwacja o podanym `reservation_id` nie istnieje.
-   `409 Conflict`: Zwracany, gdy użytkownik próbuje ponownie ocenić tę samą rezerwację.
-   `422 Unprocessable Entity`: Zwracany, gdy rezerwacja nie ma statusu `returned`.
-   `500 Internal Server Error`: Zwracany w przypadku nieoczekiwanych problemów z serwerem lub bazą danych. Błąd powinien być logowany.

## 8. Rozważania dotyczące wydajności

-   Operacje na bazie danych opierają się na indeksowanych kluczach głównych i obcych (`reservations.id`, `ratings.reservation_id`, `ratings.rater_id`), co zapewnia wysoką wydajność zapytań.
-   Punkt końcowy wykonuje jedno zapytanie `SELECT` i jedno `INSERT`, co minimalizuje obciążenie bazy danych.
-   Nie przewiduje się znaczących wąskich gardeł wydajnościowych.

## 9. Etapy wdrożenia

1.  **Definicja schematu walidacji**:
    -   Utwórz plik `src/lib/schemas/rating.schema.ts`.
    -   Zdefiniuj w nim `CreateRatingSchema` używając Zod do walidacji `reservation_id` i `stars`.

2.  **Implementacja warstwy serwisowej**:
    -   Utwórz nowy plik `src/lib/services/ratings.service.ts`.
    -   Zaimplementuj funkcję `createRating(command: CreateRatingCommand)`, która będzie zawierać całą logikę biznesową.
    -   Wykorzystaj istniejące niestandardowe klasy błędów (np. `ForbiddenError`, `NotFoundError` z `errors.service.ts`) do sygnalizowania konkretnych problemów.

3.  **Tworzenie typu w bazie danych**:
    -   Upewnij się, że typ `Rating` jest poprawnie zdefiniowany w `src/db/database.types.ts`. Jeśli go brakuje, wygeneruj go ponownie na podstawie schematu bazy danych.

4.  **Implementacja punktu końcowego API**:
    -   Utwórz plik `src/pages/api/ratings.ts`.
    -   Dodaj `export const prerender = false;`.
    -   Zaimplementuj handler `POST`.
    -   Pobierz sesję użytkownika z `context.locals.session`. Odrzuć żądanie ze statusem 401, jeśli sesja nie istnieje.
    -   Sparsuj i zwaliduj ciało żądania za pomocą `CreateRatingSchema`.
    -   Wywołaj `RatingsService.createRating` w bloku `try...catch`.
    -   Mapuj błędy rzucone przez serwis na odpowiednie odpowiedzi HTTP (np. `error instanceof NotFoundError` na status 404).
    -   W przypadku sukcesu, zwróć odpowiedź z kodem `201 Created`.
