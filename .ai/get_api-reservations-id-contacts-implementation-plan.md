
# API Endpoint Implementation Plan: GET /api/reservations/:id/contacts

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia bezpieczne pobranie adresów e-mail właściciela narzędzia i osoby wypożyczającej, powiązanych z konkretną rezerwacją. Dostęp do tych danych jest ściśle kontrolowany i możliwy tylko dla stron uczestniczących w rezerwacji (właściciela lub wypożyczającego) i dopiero po tym, jak rezerwacja zostanie obustronnie potwierdzona (osiągnie status `borrower_confirmed` lub późniejszy). Każde wywołanie tego endpointu jest audytowane.

## 2. Szczegóły żądania

- **Metoda HTTP:** `GET`
- **Struktura URL:** `/api/reservations/:id/contacts`
- **Parametry:**
  - **Wymagane:**
    - `id` (w ścieżce URL): Identyfikator rezerwacji w formacie UUID.
  - **Opcjonalne:**
    - Brak.
- **Request Body:**
  - Brak.

## 3. Wykorzystywane typy

- **DTO (Data Transfer Object):**
  - `ReservationContactsDto` (do dodania w `src/types.ts`):
    ```typescript
    export interface ReservationContactsDto {
      owner_email: string;
      borrower_email: string;
    }
    ```

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (200 OK):**
  ```json
  {
    "owner_email": "owner@example.com",
    "borrower_email": "borrower@example.com"
  }
  ```
- **Kody statusu:**
  - `200 OK`: Pomyślnie pobrano dane kontaktowe.
  - `400 Bad Request`: Identyfikator rezerwacji jest nieprawidłowy.
  - `401 Unauthorized`: Użytkownik nie jest zalogowany.
  - `403 Forbidden`: Użytkownik nie jest stroną w danej rezerwacji.
  - `404 Not Found`: Rezerwacja o podanym identyfikatorze nie istnieje.
  - `409 Conflict`: Rezerwacja nie osiągnęła jeszcze wymaganego statusu do ujawnienia kontaktów.
  - `500 Internal Server Error`: Wewnętrzny błąd serwera.

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `GET` na adres `/api/reservations/:id/contacts`.
2.  Middleware Astro weryfikuje sesję użytkownika.
3.  Handler endpointu (`src/pages/api/reservations/[id]/contacts.ts`) jest wywoływany.
4.  Handler waliduje format `id` rezerwacji (UUID) przy użyciu Zod.
5.  Handler wywołuje metodę `getReservationContacts` z serwisu `reservations.service.ts`, przekazując `id` rezerwacji oraz `id` zalogowanego użytkownika.
6.  Metoda serwisowa wywołuje funkcję bazodanową `get_counterparty_contact(reservation_id, invoker_id)`.
7.  Funkcja bazodanowa (`SECURITY DEFINER`):
    a. Sprawdza, czy `invoker_id` jest właścicielem lub wypożyczającym dla danej rezerwacji. Jeśli nie, zgłasza błąd uprawnień (przechwytywany jako 403).
    b. Sprawdza, czy status rezerwacji to `borrower_confirmed`, `picked_up` lub `returned`. Jeśli nie, zgłasza błąd stanu (przechwytywany jako 409).
    c. Wstawia wpis do tabeli `audit_log` z `event_type='contact_reveal'`.
    d. Pobiera i zwraca adresy e-mail właściciela i wypożyczającego z tabeli `auth.users`.
8.  Serwis otrzymuje dane i zwraca je w obiekcie `Result.success`. W przypadku błędu z bazy danych, mapuje go na odpowiedni `ApiError` i zwraca `Result.error`.
9.  Handler endpointu odbiera `Result` z serwisu i wysyła odpowiedź HTTP z odpowiednim kodem statusu i ciałem odpowiedzi.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie:** Endpoint jest chroniony i wymaga aktywnej sesji użytkownika. Brak sesji skutkuje odpowiedzią `401 Unauthorized`.
- **Autoryzacja:** Logika jest realizowana wewnątrz funkcji bazodanowej. Sprawdza ona, czy zalogowany użytkownik (`auth.uid()`) jest jedną ze stron rezerwacji (`owner_id` lub `borrower_id`). Próba dostępu przez innego użytkownika skutkuje błędem `403 Forbidden`.
- **Walidacja danych:** Parametr `id` jest walidowany jako UUID na poziomie handlera.
- **Audyt:** Każda próba (udana lub nieudana) odczytu danych kontaktowych jest rejestrowana w tabeli `audit_log`, co pozwala na monitorowanie dostępu do wrażliwych danych.

## 7. Rozważania dotyczące wydajności

- Operacja opiera się na prostym zapytaniu do bazy danych z wykorzystaniem indeksów na kluczach głównych (`reservations.id`), co powinno zapewnić wysoką wydajność.
- Dodatkowy zapis do tabeli `audit_log` jest operacją o niskim koszcie i nie powinien znacząco wpłynąć na czas odpowiedzi.
- Nie przewiduje się problemów z wydajnością dla tego punktu końcowego.

## 8. Etapy wdrożenia

1.  **Migracja Bazy Danych:**
    - Utworzyć nowy plik migracji SQL w `supabase/migrations/`.
    - Zdefiniować funkcję `get_counterparty_contact(reservation_id uuid)` w PostgreSQL:
      - Ustawić `SECURITY DEFINER` i `RETURNS TABLE(owner_email text, borrower_email text)`.
      - Zaimplementować logikę weryfikacji uprawnień (czy `auth.uid()` jest stroną rezerwacji).
      - Zaimplementować logikę weryfikacji statusu rezerwacji (musi być `>= 'borrower_confirmed'`).
      - Dodać `INSERT` do tabeli `audit_log`.
      - Zwrócić e-maile z `auth.users` poprzez złączenie z `profiles`.
2.  **Aktualizacja Typów:**
    - W pliku `src/types.ts` dodać definicję interfejsu `ReservationContactsDto`.
3.  **Logika Serwisu:**
    - W pliku `src/lib/services/reservations.service.ts`:
      - Utworzyć nową, asynchroniczną metodę `getReservationContacts`.
      - Metoda powinna przyjmować `reservationId: string` i `currentUserId: string`.
      - Wywołać RPC (`supabase.rpc('get_counterparty_contact', { ... })`).
      - Obsłużyć potencjalne błędy z RPC (np. P0001 dla błędów uprawnień/stanu) i zmapować je na odpowiednie `ApiError` (np. `ForbiddenError`, `ConflictError`, `NotFoundError`).
      - W przypadku sukcesu, zwrócić `Result.success` z danymi.
4.  **Implementacja Endpointu API:**
    - Utworzyć nowy plik `src/pages/api/reservations/[id]/contacts.ts`.
    - Dodać `export const prerender = false;`.
    - Zaimplementować `GET` handler.
    - Sprawdzić sesję użytkownika. Jeśli brak, zwrócić `UnauthorizedError`.
    - Zwalidować `id` z `Astro.params` przy użyciu `z.string().uuid()`. Jeśli błąd, zwrócić `BadRequestError`.
    - Wywołać `reservationsService.getReservationContacts`.
    - Na podstawie zwróconego `Result`, wysłać odpowiednią odpowiedź HTTP (`Ok`, `Created` lub błąd).
5.  **Testowanie:**
    - Napisać testy jednostkowe dla logiki serwisu, symulując różne odpowiedzi RPC.
    - Przeprowadzić testy integracyjne (manualne lub automatyczne) dla endpointu, sprawdzając wszystkie ścieżki sukcesu i błędów (różne statusy, brak uprawnień, brak rezerwacji, itp.).
