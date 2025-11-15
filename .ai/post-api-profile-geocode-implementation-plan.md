# API Endpoint Implementation Plan: POST /api/profile/geocode

## 1. Przegląd punktu końcowego

Ten punkt końcowy służy do uruchomienia procesu geokodowania dla profilu aktualnie uwierzytelnionego użytkownika. Odczytuje on tekstową lokalizację użytkownika (`location_text`), konwertuje ją na współrzędne geograficzne za pomocą zewnętrznej usługi i zapisuje wynik w bazie danych jako `location_geog`. Endpoint pozwala na aktualizację współrzędnych na żądanie, bez konieczności edycji całego profilu.

## 2. Szczegóły żądania

- **Metoda HTTP**: `POST`
- **Struktura URL**: `/api/profile/geocode`
- **Parametry**:
  - **Wymagane**: Brak.
  - **Opcjonalne**: Brak.
- **Request Body**: Brak. Operacja jest wykonywana w kontekście uwierzytelnionego użytkownika na podstawie jego sesji.

## 3. Wykorzystywane typy

- **`ProfileGeocodeResultDTO`**: Obiekt transferu danych (DTO) używany w odpowiedzi, zawierający zgeokodowaną lokalizację.
  ```typescript
  export interface ProfileGeocodeResultDTO {
    location_geog: GeoJSONPoint;
  }
  ```
- **`GeoJSONPoint`**: Standardowy format GeoJSON do reprezentacji punktu geograficznego.
  ```typescript
  export interface GeoJSONPoint {
    type: "Point";
    coordinates: [number, number]; // [lon, lat]
  }
  ```

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (200 OK)**: Zwraca obiekt `ProfileGeocodeResultDTO` z nowo obliczonymi współrzędnymi.
  ```json
  {
    "location_geog": {
      "type": "Point",
      "coordinates": [21.0122, 52.2297]
    }
  }
  ```
- **Odpowiedzi błędów**:
  - `400 Bad Request`: Gdy `location_text` w profilu jest pusty.
  - `401 Unauthorized`: Gdy użytkownik nie jest zalogowany.
  - `404 Not Found`: Gdy profil użytkownika nie istnieje.
  - `422 Unprocessable Entity`: Gdy podany `location_text` nie może zostać zgeokodowany.
  - `500 Internal Server Error`: W przypadku błędów serwera lub usługi zewnętrznej.

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `POST` na adres `/api/profile/geocode`.
2.  Middleware Astro weryfikuje sesję Supabase i zapewnia, że użytkownik jest uwierzytelniony.
3.  Handler API w `src/pages/api/profile/geocode.ts` pobiera ID użytkownika z `Astro.locals.session`.
4.  Handler wywołuje metodę `geocodeAndSaveForProfile(userId)` z serwisu `GeocodingService`.
5.  Serwis `GeocodingService` pobiera profil użytkownika z bazy danych.
6.  Sprawdza, czy `location_text` istnieje i nie jest pusty. Jeśli jest pusty, zwraca błąd.
7.  (Opcjonalnie) Sprawdza, czy `location_geog` już istnieje, aby uniknąć niepotrzebnych wywołań API (cache).
8.  Wywołuje zewnętrzną usługę geokodowania (np. Mapbox, Google) z `location_text`.
9.  Otrzymuje współrzędne `[lon, lat]` lub błąd, jeśli lokalizacja jest nieznana.
10. Aktualizuje pole `location_geog` w tabeli `profiles` dla danego użytkownika.
11. Zwraca zaktualizowane współrzędne do handlera API.
12. Handler API formatuje odpowiedź jako `ProfileGeocodeResultDTO` i wysyła ją do klienta z kodem statusu `200 OK`.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie**: Dostęp do punktu końcowego musi być ograniczony tylko do zalogowanych użytkowników. Middleware Astro musi weryfikować poprawność sesji Supabase.
- **Autoryzacja**: Użytkownik może geokodować wyłącznie własny profil. Logika serwisu musi operować na ID użytkownika pobranym z sesji, a nie z parametrów żądania.
- **Zmienne środowiskowe**: Klucz API do zewnętrznej usługi geokodowania musi być przechowywany jako zmienna środowiskowa i nigdy nie być ujawniany po stronie klienta.
- **Rate Limiting**: Należy rozważyć wprowadzenie mechanizmu ograniczającego liczbę żądań geokodowania dla jednego użytkownika w danym okresie, aby zapobiec nadużyciom i kontroli kosztów.

## 7. Rozważania dotyczące wydajności

- **Cache'owanie**: Aby zminimalizować liczbę wywołań do zewnętrznego API, serwis powinien unikać ponownego geokodowania, jeśli `location_text` w profilu nie uległ zmianie, a `location_geog` już istnieje.
- **Indeksy bazy danych**: Tabela `profiles` musi mieć indeks GIST na kolumnie `location_geog`, co jest kluczowe dla przyszłych zapytań przestrzennych.

## 8. Etapy wdrożenia

1.  **Utworzenie pliku trasy API**: Stwórz plik `src/pages/api/profile/geocode.ts`.
2.  **Implementacja handlera `POST`**: Wewnątrz pliku z pkt. 1, zaimplementuj `export const POST: APIRoute = async ({ locals }) => { ... }` i ustaw `export const prerender = false`.
3.  **Pobranie sesji**: W handlerze uzyskaj dostęp do sesji i ID użytkownika poprzez `locals.session.user.id`. Zabezpiecz endpoint przed dostępem nieuwierzytelnionych użytkowników, zwracając `401 Unauthorized`.
4.  **Rozbudowa serwisu `GeocodingService`**: W pliku `src/lib/services/geocoding.service.ts` dodaj nową asynchroniczną funkcję `geocodeAndSaveForProfile(userId: string, supabase: SupabaseClient)`.
5.  **Implementacja logiki w serwisie**:
    -   Pobierz profil użytkownika na podstawie `userId`. Zwróć błąd, jeśli profil nie istnieje (`404 Not Found`).
    -   Sprawdź, czy `profile.location_text` jest niepusty. Jeśli nie, zwróć błąd (`400 Bad Request`).
    -   Wywołaj zewnętrzne API do geokodowania (np. używając `fetch`). Użyj klucza API ze zmiennych środowiskowych (`import.meta.env.GEOCODING_API_KEY`).
    -   Obsłuż błędy z zewnętrznego API (np. gdy lokalizacja jest nierozpoznawalna - `422 Unprocessable Entity`).
    -   Zaktualizuj rekord w tabeli `profiles`, ustawiając pole `location_geog` z otrzymanymi współrzędnymi.
    -   Zwróć zaktualizowany obiekt `location_geog`.
6.  **Integracja serwisu z handlerem API**: Wywołaj `geocodeAndSaveForProfile` w handlerze `POST`, przekazując `userId` i klienta `supabase` z `locals`.
7.  **Obsługa błędów w handlerze**: Otocz wywołanie serwisu blokiem `try...catch`. Mapuj błędy rzucane przez serwis na odpowiednie odpowiedzi HTTP (np. `return new Response(..., { status: 400 })`).
8.  **Zwrócenie poprawnej odpowiedzi**: W przypadku sukcesu, zwróć odpowiedź `200 OK` z ciałem w formacie `ProfileGeocodeResultDTO`, używając `Response.json()`.

