# API Endpoint Implementation Plan: POST /api/tokens/award/signup

## 1. Przegląd punktu końcowego

Ten punkt końcowy jest przeznaczony do przyznawania jednorazowego bonusu w postaci tokenów nowo zarejestrowanym użytkownikom. Użytkownik musi być uwierzytelniony, aby móc wywołać ten punkt końcowy. Operacja jest idempotentna, co oznacza, że użytkownik może otrzymać bonus tylko raz. Logika biznesowa jest zamknięta w funkcji bazodanowej, aby zapewnić atomowość operacji (przyznanie nagrody i aktualizacja salda).

## 2. Szczegóły żądania

-   **Metoda HTTP:** `POST`
-   **Struktura URL:** `/api/tokens/award/signup`
-   **Parametry:**
    -   **Wymagane:** Brak jawnych parametrów. Identyfikator użytkownika jest pobierany z aktywnej sesji uwierzytelniania zarządzanej przez middleware.
    -   **Opcjonalne:** Brak.
-   **Request Body:** Puste.

## 3. Wykorzystywane typy

-   **Response DTO (`AwardSignupBonusResponse`):**
    ```typescript
    // src/types.ts
    export interface AwardSignupBonusResponse {
      awarded: true;
      amount: number;
    }
    ```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (`200 OK`):**
    -   **Warunek:** Bonus został pomyślnie przyznany.
    -   **Body:**
        ```json
        {
          "awarded": true,
          "amount": 10
        }
        ```
-   **Odpowiedzi błędów:**
    -   **`401 Unauthorized`**: Użytkownik nie jest uwierzytelniony.
    -   **`409 Conflict`**: Użytkownik już otrzymał ten bonus.
    -   **`500 Internal Server Error`**: Wystąpił nieoczekiwany błąd serwera.

## 5. Przepływ danych

1.  Uwierzytelniony użytkownik wysyła żądanie `POST` na adres `/api/tokens/award/signup`.
2.  Middleware Astro (`src/middleware/index.ts`) weryfikuje sesję użytkownika i dołącza jego dane do `context.locals.user`. Jeśli sesja jest nieprawidłowa, middleware zwraca błąd `401`.
3.  Handler endpointa w `src/pages/api/tokens/award/signup.ts` odczytuje ID użytkownika z `context.locals.user.id`.
4.  Handler wywołuje metodę `TokensService.awardSignupBonus(userId)`.
5.  Metoda `awardSignupBonus` w `src/lib/services/tokens.service.ts` wywołuje funkcję RPC Supabase `award_signup_bonus` z przekazanym `user_id`.
6.  Funkcja bazodanowa `award_signup_bonus` wykonuje transakcję:
    a. Próbuje wstawić nowy rekord do tabeli `award_events` z `kind = 'signup_bonus'`.
    b. Jeśli wstawienie narusza unikalny klucz `(user_id, kind)`, funkcja przechwytuje wyjątek i zwraca status wskazujący na konflikt.
    c. Jeśli wstawienie się powiedzie, funkcja dodaje odpowiedni wpis `credit` do tabeli `token_ledger` dla danego użytkownika na kwotę 10 tokenów.
    d. Zwraca status powodzenia.
7.  `TokensService` otrzymuje wynik z RPC. Jeśli wynikiem jest konflikt, rzuca dedykowany błąd (np. `AlreadyAwardedError`). W przypadku innych błędów bazy danych, rzuca generyczny błąd serwera.
8.  Handler endpointa łapie błędy z serwisu:
    -   W przypadku `AlreadyAwardedError`, zwraca odpowiedź `409 Conflict`.
    -   W przypadku sukcesu, zwraca odpowiedź `200 OK` z danymi o przyznanych tokenach.
    -   W przypadku innych błędów, zwraca `500 Internal Server Error`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint musi być bezwzględnie chroniony i dostępny tylko dla zalogowanych użytkowników. Middleware Astro jest odpowiedzialne za egzekwowanie tej zasady.
-   **Autoryzacja:** Każdy uwierzytelniony użytkownik jest uprawniony do wywołania tego endpointa w swoim własnym imieniu.
-   **Idempotentność:** Kluczowy mechanizm bezpieczeństwa zapobiegający wielokrotnemu przyznawaniu bonusu. Jest on realizowany przez unikalny indeks w tabeli `award_events` na poziomie bazy danych, co jest odporne na race conditions.

## 7. Obsługa błędów

-   **`401 Unauthorized`**: Zwracany przez middleware, gdy w żądaniu brakuje prawidłowej sesji.
-   **`409 Conflict`**: Zwracany, gdy `TokensService` zasygnalizuje, że funkcja bazodanowa napotkała naruszenie unikalnego klucza, co oznacza, że bonus został już przyznany.
-   **`500 Internal Server Error`**: Zwracany w przypadku nieoczekiwanych błędów podczas wywołania RPC Supabase lub innych problemów po stronie serwera. Błędy te powinny być logowane.

## 8. Rozważania dotyczące wydajności

-   Operacje wykonywane przez ten endpoint są proste i opierają się na indeksowanych kolumnach w bazie danych (`award_events.user_id`).
-   Nie przewiduje się problemów z wydajnością; obciążenie jest minimalne.

## 9. Etapy wdrożenia

1.  **Baza danych:**
    -   Utwórz nową migrację Supabase w celu dodania funkcji `award_signup_bonus(p_user_id uuid)`.
    -   Funkcja powinna zawierać logikę transakcyjną: `INSERT` do `award_events` i `INSERT` do `token_ledger`.
    -   Implementacja powinna zawierać blok `EXCEPTION` do obsługi błędu `unique_violation` (kod SQLSTATE `23505`) i zwracania wskaźnika konfliktu.
2.  **Serwis:**
    -   W pliku `src/lib/services/errors.service.ts` dodaj nową klasę błędu `AlreadyAwardedError`.
    -   W pliku `src/lib/services/tokens.service.ts` dodaj nową asynchroniczną metodę `awardSignupBonus(userId: string)`.
    -   Metoda ta powinna wywołać funkcję RPC `award_signup_bonus` w Supabase.
    -   Przeanalizuj odpowiedź z RPC. Jeśli wskazuje na konflikt, rzuć `AlreadyAwardedError`. W przypadku innych błędów rzuć generyczny `Error`.
3.  **API Route:**
    -   Utwórz nowy plik `src/pages/api/tokens/award/signup.ts`.
    -   Zaimplementuj handler `POST`, który jest asynchroniczny i ma `export const prerender = false`.
    -   W handlerze:
        a. Sprawdź, czy `context.locals.user` istnieje. Jeśli nie, zwróć `401`.
        b. Wywołaj `tokensService.awardSignupBonus` w bloku `try...catch`.
        c. W bloku `catch` sprawdzaj instancję błędu. Jeśli to `AlreadyAwardedError`, zwróć `409`. W przeciwnym razie zaloguj błąd i zwróć `500`.
        d. Jeśli wywołanie serwisu zakończy się sukcesem, zwróć odpowiedź `200 OK` z payloadem `{ awarded: true, amount: 10 }`.
4.  **Typy:**
    -   Dodaj `AwardSignupBonusResponse` do `src/types.ts`.
