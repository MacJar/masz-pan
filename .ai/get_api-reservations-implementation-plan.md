# API Endpoint Implementation Plan: GET /api/reservations

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia uwierzytelnionym użytkownikom pobieranie listy ich rezerwacji. Użytkownik musi określić, czy chce wyświetlić rezerwacje jako właściciel narzędzia (`owner`) czy jako pożyczający (`borrower`). Endpoint wspiera filtrowanie po statusie oraz paginację kursorową w celu efektywnego przeglądania wyników.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `GET`
-   **Struktura URL:** `/api/reservations`
-   **Parametry (Query String):**
    -   **Wymagane:**
        -   `role` (string): Określa rolę użytkownika. Musi przyjmować jedną z wartości: `owner` lub `borrower`.
    -   **Opcjonalne:**
        -   `status` (string | string[]): Filtruje wyniki po jednym lub wielu statusach rezerwacji. Dopuszczalne wartości to `requested`, `owner_accepted`, `borrower_confirmed`, `picked_up`, `returned`, `cancelled`, `rejected`.
        -   `limit` (number): Liczba wyników na stronę. Domyślnie `20`, maksymalnie `50`.
        -   `cursor` (string): Nieprzezroczysty ciąg znaków (opaque string) otrzymany z pola `next_cursor` poprzedniej odpowiedzi, używany do paginacji.
-   **Request Body:** Brak

## 3. Wykorzystywane typy

-   **`GetReservationsQuerySchema` (Zod Schema - do stworzenia):**
    Schemat do walidacji i parsowania parametrów zapytania.
    ```typescript
    import { z } from "zod";

    const ReservationStatusEnum = z.enum(['requested', 'owner_accepted', 'borrower_confirmed', 'picked_up', 'returned', 'cancelled', 'rejected']);

    export const GetReservationsQuerySchema = z.object({
      role: z.enum(["owner", "borrower"]),
      status: z.union([ReservationStatusEnum, z.array(ReservationStatusEnum)]).optional(),
      limit: z.coerce.number().int().min(1).max(50).optional().default(20),
      cursor: z.string().optional(),
    });
    ```
-   **`ReservationListItemDTO` (istniejący w `src/types.ts`):**
    Obiekt transferu danych dla pojedynczej rezerwacji w liście.
    ```typescript
    export type ReservationListItemDTO = Pick<ReservationDTO, "id" | "status">;
    ```
-   **`ReservationListPageDTO` (istniejący w `src/types.ts`):**
    Obiekt transferu danych dla całej odpowiedzi, zawierający listę rezerwacji i kursor.
    ```typescript
    export type ReservationListPageDTO = CursorPage<ReservationListItemDTO>;
    ```

## 4. Szczegóły odpowiedzi

-   **Struktura odpowiedzi sukcesu (200 OK):**
    ```json
    {
      "items": [
        {
          "id": "c3e3e3e3-3e3e-3e3e-3e3e-3e3e3e3e3e3e",
          "status": "requested"
        },
        {
          "id": "a1b2c3d4-e5f6-a7b8-c9d0-e1f2a3b4c5d6",
          "status": "owner_accepted"
        }
      ],
      "next_cursor": "eyJjcmVhdGVkX2F0IjoiMjAyNS0xMS0xNFQxMDowMDowMFoiLCJpZCI6ImExYjJjM2Q0LWU1ZjYtYTdiOC1jOWQwLWUxZjJhM2I0YzVkNiJ9"
    }
    ```
-   **Kody stanu:**
    -   `200 OK`: Zapytanie zakończone sukcesem.
    -   `400 Bad Request`: Błędne lub brakujące parametry zapytania.
    -   `401 Unauthorized`: Użytkownik nie jest uwierzytelniony.
    -   `500 Internal Server Error`: Wewnętrzny błąd serwera.

## 5. Przepływ danych

1.  Żądanie `GET` trafia do handlera API w `src/pages/api/reservations/index.ts`.
2.  Middleware Astro weryfikuje sesję użytkownika. Jeśli sesja jest nieprawidłowa, zwraca `401 Unauthorized`.
3.  Handler API używa `GetReservationsQuerySchema` (Zod) do walidacji i parsowania parametrów z `Astro.request.url`. W przypadku błędu walidacji zwraca `400 Bad Request`.
4.  Handler wywołuje funkcję serwisową, np. `reservationsService.listUserReservations`, przekazując `userId` z sesji oraz zwalidowane parametry.
5.  Funkcja serwisowa (`listUserReservations` w `src/lib/services/reservations.service.ts`):
    a.  Dekoduje `cursor`, jeśli został podany, aby uzyskać wartości (`created_at`, `id`) do paginacji.
    b.  Konstruuje zapytanie do Supabase (tabela `reservations`).
    c.  Dynamicznie dodaje warunek `WHERE` w zależności od parametru `role`:
        -   Jeśli `role` to `owner`, dodaje `eq('owner_id', userId)`.
        -   Jeśli `role` to `borrower`, dodaje `eq('borrower_id', userId)`.
    d.  Jeśli podano `status`, dodaje warunek `in('status', statusArray)`.
    e.  Implementuje logikę paginacji kursorowej (keyset pagination) używając `created_at` jako głównego klucza sortowania i `id` jako tie-breakera, aby zapewnić stabilne sortowanie.
    f.  Pobiera o jeden element więcej niż `limit`, aby sprawdzić, czy istnieje następna strona.
    g.  Jeśli istnieje następna strona, generuje nowy, zakodowany w Base64 `next_cursor` z ostatniego elementu pobranego w ramach limitu.
    h.  Zwraca listę rezerwacji (bez dodatkowego elementu) oraz `next_cursor`.
