# API Endpoint Implementation Plan: GET /api/users/{id}/ratings/summary

## 1. Przegląd punktu końcowego

Celem tego punktu końcowego jest dostarczenie zagregowanych danych dotyczących ocen dla danego użytkownika. Umożliwi to wyświetlanie średniej oceny i całkowitej liczby ocen w publicznym profilu użytkownika. Endpoint będzie pobierał dane z bazy danych, preferencyjnie korzystając ze zmaterializowanego widoku `rating_stats` w celu zapewnienia wysokiej wydajności.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `GET`
-   **Struktura URL:** `/api/users/{id}/ratings/summary`
-   **Parametry:**
    -   **Wymagane:**
        -   `id` (parametr ścieżki): Unikalny identyfikator (UUID) użytkownika.
    -   **Opcjonalne:**
        -   Brak.
-   **Request Body:**
    -   Brak.

## 3. Wykorzystywane typy

-   **`UserIdParams` (Zod Schema):**
    ```typescript
    import { z } from 'zod';

    export const UserIdParams = z.object({
      id: z.string().uuid({ message: "User ID must be a valid UUID." }),
    });
    ```
-   **`UserRatingSummaryDto` (Typ TypeScript w `src/types.ts`):**
    ```typescript
    export interface UserRatingSummaryDto {
      rated_user_id: string;
      avg_stars: number | null;
      ratings_count: number;
    }
    ```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (200 OK):**
    ```json
    {
      "rated_user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "avg_stars": 4.75,
      "ratings_count": 12
    }
    ```
-   **Odpowiedź błędu (400 Bad Request):**
    ```json
    {
      "message": "Invalid input",
      "errors": ["User ID must be a valid UUID."]
    }
    ```
-   **Odpowiedź błędu (404 Not Found):**
    ```json
    {
      "message": "User not found"
    }
    ```

## 5. Przepływ danych

1.  Klient wysyła żądanie `GET` na adres `/api/users/{id}/ratings/summary`.
2.  Middleware Astro (`src/middleware/index.ts`) przetwarza żądanie, m.in. inicjalizując klienta Supabase w `context.locals`.
3.  Handler API w `src/pages/api/users/[id]/ratings/summary.ts` zostaje wywołany.
4.  Handler waliduje parametr `id` ze ścieżki URL przy użyciu schematu Zod `UserIdParams`.
5.  Jeśli walidacja się powiedzie, handler wywołuje metodę `getRatingSummary(userId)` z serwisu `ProfileService`.
6.  Metoda `getRatingSummary` wykonuje zapytanie `SELECT` do zmaterializowanego widoku `rating_stats` w bazie danych Supabase, filtrując po `rated_user_id`.
7.  Baza danych zwraca zagregowane dane (średnia i liczba ocen) lub `null`, jeśli użytkownik nie ma ocen.
8.  `ProfileService` zwraca wynik do handlera.
9.  Handler formatuje dane do postaci `UserRatingSummaryDto` i wysyła odpowiedź JSON z kodem statusu `200 OK` lub odpowiedni kod błędu (`404` lub `500`).

## 6. Względy bezpieczeństwa

-   **Walidacja danych wejściowych:** Wszystkie dane wejściowe, w tym parametr `id` ze ścieżki, muszą być walidowane przy użyciu Zod, aby upewnić się, że są w oczekiwanym formacie (UUID). Zapobiega to podstawowym wektorom ataków.
-   **Uwierzytelnianie i autoryzacja:** Endpoint jest publiczny i nie wymaga uwierzytelniania ani autoryzacji, ponieważ zwraca dane przeznaczone do publicznego wyświetlania.
-   **Dostęp do bazy danych:** Zapytania do bazy danych będą wykonywane za pośrednictwem klienta Supabase, który parametryzuje zapytania, chroniąc przed atakami SQL Injection. Klient Supabase będzie używał klucza `service_role` po stronie serwera.

## 7. Obsługa błędów

-   **Błąd walidacji (400 Bad Request):** Jeśli `id` nie jest poprawnym UUID, handler zwróci odpowiedź 400 z listą błędów walidacji.
-   **Nie znaleziono zasobu (404 Not Found):** Jeśli zapytanie do `rating_stats` nie zwróci wyników dla danego `id`, serwis sprawdzi, czy profil użytkownika w ogóle istnieje. Jeśli nie, zostanie zwrócony błąd 404. Jeśli profil istnieje, ale nie ma ocen, zostanie zwrócona odpowiedź 200 z `avg_stars: null` i `ratings_count: 0`.
-   **Błąd serwera (500 Internal Server Error):** W przypadku problemów z połączeniem z bazą danych lub innych nieoczekiwanych błędów, zostanie zwrócona odpowiedź 500. Błąd zostanie zarejestrowany w logach serwera.

## 8. Rozważania dotyczące wydajności

-   **Wykorzystanie zmaterializowanego widoku:** Główne zapytanie będzie skierowane do zmaterializowanego widoku `rating_stats`, co jest znacznie wydajniejsze niż dynamiczne obliczanie agregatów z tabeli `ratings` przy każdym żądaniu.
-   **Indeksowanie:** Należy upewnić się, że kolumna `rated_user_id` w widoku `rating_stats` jest zaindeksowana w celu przyspieszenia wyszukiwania.
-   **Odświeżanie widoku:** Należy wdrożyć strategię regularnego odświeżania zmaterializowanego widoku (np. za pomocą cron job w Supabase), aby dane były aktualne.

## 9. Etapy wdrożenia

1.  **Aktualizacja typów:**
    -   W pliku `src/types.ts` zdefiniuj interfejs `UserRatingSummaryDto`.

2.  **Rozbudowa serwisu:**
    -   W pliku `src/lib/services/profile.service.ts` dodaj nową metodę `getRatingSummary(userId: string)`.
    -   Wewnątrz metody zaimplementuj logikę zapytania do widoku `rating_stats` przy użyciu przekazanego klienta Supabase.
    -   Dodaj obsługę przypadku, gdy użytkownik nie ma ocen (zapytanie zwraca `null`).

3.  **Implementacja handlera API:**
    -   Utwórz nowy plik `src/pages/api/users/[id]/ratings/summary.ts`.
    -   Dodaj `export const prerender = false;`.
    -   Zaimplementuj handler dla metody `GET`.
    -   Pobierz `id` z `Astro.params`.
    -   Zwaliduj `id` przy użyciu schematu Zod.
    -   Wywołaj metodę `profileService.getRatingSummary(id)`.
    -   Zwróć odpowiedź w formacie JSON (`Response.json()`) z odpowiednim kodem statusu i danymi.
    -   Zaimplementuj obsługę błędów (400, 404, 500).

4.  **Testowanie:**
    -   Przygotuj dane testowe w bazie danych (użytkownicy z ocenami i bez).
    -   Wykonaj ręczne testy punktu końcowego za pomocą narzędzia typu cURL lub Postman, sprawdzając wszystkie scenariusze (sukces, nieprawidłowe ID, nieistniejący użytkownik).


