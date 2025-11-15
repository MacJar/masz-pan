# API Endpoint Implementation Plan: POST /api/reservations/:id/cancel

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia autoryzowanemu użytkownikowi (właścicielowi narzędzia lub wypożyczającemu) anulowanie istniejącej rezerwacji. Operacja ta zmienia status rezerwacji na `cancelled`, zwalnia wszelkie tokeny zablokowane na poczet tej rezerwacji i rejestruje zdarzenie w logu audytowym.

## 2. Szczegóły żądania

-   **Metoda HTTP**: `POST`
-   **Struktura URL**: `/api/reservations/:id/cancel`
-   **Parametry**:
    -   **Wymagane**:
        -   `id` (w ścieżce URL): Identyfikator UUID rezerwacji do anulowania.
    -   **Opcjonalne**: Brak.
-   **Request Body**:
    -   **Format**: `application/json`
    -   **Struktura**:
        ```json
        {
          "cancelled_reason": "string"
        }
        ```
    -   **Opis**: Opcjonalne pole zawierające powód anulowania rezerwacji.

## 3. Wykorzystywane typy

-   **`CancelReservationSchema` (Zod Schema)**: Schemat do walidacji ciała żądania.
    ```typescript
    import { z } from 'zod';

    export const CancelReservationSchema = z.object({
      cancelled_reason: z.string().max(500, "Reason cannot be longer than 500 characters.").optional(),
    });
    ```
-   **`Reservation` (Entity/DTO)**: Typ obiektu rezerwacji zwracanego w odpowiedzi, zdefiniowany w `src/types.ts`.

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (`200 OK`)**:
    -   **Ciało odpowiedzi**: Zwraca pełny, zaktualizowany obiekt rezerwacji w formacie JSON.
        ```json
        {
          "id": "uuid",
          "tool_id": "uuid",
          "owner_id": "uuid",
          "borrower_id": "uuid",
          "status": "cancelled",
          "agreed_price_tokens": null,
          "cancelled_reason": "string | null",
          "created_at": "timestamp",
          "updated_at": "timestamp"
        }
        ```
-   **Odpowiedzi błędu**: Zobacz sekcję "Obsługa błędów".

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `POST` na adres `/api/reservations/:id/cancel`.
2.  Middleware Astro weryfikuje sesję użytkownika i udostępnia jego dane w `Astro.locals.user`. Jeśli użytkownik nie jest zalogowany, zwraca `401 Unauthorized`.
3.  Handler endpointu w `src/pages/api/reservations/[id]/cancel.ts` jest wywoływany.
4.  Handler parsuje `id` z parametrów URL oraz opcjonalne ciało żądania.
5.  Dane wejściowe są walidowane: `id` musi być typu UUID, a ciało żądania musi odpowiadać `CancelReservationSchema`. W przypadku błędu zwracany jest `422 Unprocessable Entity`.
6.  Handler wywołuje metodę `ReservationsService.cancelReservation(id, user.id, cancelled_reason)`.
7.  Metoda `cancelReservation` w serwisie wykonuje następujące kroki:
    a. Pobiera rezerwację z bazy danych na podstawie `id`. Jeśli nie istnieje, rzuca błąd (obsłużony jako `404 Not Found`).
    b. Sprawdza uprawnienia: weryfikuje, czy `user.id` jest równy `reservation.owner_id` lub `reservation.borrower_id`. Jeśli nie, rzuca błąd (obsłużony jako `403 Forbidden`).
    c. Weryfikuje stan rezerwacji: sprawdza, czy status rezerwacji pozwala na anulowanie (np. jest w stanie `requested`, `owner_accepted`, `borrower_confirmed`). Jeśli nie, rzuca błąd (obsłużony jako `409 Conflict`).
    d. Wywołuje funkcję RPC Supabase `reservation_transition` z parametrami: `reservation_id`, `new_status: 'cancelled'`, oraz `cancelled_reason`. Ta funkcja atomowo zmienia stan, zwalnia blokadę tokenów i tworzy wpis w `audit_log`.
    e. Pobiera i zwraca zaktualizowany obiekt rezerwacji.
