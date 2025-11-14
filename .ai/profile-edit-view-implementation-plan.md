# Plan implementacji widoku Edycja Profilu / Onboarding

## 1. Przegląd
Celem tego widoku jest umożliwienie nowym użytkownikom uzupełnienia kluczowych danych profilowych (nazwa, lokalizacja, zgoda RODO) w ramach procesu onboardingu, a także pozwolenie istniejącym użytkownikom na edycję tych informacji. Widok ten jest kluczowy dla funkcjonowania aplikacji, ponieważ kompletny profil jest wymagany do korzystania z chronionych zasobów. Proces zapisywania profilu jest połączony z geokodowaniem podanej lokalizacji.

## 2. Routing widoku
Widok będzie dostępny pod chronioną ścieżką:
- **URL**: `/profile/edit`

Dostęp do tej ścieżki wymaga autentykacji. Nowi użytkownicy z niekompletnym profilem będą automatycznie przekierowywani do tego widoku przez middleware z dowolnej chronionej strony.

## 3. Struktura komponentów
Hierarchia komponentów zostanie zaimplementowana z wykorzystaniem React i będzie renderowana na stronie Astro (`/src/pages/profile/edit.astro`).

```
- edit.astro (Strona Astro)
  - Layout.astro
    - ProfileEditView.tsx (Główny komponent kliencki)
      - SkeletonLoader.tsx (Wyświetlany podczas ładowania danych)
      - ErrorDisplay.tsx (Wyświetlany w przypadku błędu pobierania danych)
      - ProfileForm.tsx (Formularz edycji profilu)
        - Komponenty UI z biblioteki Shadcn:
          - Label, Input (dla nazwy użytkownika)
          - Label, Input (dla lokalizacji)
          - LocationStatus.tsx (Komponent statusu geokodowania)
          - Checkbox, Label (dla zgody RODO)
          - Button (Przycisk zapisu)
        - ErrorDisplay.tsx (Do wyświetlania błędów walidacji formularza)
      - Sonner/Toaster (Do wyświetlania powiadomień toast)
```

## 4. Szczegóły komponentów

### `ProfileEditView.tsx`
- **Opis komponentu**: Komponent kontenerowy, który zarządza logiką i stanem całego widoku. Odpowiada za pobieranie danych profilu, obsługę interakcji z API oraz renderowanie komponentów podrzędnych w zależności od stanu (ładowanie, błąd, sukces).
- **Główne elementy**: Wykorzystuje `ProfileForm` do renderowania interfejsu, a także komponenty `SkeletonLoader` i `ErrorDisplay` do obsługi stanów pośrednich.
- **Obsługiwane interakcje**: Inicjuje pobieranie danych profilu przy montowaniu. Przekazuje handler zapisu formularza do komponentu `ProfileForm`.
- **Obsługiwana walidacja**: Brak bezpośredniej walidacji. Zarządza stanem błędów walidacyjnych otrzymanych z API i przekazuje je do `ProfileForm`.
- **Typy**: `Profile` (DTO), `ProfileEditViewModel` (ViewModel).
- **Propsy**: Brak.

### `ProfileForm.tsx`
- **Opis komponentu**: Komponent prezentacyjny zawierający formularz HTML. Renderuje pola do wprowadzania danych, obsługuje ich zmiany i wyświetla błędy walidacyjne.
- **Główne elementy**: `form`, `Input` (dla `username` i `location_text`), `Checkbox` (dla `rodo_consent`), `Button` (do wysłania formularza). Obok pola lokalizacji znajduje się komponent `LocationStatus`.
- **Obsługiwane interakcje**:
  - `onChange` dla każdego pola formularza.
  - `onSubmit` dla całego formularza.
- **Obsługiwana walidacja**: Wyświetla błędy walidacyjne przekazane w propsach. Przycisk zapisu jest nieaktywny, dopóki wszystkie wymagane pola nie zostaną wypełnione po stronie klienta.
- **Typy**: `ProfileEditViewModel`, `ProfileUpdateDto`.
- **Propsy**:
  - `formData: ProfileEditViewModel`
  - `isSubmitting: boolean`
  - `onFieldChange: (field: keyof ProfileUpdateDto, value: string | boolean) => void`
  - `onSubmit: () => void`

