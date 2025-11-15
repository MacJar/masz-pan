# API Endpoint Implementation Plan: POST /api/tokens/award/listing

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia zalogowanemu użytkownikowi otrzymanie bonusu w postaci tokenów za wystawienie nowego narzędzia. Logika biznesowa ogranicza przyznawanie bonusów do pierwszych trzech narzędzi wystawionych przez użytkownika i zapewnia, że za jedno narzędzie można otrzymać bonus tylko raz. Operacja jest atomowa i realizowana w ramach transakcji bazodanowej.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `POST`
-   **Struktura URL:** `/api/tokens/award/listing`
-   **Request Body:**
    -   **Typ zawartości:** `application/json`
    -   **Struktura:**
        ```json
        {
          "toolId": "string (uuid)"
        }
        ```
-   **Parametry:**
    -   **Wymagane:**
        -   `toolId` (w ciele żądania): Identyfikator UUID narzędzia.

## 3. Wykorzystywane typy

-   **DTO (Payload Schema):** `src/lib/schemas/token.schema.ts`
    ```typescript
    // AwardListingBonusPayloadSchema
    import { z } from 'zod';

    export const AwardListingBonusPayloadSchema = z.object({
      toolId: z.string().uuid({ message: 'Valid tool ID is required' }),
    });
    ```
-   **Command Model:** `src/types.ts`
    ```typescript
    // AwardListingBonusCommand
    export type AwardListingBonusCommand = {
      userId: string;
      toolId: string;
    };
    ```
-   **DTO (Response):** `src/types.ts`
    ```typescript
    // AwardListingBonusResponse
    export type AwardListingBonusResponse = {
      awarded: true;
      amount: number;
      countUsed: number;
    };
    ```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (Status 200 OK):**
    ```json
    {
      "awarded": true,
      "amount": 2,
      "count_used": 1 
    }
    ```
-   **Odpowiedzi błędów:**
    -   `400 Bad Request`: Nieprawidłowe lub brakujące `toolId`.
    -   `401 Unauthorized`: Użytkownik nie jest zalogowany.
    -   `403 Forbidden`: Użytkownik nie jest właścicielem narzędzia.
    -   `404 Not Found`: Narzędzie o podanym ID nie istnieje.
    -   `409 Conflict`: Bonus został już przyznany lub osiągnięto limit.
    -   `500 Internal Server Error`: Wewnętrzny błąd serwera.

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `POST` na `/api/tokens/award/listing` z `toolId` w ciele.
2.  Middleware Astro weryfikuje sesję użytkownika. Jeśli sesja jest nieprawidłowa, zwraca `401 Unauthorized`.
3.  Handler API w `src/pages/api/tokens/award/listing.ts` parsuje i waliduje ciało żądania przy użyciu `AwardListingBonusPayloadSchema`. W przypadku błędu zwraca `400 Bad Request`.
4.  Handler wywołuje metodę serwisową `tokensService.awardListingBonus({ userId, toolId })`.
5.  Metoda `awardListingBonus` w `src/lib/services/tokens.service.ts` wywołuje funkcję RPC w bazie danych Supabase: `award_listing_bonus(p_user_id, p_tool_id)`.
6.  Funkcja RPC `award_listing_bonus` wykonuje następujące operacje w ramach jednej transakcji:
    a. Sprawdza, czy narzędzie o podanym `tool_id` istnieje i czy `p_user_id` jest jego właścicielem. Jeśli nie, rzuca błąd (przechwytywany jako 404 lub 403).
    b. Weryfikuje, czy w tabeli `award_events` nie istnieje już wpis dla `(p_user_id, p_tool_id)` z `kind = 'listing_bonus'`. Jeśli tak, rzuca błąd (409 Conflict).
    c. Liczy istniejące wpisy w `award_events` dla `p_user_id` z `kind = 'listing_bonus'`. Jeśli liczba wynosi 3 lub więcej, rzuca błąd (409 Conflict).
    d. Wstawia nowy rekord do `award_events`.
    e. Wstawia nowy rekord `credit` do `token_ledger` na kwotę bonusu.
    f. Zatwierdza transakcję.
7.  Serwis `tokensService` otrzymuje wynik z funkcji RPC i zwraca go do handlera.
8.  Handler API formatuje odpowiedź sukcesu (200 OK) i odsyła ją do klienta.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint musi być chroniony. Dostęp jest możliwy tylko dla uwierzytelnionych użytkowników, co jest zapewniane przez middleware Astro.
-   **Autoryzacja:** Logika biznesowa musi rygorystycznie sprawdzać, czy `tool.owner_id` jest zgodne z ID zalogowanego użytkownika. Zapobiega to przyznawaniu bonusów za nie swoje narzędzia.
-   **Walidacja danych wejściowych:** Użycie Zod do walidacji `toolId` chroni przed atakami typu NoSQL injection i zapewnia integralność danych wejściowych.
-   **Ochrona przed Race Conditions:** Umieszczenie logiki sprawdzającej i zapisującej w jednej transakcji bazodanowej chroni przed możliwością obejścia limitu 3 bonusów poprzez równoczesne wysłanie wielu żądań.

## 7. Rozważania dotyczące wydajności

-   Operacja jest zamknięta w jednej, relatywnie prostej transakcji bazodanowej, co powinno zapewnić wysoką wydajność.
-   Kluczowe jest istnienie indeksów na tabeli `award_events` dla kolumn `(user_id, kind)` oraz `(user_id, tool_id, kind)`, aby zapytania zliczające i sprawdzające unikalność były szybkie. Unikalny indeks częściowy z `db-plan.md` realizuje to wymaganie.

## 8. Etapy wdrożenia

1.  **Baza danych:**
    -   Utwórz nowy plik migracji Supabase.
    -   Zaimplementuj funkcję RPC `award_listing_bonus(p_user_id uuid, p_tool_id uuid) RETURNS JSON`, która zawiera całą logikę transakcyjną (weryfikacja, sprawdzanie limitów, wstawianie rekordów).

2.  **Logika Backendowa (Schematy i Serwis):**
    -   W pliku `src/lib/schemas/token.schema.ts` dodaj `AwardListingBonusPayloadSchema`.
    -   W pliku `src/types.ts` dodaj typy `AwardListingBonusCommand` i `AwardListingBonusResponse`.
    -   W serwisie `src/lib/services/tokens.service.ts` zaimplementuj nową, asynchroniczną metodę `awardListingBonus(cmd: AwardListingBonusCommand)`. Metoda ta powinna wywoływać funkcję RPC i obsługiwać jej ewentualne błędy, mapując je na odpowiednie `ApiError`.

3.  **Endpoint API:**
    -   Utwórz nowy plik `src/pages/api/tokens/award/listing.ts`.
    -   Zaimplementuj handler `POST`, który:
        -   Eksportuje `prerender = false`.
        -   Sprawdza sesję użytkownika (`context.locals.user`).
        -   Waliduje ciało żądania za pomocą `AwardListingBonusPayloadSchema`.
        -   Wywołuje metodę `tokensService.awardListingBonus`.
        -   Zwraca odpowiedź w formacie JSON lub obsługuje błędy za pomocą `ApiErrorService`.

4.  **Testowanie:**
    -   Dodaj testy jednostkowe/integracyjne dla serwisu `tokens.service.ts`, sprawdzając wszystkie ścieżki (sukces, błędy uprawnień, przekroczenie limitu, ponowna próba dla tego samego narzędzia).
    -   Przeprowadź testy E2E dla endpointu API, symulując różne scenariusze.