6.  Handler API otrzymuje dane z serwisu i formatuje odpowiedź `ReservationListPageDTO`.
7.  Odpowiedź JSON jest wysyłana do klienta ze statusem `200 OK`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint musi być chroniony i dostępny tylko dla zalogowanych użytkowników. Middleware Astro (`src/middleware/index.ts`) jest odpowiedzialne za weryfikację sesji i przekazanie danych użytkownika w `context.locals`.
-   **Autoryzacja:** Absolutnie kluczowe jest filtrowanie zapytań do bazy danych po ID zalogowanego użytkownika. Zapytanie musi zawsze zawierać warunek `owner_id = :userId` lub `borrower_id = :userId`, aby zapobiec dostępowi do rezerwacji nienależących do użytkownika.
-   **Walidacja danych wejściowych:** Wszystkie parametry wejściowe z query string muszą być rygorystycznie walidowane za pomocą Zod, aby zapobiec błędom i potencjalnym atakom (np. SQL Injection, chociaż Supabase ORM w dużym stopniu przed tym chroni).

## 7. Obsługa błędów

-   **Błędy walidacji (400):** Jeśli walidacja parametrów query za pomocą Zod nie powiedzie się, API zwróci odpowiedź z kodem `400 Bad Request` i szczegółami błędu.
    ```json
    {
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid query parameters",
        "details": [ /* ... Zod error issues ... */ ]
      }
    }
    ```
-   **Brak uwierzytelnienia (401):** Middleware zwróci `401 Unauthorized`, jeśli użytkownik nie jest zalogowany.
-   **Błędy serwera (500):** W przypadku problemów z połączeniem z bazą danych lub innych nieoczekiwanych wyjątków, API zwróci `500 Internal Server Error`. Błąd powinien zostać zalogowany po stronie serwera w celu dalszej diagnostyki.
    ```json
    {
      "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "An unexpected error occurred."
      }
    }
    ```

## 8. Rozważania dotyczące wydajności

-   **Indeksy w bazie danych:** Należy upewnić się, że istnieją indeksy na kolumnach `owner_id`, `borrower_id`, `status` oraz `created_at` w tabeli `reservations`, aby zapewnić wysoką wydajność zapytań.
    -   Zalecany indeks złożony: `(owner_id, created_at, id)`
    -   Zalecany indeks złożony: `(borrower_id, created_at, id)`
-   **Paginacja:** Użycie paginacji kursorowej jest kluczowe dla wydajności i skalowalności, ponieważ unika kosztownych operacji `OFFSET` na dużych zbiorach danych.
-   **Limit wyników:** Ograniczenie maksymalnej wartości `limit` do rozsądnej liczby (np. 50) zapobiega nadmiernemu obciążeniu serwera i bazy danych.

## 9. Etapy wdrożenia

1.  **Schemat walidacji:** Stworzyć `GetReservationsQuerySchema` używając Zod i umieścić go w istniejącym lub nowym pliku, np. `src/lib/schemas/reservation.schema.ts`.
2.  **Serwis:**
    -   Utworzyć plik `src/lib/services/reservations.service.ts`, jeśli nie istnieje.
    -   Zaimplementować funkcję `listUserReservations(userId: string, query: z.infer<typeof GetReservationsQuerySchema>)`.
    -   Wewnątrz serwisu zaimplementować logikę budowania zapytania do Supabase, w tym filtrowanie, sortowanie i paginację kursorową.
    -   Dodać obsługę enkodowania/dekodowania kursora (np. `btoa`/`atob` na stringu JSON).
3.  **Handler API:**
    -   Utworzyć plik `src/pages/api/reservations/index.ts`.
    -   Dodać `export const prerender = false;`.
    -   Zaimplementować handler `GET({ locals, request })`.
    -   Sprawdzić, czy `locals.session` istnieje; jeśli nie, zwrócić `401`.
    -   Sparować i zwalidować parametry zapytania przy użyciu `GetReservationsQuerySchema`. W przypadku błędu zwrócić `400`.
    -   Wywołać serwis `reservationsService.listUserReservations`.
    -   Obsłużyć potencjalne błędy z serwisu i zwrócić `500`.
    -   Sformatować pomyślną odpowiedź jako `Response.json()` i zwrócić `200`.
4.  **Typy:** Zweryfikować, czy istniejące typy `ReservationListItemDTO` i `ReservationListPageDTO` w `src/types.ts` są wystarczające. Jeśli nie, zaktualizować je.
5.  **Testowanie:** Przygotować scenariusze testowe, uwzględniając:
    -   Poprawne działanie dla roli `owner` i `borrower`.
    -   Filtrowanie po jednym i wielu statusach.
    -   Paginację (pobranie pierwszej strony, następnie drugiej przy użyciu `next_cursor`).
    -   Przypadki brzegowe: brak rezerwacji, ostatnia strona wyników (`next_cursor: null`).
    -   Obsługę błędów dla niepoprawnych parametrów i braku uwierzytelnienia.