### `LocationStatus.tsx`
- **Opis komponentu**: Mały komponent informacyjny wyświetlany obok pola lokalizacji, który wizualnie komunikuje status weryfikacji geokodowania.
- **Główne elementy**: Ikona i tekst. Zmienia kolor i treść w zależności od statusu.
- **Obsługiwane interakcje**: Brak.
- **Obsługiwana walidacja**: Brak.
- **Typy**: `locationStatus: 'IDLE' | 'VERIFIED' | 'ERROR'`.
- **Propsy**:
  - `status: 'IDLE' | 'VERIFIED' | 'ERROR'`

## 5. Typy

### `Profile` (DTO)
Reprezentuje obiekt profilu zwracany przez API (`/api/profile`).
```typescript
interface Profile {
  id: string;
  user_id: string;
  username: string | null;
  location_text: string | null;
  location_geog: any | null; // Typ PostGIS
  rodo_consent: boolean | null;
  is_complete: boolean;
  avg_rating?: number;
  ratings_count?: number;
}
```

### `ProfileUpdateDto`
Reprezentuje dane wysyłane w ciele żądania `PUT /api/profile`.
```typescript
interface ProfileUpdateDto {
  username: string;
  location_text: string;
  rodo_consent: boolean;
}
```

### `ProfileEditViewModel`
Reprezentuje stan formularza w widoku, łącząc dane z informacjami o błędach i statusie UI.
```typescript
interface ProfileEditViewModel {
  username: string;
  location_text: string;
  rodo_consent: boolean;
  errors: {
    username?: string;
    location_text?: string;
    form?: string; // Błędy ogólne
  };
  locationStatus: 'IDLE' | 'VERIFIED' | 'ERROR';
}
```

## 6. Zarządzanie stanem
Logika i stan widoku zostaną scentralizowane w niestandardowym hooku `useProfileManager`.

### `useProfileManager`
- **Cel**: Abstrakcja logiki biznesowej od komponentu `ProfileEditView`.
- **Zarządzany stan**:
  - `profileData: Profile | null` - oryginalne dane z serwera.
  - `formData: ProfileEditViewModel` - aktualny stan formularza.
  - `isLoading: boolean` - status początkowego ładowania danych.
  - `isSubmitting: boolean` - status wysyłania formularza.
  - `error: string | null` - błędy krytyczne (np. problem z pobraniem danych).
- **Udostępniane funkcje**:
  - `handleFieldChange`: Aktualizuje stan `formData`.
  - `handleSubmit`: Obsługuje logikę wysyłki formularza, w tym walidację i komunikację z API.
- **Efekty uboczne**: Wywołuje `GET /api/profile` przy pierwszym renderowaniu, aby zainicjować stan formularza.

## 7. Integracja API

- **Pobieranie danych**:
  - **Endpoint**: `GET /api/profile`
  - **Moment wywołania**: Przy montowaniu komponentu `ProfileEditView`.
  - **Obsługa odpowiedzi**:
    - **200 OK**: Wypełnienie formularza danymi z odpowiedzi. Jeśli `location_geog` istnieje, `locationStatus` ustawiany jest na `'VERIFIED'`.
    - **404 Not Found**: Inicjalizacja pustego formularza (scenariusz dla nowego użytkownika).

- **Zapisywanie danych**:
  - **Endpoint**: `PUT /api/profile`
  - **Typ żądania**: `ProfileUpdateDto`
  - **Typ odpowiedzi**: `Profile`
  - **Moment wywołania**: Po kliknięciu przycisku "Zapisz" i pomyślnej walidacji klienta.
  - **Obsługa odpowiedzi**:
    - **200/201**: Wyświetlenie powiadomienia o sukcesie i przekierowanie użytkownika na stronę `/profile`.
    - **409 Conflict**: Wyświetlenie błędu walidacji przy polu `username`.
    - **422 Unprocessable Entity**: Wyświetlenie błędu przy polu `location_text` i zmiana `locationStatus` na `'ERROR'`.

