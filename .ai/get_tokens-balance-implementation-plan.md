# API Endpoint Implementation Plan: GET /api/tokens/balance

## 1. Przegląd punktu końcowego

Ten punkt końcowy służy do pobierania aktualnego salda tokenów (całkowitego, zablokowanego i dostępnego) dla uwierzytelnionego użytkownika. Jest to operacja tylko do odczytu, która pobiera dane z widoku `balances` w bazie danych.

## 2. Szczegóły żądania

-   **Metoda HTTP**: `GET`
-   **Struktura URL**: `/api/tokens/balance`
-   **Parametry**:
    -   Wymagane: Brak.
    -   Opcjonalne: Brak.
-   **Request Body**: Brak.
-   **Nagłówki**:
    -   `Authorization`: `Bearer <SUPABASE_JWT>` (wymagany do uwierzytelnienia).

## 3. Wykorzystywane typy

W pliku `src/types.ts` zostanie zdefiniowany następujący typ DTO dla odpowiedzi:

```typescript
export interface TokenBalanceDto {
  user_id: string;
  total: number;
  held: number;
  available: number;
}
```

## 4. Szczegóły odpowiedzi

-   **Sukces (200 OK)**: Zwraca obiekt JSON z saldem tokenów.
    ```json
    {
      "user_id": "c3e4a5f6-7b8c-9d0e-1f2a-3b4c5d6e7f8a",
      "total": 100,
      "held": 20,
      "available": 80
    }
    ```
-   **Błąd (401 Unauthorized)**: Gdy użytkownik nie jest uwierzytelniony.
-   **Błąd (500 Internal Server Error)**: W przypadku problemów z serwerem lub bazą danych.

## 5. Przepływ danych

1.  Klient wysyła żądanie `GET` na adres `/api/tokens/balance`.
2.  Middleware Astro (`src/middleware/index.ts`) weryfikuje token JWT i inicjalizuje sesję Supabase, udostępniając ją w `context.locals`.
3.  Handler API w `src/pages/api/tokens/balance.ts` pobiera sesję i ID użytkownika z `context.locals`. Jeśli sesja nie istnieje, zwraca `401 Unauthorized`.
4.  Handler wywołuje metodę `getUserBalance(userId)` z nowo utworzonego serwisu `TokensService` (`src/lib/services/tokens.service.ts`).
5.  `TokensService.getUserBalance` wykonuje zapytanie `SELECT * FROM balances WHERE user_id = :userId` do bazy danych Supabase.
6.  Jeśli zapytanie nie zwróci żadnego wiersza, serwis konstruuje i zwraca domyślny obiekt `TokenBalanceDto` z wartościami `0`.
7.  Serwis mapuje wynik zapytania na obiekt `TokenBalanceDto` i zwraca go do handlera.
8.  Handler serializuje DTO do formatu JSON i odsyła do klienta z kodem statusu `200 OK`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie**: Dostęp do endpointu musi być chroniony i wymagać ważnego tokenu sesji Supabase.
-   **Autoryzacja**: Logika serwisu musi bezwzględnie zapewniać, że zapytanie do bazy danych jest filtrowane przez ID użytkownika pobrane z sesji serwerowej. Zapobiegnie to możliwości odczytania salda innego użytkownika.

## 7. Rozważania dotyczące wydajności

-   Zapytanie odpytuje widok (`balances`), który wykonuje agregację na tabeli `token_ledger`. Przy bardzo dużej liczbie transakcji w `token_ledger`, wydajność tego widoku może ulec pogorszeniu.
-   **Optymalizacja**: W przyszłości, jeśli wydajność stanie się problemem, widok `balances` można zastąpić zmaterializowanym widokiem, który byłby odświeżany okresowo lub za pomocą triggerów.

## 8. Etapy wdrożenia

1.  **Definicja Typu**: W pliku `src/types.ts` dodać definicję interfejsu `TokenBalanceDto`.
2.  **Utworzenie Serwisu**: Stworzyć nowy plik `src/lib/services/tokens.service.ts`.
3.  **Implementacja Logiki Serwisu**:
    -   W `tokens.service.ts` zaimplementować funkcję `getUserBalance(supabase: SupabaseClient, userId: string): Promise<TokenBalanceDto>`.
    -   Funkcja ta powinna wykonać zapytanie do widoku `balances` w bazie danych.
    -   Powinna obsłużyć przypadek, gdy dla danego użytkownika nie ma jeszcze rekordu w widoku (zwracając zerowe saldo).
4.  **Utworzenie Endpointu API**: Stworzyć nowy plik `src/pages/api/tokens/balance.ts`.
5.  **Implementacja Handlera API**:
    -   W pliku `balance.ts` dodać `export const prerender = false;`.
    -   Zaimplementować handler `GET({ locals })`.
    -   Pobrać sesję użytkownika z `locals.supabase`.
    -   W przypadku braku sesji, zwrócić odpowiedź z kodem `401`.
    -   Wywołać serwis `TokensService.getUserBalance`, przekazując klienta Supabase i ID użytkownika.
    -   Zwrócić uzyskaną odpowiedź DTO w formacie JSON z kodem `200 OK`.
    -   Dodać obsługę błędów `try-catch` dla wywołania serwisu i zwracać `500` w razie niepowodzenia.