8.  Handler endpointu odbiera zaktualizowaną rezerwację z serwisu i wysyła ją jako odpowiedź `200 OK` w formacie JSON.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie**: Dostęp do endpointu jest ograniczony do zalogowanych użytkowników poprzez middleware Astro, które sprawdza `Astro.locals.user`.
-   **Autoryzacja**: Kluczowym elementem jest weryfikacja w warstwie serwisowej, czy zalogowany użytkownik jest jedną ze stron rezerwacji (`owner_id` lub `borrower_id`). Zapobiega to anulowaniu rezerwacji przez nieuprawnione osoby (IDOR).
-   **Walidacja danych wejściowych**: Parametr `id` oraz ciało żądania są rygorystycznie walidowane przy użyciu Zod, aby zapobiec błędom i atakom (np. SQL Injection, chociaż Supabase ORM zapewnia ochronę).
-   **Zarządzanie stanem**: Logika biznesowa dotycząca dozwolonych przejść między stanami jest hermetyzowana w serwisie i egzekwowana przez funkcję bazodanową, co zapobiega nieprawidłowym operacjom na rezerwacjach.

## 7. Obsługa błędów

Endpoint będzie zwracał następujące kody błędów:

-   `401 Unauthorized`: Użytkownik nie jest zalogowany.
-   `403 Forbidden`: Użytkownik jest zalogowany, ale nie jest właścicielem ani wypożyczającym w danej rezerwacji.
-   `404 Not Found`: Rezerwacja o podanym `id` nie została znaleziona.
-   `409 Conflict`: Rezerwacja jest w stanie, który nie pozwala na jej anulowanie (np. została już zakończona lub anulowana).
-   `422 Unprocessable Entity`: Błąd walidacji danych wejściowych (np. `id` nie jest UUID, `cancelled_reason` jest zbyt długie).
-   `500 Internal Server Error`: Wystąpił nieoczekiwany błąd po stronie serwera, np. podczas komunikacji z bazą danych.

## 8. Rozważania dotyczące wydajności

Operacja jest transakcyjna i dotyczy pojedynczego rekordu, więc nie przewiduje się problemów z wydajnością. Tabela `reservations` powinna mieć indeks na kluczu głównym `id`, co jest standardem i zapewnia szybkie wyszukiwanie. Wywołanie funkcji RPC jest wydajnym sposobem na wykonanie logiki w bazie danych.

## 9. Etapy wdrożenia

1.  **Schemat walidacji**: W pliku `src/lib/schemas/reservation.schema.ts` dodać eksportowany `CancelReservationSchema` do walidacji ciała żądania.
2.  **Warstwa serwisowa**:
    -   W pliku `src/lib/services/reservations.service.ts` utworzyć nową, asynchroniczną metodę `cancelReservation(reservationId: string, userId: string, reason?: string): Promise<Reservation>`.
    -   Zaimplementować w niej logikę pobierania rezerwacji, weryfikacji uprawnień i stanu.
    -   Dodać wywołanie funkcji RPC `reservation_transition` za pomocą klienta Supabase (`supabase.rpc(...)`).
    -   Zaimplementować obsługę błędów poprzez rzucanie dedykowanych wyjątków lub zwracanie wyników z kodami błędów.
3.  **Endpoint API**:
    -   Utworzyć nowy plik `src/pages/api/reservations/[id]/cancel.ts`.
    -   Dodać `export const prerender = false;`.
    -   Zaimplementować handler `POST({ params, request, locals })`.
    -   Pobrać `id` z `params`, dane użytkownika z `locals.user` oraz `supabase` z `locals.supabase`.
    -   Zwalidować `id` oraz ciało żądania przy użyciu `CancelReservationSchema`.
    -   Wywołać metodę `reservationsService.cancelReservation(...)` w bloku `try...catch`.
    -   Obsłużyć potencjalne błędy z serwisu i mapować je na odpowiednie odpowiedzi HTTP z kodami stanu.
    -   W przypadku sukcesu, zwrócić zaktualizowaną rezerwację z kodem `200 OK`.