## 8. Interakcje użytkownika
- **Wprowadzanie tekstu w polach `username` i `location_text`**: Aktualizuje stan formularza. Po rozpoczęciu edycji pola, ewentualny błąd walidacji dla tego pola jest czyszczony.
- **Zaznaczenie `rodo_consent`**: Aktualizuje stan. Jest to warunek konieczny do aktywacji przycisku zapisu.
- **Kliknięcie "Zapisz"**: Uruchamia proces walidacji i wysyłki. Przycisk jest zablokowany na czas operacji, a na ekranie pojawia się wskaźnik ładowania. Wynik operacji (sukces lub błąd) jest komunikowany przez toast.

## 9. Warunki i walidacja
- **Nazwa użytkownika (`username`)**:
  - Wymagane (nie może być puste po usunięciu białych znaków).
  - Unikalne (weryfikowane przez API).
- **Lokalizacja (`location_text`)**:
  - Wymagane (nie może być puste).
  - Musi być możliwe do zgeokodowania (weryfikowane przez API).
- **Zgoda RODO (`rodo_consent`)**:
  - Musi być zaznaczone (`true`).

Przycisk "Zapisz" w komponencie `ProfileForm` będzie nieaktywny (`disabled`), jeśli którykolwiek z powyższych warunków po stronie klienta nie jest spełniony.

## 10. Obsługa błędów
- **Błąd pobierania profilu**: Jeśli `GET /api/profile` zwróci błąd inny niż 404, widok wyświetli komunikat o błędzie z opcją ponowienia próby.
- **Błędy walidacji API**:
  - **409 (Username Taken)**: `formData.errors.username` zostanie ustawiony na "Ta nazwa użytkownika jest już zajęta.".
  - **422 (Geocoder Failure)**: `formData.errors.location_text` zostanie ustawiony, a `locationStatus` na `'ERROR'`.
- **Błąd serwera (5xx)**: Ogólny komunikat o błędzie zostanie wyświetlony w formularzu lub jako toast, informując użytkownika o problemie i prosząc o ponowienie próby później.
- **Błąd sieci**: Biblioteka do obsługi zapytań HTTP obsłuży błąd sieci, co poskutkuje wyświetleniem globalnego powiadomienia (toast) o problemie z połączeniem.

## 11. Kroki implementacji
1.  **Stworzenie strony Astro**: Utworzenie pliku `/src/pages/profile/edit.astro`, który będzie renderował główny komponent React.
2.  **Zaimplementowanie hooka `useProfileManager`**: Scentralizowanie w nim całej logiki zarządzania stanem, w tym funkcji do pobierania i aktualizacji profilu.
3.  **Budowa komponentu `ProfileEditView`**: Stworzenie komponentu kontenerowego, który używa hooka `useProfileManager` i zarządza renderowaniem widoku w zależności od stanu.
4.  **Budowa komponentu `ProfileForm`**: Stworzenie w pełni sterowanego, prezentacyjnego komponentu formularza z polami i przyciskiem, wykorzystując komponenty z biblioteki Shadcn/ui.
5.  **Stworzenie komponentu `LocationStatus`**: Dodanie małego komponentu do informowania o stanie weryfikacji lokalizacji.
6.  **Integracja z API**: Podłączenie logiki z `useProfileManager` do rzeczywistych wywołań API za pomocą istniejącego klienta API.
7.  **Obsługa błędów i stanu ładowania**: Implementacja wyświetlania `SkeletonLoader`, `ErrorDisplay` oraz powiadomień toast dla różnych scenariuszy.
8.  **Middleware (weryfikacja)**: Upewnienie się, że istniejący middleware w `src/middleware/index.ts` poprawnie obsługuje logikę przekierowania dla użytkowników z niekompletnym profilem (`is_complete: false`).
9.  **Testowanie manualne**: Przetestowanie wszystkich scenariuszy: ścieżka nowego użytkownika (onboarding), edycja istniejącego profilu, obsługa błędów walidacji (nazwa, lokalizacja), obsługa błędów serwera.
