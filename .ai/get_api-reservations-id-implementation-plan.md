# API Endpoint Implementation Plan: GET /api/reservations/{id}

## 1. Przegląd punktu końcowego

Celem tego punktu końcowego jest dostarczenie szczegółowych informacji o pojedynczej rezerwacji. Dostęp do zasobu jest ściśle ograniczony i możliwy wyłącznie dla dwóch stron transakcji: właściciela narzędzia oraz osoby wypożyczającej (borrower). Pomyślne żądanie zwróci obiekt rezerwacji wraz z podstawowymi danymi powiązanego narzędzia.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `GET`
-   **Struktura URL:** `/api/reservations/[id]`
-   **Parametry:**
    -   **Wymagane:**
        -   `id` (w ścieżce URL): Identyfikator UUID rezerwacji.
-   **Request Body:** Brak

## 3. Wykorzystywane typy

Do implementacji zostaną wykorzystane lub stworzone następujące typy DTO w `src/types.ts`:

```typescript
// Propozycja DTO, jeśli nie istnieją odpowiedniki

/**
 * Podstawowe, publiczne informacje o narzędziu.
 */
export interface ToolSummaryDto {
  id: string;
  name: string;
  // Opcjonalnie: url głównego zdjęcia
  mainImageUrl?: string;
}

/**
 * Szczegółowe informacje o rezerwacji zwracane przez endpoint.
 */
export interface ReservationDetailsDto {
  id: string;
  status: ReservationStatus; // Istniejący typ ENUM
  agreedPriceTokens: number | null;
  tool: ToolSummaryDto;
  ownerId: string;
  borrowerId: string;
  createdAt: string;
  updatedAt: string;
}
```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (200 OK):**
    ```json
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "status": "owner_accepted",
      "agreedPriceTokens": 5,
      "tool": {
        "id": "2c7a8f8f-3b7a-4a32-8c28-2a8a1f73c6a4",
        "name": "Wiertarka udarowa Bosch"
      },
      "ownerId": "a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5",
      "borrowerId": "f6f6f6f6-e5e5-d4d4-c3c3-b2b2b2b2b2b2",
      "createdAt": "2025-11-14T10:00:00Z",
      "updatedAt": "2025-11-14T11:30:00Z"
    }
    ```
-   **Odpowiedzi błędów:**
    -   `400 Bad Request`: Nieprawidłowy format UUID w parametrze `id`.
    -   `401 Unauthorized`: Użytkownik nie jest zalogowany.
    -   `404 Not Found`: Rezerwacja o podanym ID nie istnieje lub użytkownik nie ma do niej uprawnień.
    -   `500 Internal Server Error`: Błąd serwera.

## 5. Przepływ danych

1.  Żądanie `GET` trafia do endpointa Astro `src/pages/api/reservations/[id].ts`.
2.  Middleware (`src/middleware/index.ts`) weryfikuje istnienie aktywnej sesji użytkownika i dołącza jego dane do `context.locals`. Jeśli sesja nie istnieje, zwraca `401`.
3.  Handler `GET` w pliku endpointa waliduje parametr `id` przy użyciu schemy Zod, sprawdzając, czy jest to poprawny UUID. W razie błędu zwraca `400`.
4.  Handler wywołuje metodę serwisu: `reservationsService.getReservationDetails(id, user.id)`.
5.  Metoda `getReservationDetails` w `src/lib/services/reservations.service.ts` wykonuje zapytanie do bazy Supabase.
6.  Zapytanie SQL pobiera dane z tabeli `reservations` i łączy je z tabelą `tools`, aby uzyskać nazwę narzędzia.
7.  Zapytanie zawiera klauzulę `WHERE`, która filtruje wyniki na podstawie `reservations.id` ORAZ warunku `(reservations.owner_id = :userId OR reservations.borrower_id = :userId)`.
8.  Jeśli zapytanie nie zwróci żadnego rekordu (co oznacza brak rezerwacji lub brak uprawnień), serwis rzuca błąd `ResourceNotFoundError`.
9.  W przypadku sukcesu, serwis mapuje wynik z bazy danych na DTO `ReservationDetailsDto`.
10. Handler endpointa przechwytuje ewentualne błędy: `ResourceNotFoundError` jest mapowany na odpowiedź `404`, a inne nieoczekiwane błędy na `500`.
11. Pomyślnie pobrane DTO jest zwracane w odpowiedzi JSON z kodem statusu `200`.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint musi być chroniony, a dostęp do niego możliwy tylko dla zalogowanych użytkowników. Zapewnia to middleware Astro.
-   **Autoryzacja:** Krytycznym elementem jest weryfikacja, czy zalogowany użytkownik jest jedną ze stron rezerwacji. Musi to być zaimplementowane na poziomie zapytania do bazy danych, aby zapobiec wyciekowi danych i atakom typu IDOR.
-   **Walidacja danych wejściowych:** Parametr `id` musi być walidowany jako UUID, aby zapobiec błędom zapytań i potencjalnym atakom (np. SQL Injection, chociaż Supabase SDK parametryzuje zapytania).
-   **Maskowanie błędów:** Zwracanie `404 Not Found` zarówno w przypadku braku zasobu, jak i braku uprawnień, jest celowym działaniem uniemożliwiającym atakującemu odgadnięcie istnienia rezerwacji.

## 7. Rozważania dotyczące wydajności

-   Zapytanie do bazy danych powinno być proste i wydajne. Wykorzystuje ono klucz główny tabeli `reservations` (`id`), co gwarantuje szybkie wyszukiwanie.
-   Należy upewnić się, że kolumny `owner_id` i `borrower_id` w tabeli `reservations` są zindeksowane, aby przyspieszyć część autoryzacyjną zapytania.

## 8. Etapy wdrożenia

1.  **Typy:** W pliku `src/types.ts` zdefiniować (jeśli nie istnieją) interfejsy `ToolSummaryDto` oraz `ReservationDetailsDto`.
2.  **Serwis:** W pliku `src/lib/services/reservations.service.ts` zaimplementować nową, asynchroniczną metodę `getReservationDetails(reservationId: string, userId: string)`.
    -   Metoda powinna przyjmować ID rezerwacji oraz ID zalogowanego użytkownika.
    -   Powinna wykonać zapytanie do Supabase, które pobierze rezerwację i podstawowe dane narzędzia, wymuszając w klauzuli `WHERE` sprawdzenie uprawnień.
    -   W przypadku braku wyników, powinna rzucić błąd (np. `ResourceNotFoundError` z `errors.service.ts`).
    -   W przypadku sukcesu, powinna zmapować dane na `ReservationDetailsDto` i je zwrócić.
3.  **Endpoint API:** Utworzyć nowy plik `src/pages/api/reservations/[id].ts`.
4.  **Implementacja Handlera:** W nowym pliku zaimplementować handler dla metody `GET`.
    -   Dodać `export const prerender = false;`.
    -   Pobrać ID użytkownika z `context.locals.user`. Jeśli nie istnieje, zwrócić `401`.
    -   Zwalidować parametr `id` z `Astro.params` przy użyciu Zod. W razie błędu zwrócić `400`.
    -   Wywołać metodę serwisu `getReservationDetails` w bloku `try...catch`.
    -   Obsłużyć błędy z serwisu, mapując je na odpowiednie odpowiedzi HTTP (`404`, `500`).
    -   W przypadku sukcesu, zwrócić pobrane dane z kodem statusu `200`.
