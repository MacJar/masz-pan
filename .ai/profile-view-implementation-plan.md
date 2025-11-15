# Plan implementacji widoku: Mój profil

## 1. Przegląd

Widok "Mój profil" (`/profile`) jest chronionym obszarem, gdzie użytkownicy mogą zarządzać swoimi danymi profilowymi. Dla nowych użytkowników jest to obowiązkowy krok, który muszą ukończyć po rejestracji, aby móc korzystać z aplikacji. Widok umożliwia podgląd i edycję nazwy użytkownika, lokalizacji tekstowej oraz statusu zgody RODO. Wyświetla również status geokodowania lokalizacji i zapewnia szybki dostęp do kluczowych sekcji aplikacji, takich jak "Moje narzędzia" czy "Moje rezerwacje".

## 2. Routing widoku

Widok będzie dostępny pod ścieżką `/profile`. Trasa ta musi być chroniona i dostępna wyłącznie dla zalogowanych użytkowników. Niezalogowani użytkownicy próbujący uzyskać dostęp do tej ścieżki powinni zostać przekierowani na stronę logowania. Dodatkowo, nowi użytkownicy bez uzupełnionego profilu powinni być automatycznie przekierowywani na tę stronę z innych części aplikacji.

## 3. Struktura komponentów

Komponenty zostaną zaimplementowane w React i osadzone na stronie Astro jako interaktywna wyspa.

```
- profile.astro (Strona Astro)
  - Layout.astro
    - ProfileView.tsx (Główny komponent React, `client:load`)
      - SkeletonLoader.tsx (Wyświetlany warunkowo podczas ładowania danych)
      - ErrorDisplay.tsx (Wyświetlany warunkowo w przypadku błędu ładowania)
      - ProfileForm.tsx (Formularz do edycji danych profilowych)
        - Input (shadcn/ui, dla nazwy użytkownika)
        - Input (shadcn/ui, dla lokalizacji)
        - Checkbox (shadcn/ui, dla zgody RODO)
        - Button (shadcn/ui, do zapisu zmian)
      - LocationStatus.tsx (Wyświetla status geokodowania)
      - QuickActions.tsx (Nawigacja do innych sekcji)
```

## 4. Szczegóły komponentów

### `ProfileView.tsx`

-   **Opis komponentu**: Główny kontener widoku profilu. Odpowiada za pobieranie danych profilu, zarządzanie stanem (ładowanie, błędy) i koordynację komponentów podrzędnych.
-   **Główne elementy**: Wykorzystuje `div` jako kontener. Warunkowo renderuje komponenty `SkeletonLoader`, `ErrorDisplay` lub `ProfileForm` wraz z `LocationStatus` i `QuickActions`.
-   **Obsługiwane interakcje**: Inicjuje pobieranie danych profilu przy montowaniu. Przekazuje dane i handlery do komponentów podrzędnych.
-   **Typy**: `ProfileDTO`, `ProfileViewModel`.
-   **Propsy**: Brak.

### `ProfileForm.tsx`

-   **Opis komponentu**: Interaktywny formularz do edycji danych profilu. Wykorzystuje bibliotekę `react-hook-form` z resolverem `zod` do zarządzania stanem i walidacji.
-   **Główne elementy**: `form`, komponenty `Input`, `Checkbox`, `Button` z biblioteki `shadcn/ui`. Etykiety i komunikaty o błędach.
-   **Obsługiwane interakcje**:
    -   Wprowadzanie tekstu w polach nazwy użytkownika i lokalizacji.
    -   Zaznaczanie/odznaczanie pola zgody RODO.
    -   Wysyłanie formularza przyciskiem "Zapisz".
-   **Obsługiwana walidacja**:
    -   **Nazwa użytkownika**: Wymagane, niepuste (po usunięciu białych znaków). Błąd serwera (409) o zajętej nazwie jest również wyświetlany przy tym polu.
    -   **Zgoda RODO**: Musi być zaznaczona (wymagane `true`).
-   **Typy**: `ProfileDTO` (do inicjalizacji), `ProfileUpsertCommand` (do wysyłki).
-   **Propsy**:
    -   `profile: ProfileDTO | null`: Aktualne dane profilu do wypełnienia formularza.
    -   `isSubmitting: boolean`: Informuje, czy formularz jest w trakcie przetwarzania.
    -   `onSubmit: (data: ProfileUpsertCommand) => Promise<void>`: Funkcja zwrotna wywoływana po pomyślnej walidacji i wysłaniu formularza.
    -   `fieldErrors: Record<string, string>`: Obiekt z błędami walidacji od serwera.

### `LocationStatus.tsx`

-   **Opis komponentu**: Mały, informacyjny komponent wyświetlający status geokodowania lokalizacji użytkownika.
-   **Główne elementy**: `div` z ikoną i tekstem. Kolor i treść zmieniają się w zależności od statusu.
-   **Obsługiwane interakcje**: Brak.
-   **Typy**: `GeocodingStatus` (typ enum: `'SUCCESS' | 'PENDING' | 'ERROR' | 'NOT_SET'`).
-   **Propsy**:
    -   `status: GeocodingStatus`: Aktualny status geokodowania.

### `QuickActions.tsx`

-   **Opis komponentu**: Statyczny komponent nawigacyjny zawierający linki do innych części serwisu.
-   **Główne elementy**: Kontener `div` z listą linków (`<a>` lub `Link` z Astro).
-   **Obsługiwane interakcje**: Kliknięcie w linki przenosi użytkownika do odpowiednich stron (`/tools/my`, `/reservations` itp.).
-   **Typy**: Brak.
-   **Propsy**: Brak.

## 5. Typy

### Istniejące typy (z `src/types.ts`)

-   **`ProfileDTO`**: Obiekt transferu danych (DTO) dla profilu użytkownika pobieranego z API.
    -   `id: string`
    -   `username: string | null`
    -   `location_text: string | null`
    -   `rodo_consent: boolean | null`
    -   `location_geog: string | null` (GeoJSON jako string)
    -   `last_geocoded_at: string | null`
-   **`ProfileUpsertCommand`**: DTO dla żądania `PUT` tworzącego/aktualizującego profil.
    -   `username: string`
    -   `location_text: string | null`
    -   `rodo_consent: boolean`

### Nowe typy (ViewModel i typy pomocnicze)

-   **`ProfileViewModel`**: Reprezentuje pełny stan komponentu `ProfileView`.
    -   `profile: ProfileDTO | null`: Oryginalne dane z serwera lub `null` dla nowego użytkownika.
    -   `isLoading: boolean`: `true` podczas początkowego ładowania danych.
    -   `isSubmitting: boolean`: `true` podczas wysyłania formularza.
    -   `error: string | null`: Globalny komunikat błędu (np. błąd serwera przy pobieraniu).
    -   `fieldErrors: Record<string, string>`: Błędy walidacji dla poszczególnych pól.
    -   `geocodingStatus: GeocodingStatus`: Wyprowadzony status geokodowania.
-   **`GeocodingStatus`**: Typ wyliczeniowy dla statusu geokodowania.
    -   `'SUCCESS'`: Lokalizacja poprawnie zgeokodowana.
    -   `'PENDING'`: Lokalizacja wpisana, oczekuje na geokodowanie.
    -   `'ERROR'`: Ostatnia próba geokodowania zakończyła się błędem.
    -   `'NOT_SET'`: Lokalizacja nie została jeszcze podana.

## 6. Zarządzanie stanem

Cała logika stanu zostanie zamknięta w niestandardowym hooku `useProfileManager`. Takie podejście oddziela logikę od prezentacji i ułatwia testowanie.

-   **`useProfileManager()`**:
    -   **Cel**: Zarządzanie cyklem życia danych profilu: pobieranie, aktualizacja, obsługa stanu ładowania i błędów.
    -   **Zarządzany stan**: `profile`, `isLoading`, `isSubmitting`, `error`, `fieldErrors`.
    -   **Użycie**:
        ```typescript
        const {
          profile,
          isLoading,
          isSubmitting,
          error,
          fieldErrors,
          saveProfile
        } = useProfileManager();
        ```
    -   **Funkcje**:
        -   `fetchProfile()`: Wywoływana w `useEffect` przy montowaniu komponentu. Obsługuje status 200 (istniejący profil) i 404 (nowy użytkownik).
        -   `saveProfile(command: ProfileUpsertCommand)`: Wysyła dane do API, zarządza stanem `isSubmitting` i obsługuje odpowiedzi (sukces, błędy walidacji 400, konflikt 409).

## 7. Integracja API

Należy utworzyć nowy plik kliencki `src/lib/api/profile.client.ts` do obsługi zapytań do API profilu.

-   **`GET /api/profile`**:
    -   **Funkcja kliencka**: `getProfile(): Promise<ProfileDTO>`
    -   **Użycie**: Pobranie danych zalogowanego użytkownika. Odpowiedź 404 jest traktowana jako stan "nowego użytkownika", a nie jako błąd aplikacji.
    -   **Typ odpowiedzi**: `ProfileDTO`
-   **`PUT /api/profile`**:
    -   **Funkcja kliencka**: `upsertProfile(command: ProfileUpsertCommand): Promise<ProfileDTO>`
    -   **Użycie**: Zapisanie zmian w formularzu.
    -   **Typ żądania**: `ProfileUpsertCommand`
    -   **Typ odpowiedzi**: `ProfileDTO`

## 8. Interakcje użytkownika

-   **Wejście na stronę**: Użytkownik widzi szkielet ładowania, a następnie formularz (pusty dla nowych, wypełniony dla istniejących użytkowników).
-   **Wypełnianie formularza**: Pola są aktualizowane w czasie rzeczywistym. Błędy walidacji (np. po próbie zapisu) są usuwane po rozpoczęciu edycji danego pola.
-   **Zapis (nieudany)**: Kliknięcie "Zapisz" z nieprawidłowymi danymi (np. pustą nazwą użytkownika) podświetla błędy i nie wysyła żądania do API.
-   **Zapis (udany)**: Przycisk "Zapisz" staje się nieaktywny, pojawia się wskaźnik ładowania. Po pomyślnej odpowiedzi z API wyświetlany jest komunikat toast o sukcesie, a formularz jest aktualizowany nowymi danymi.
-   **Zapis (błąd serwera)**: W przypadku błędu serwera (np. 500, 409) wyświetlany jest odpowiedni komunikat (toast dla 500, błąd pola dla 409), a przycisk "Zapisz" staje się ponownie aktywny.

## 9. Warunki i walidacja

-   **Nazwa użytkownika**: Musi być niepusta. Walidacja odbywa się po stronie klienta (przed wysłaniem) i serwera. Unikalność jest sprawdzana tylko przez serwer (obsługa błędu 409).
-   **Zgoda RODO**: Pole musi być zaznaczone (`true`). Walidacja po stronie klienta przed wysłaniem.
-   **Przycisk "Zapisz"**: Jest nieaktywny (`disabled`), gdy formularz jest w trakcie wysyłania (`isSubmitting`) lub gdy dane po stronie klienta są nieprawidłowe.

## 10. Obsługa błędów

-   **Błąd pobierania profilu**: Jeśli `GET /api/profile` zwróci błąd serwera (inny niż 404), widok wyświetli globalny komunikat o błędzie zamiast formularza.
-   **Błąd zapisu profilu (ogólny)**: Błędy 5xx podczas `PUT /api/profile` będą komunikowane za pomocą powiadomienia toast (np. "Wystąpił nieoczekiwany błąd. Spróbuj ponownie.").
-   **Błąd zapisu (konflikt nazwy)**: Błąd 409 zostanie obsłużony przez wyświetlenie komunikatu "Nazwa użytkownika jest już zajęta" bezpośrednio pod polem nazwy użytkownika.
-   **Brak połączenia z siecią**: Błędy sieciowe (np. `TypeError: Failed to fetch`) będą przechwytywane i komunikowane jako ogólny błąd zapisu.

## 11. Kroki implementacji

1.  **Utworzenie klienta API**: Stworzyć plik `src/lib/api/profile.client.ts` i zaimplementować w nim funkcje `getProfile` oraz `upsertProfile` do komunikacji z endpointami `/api/profile`.
2.  **Stworzenie strony Astro**: Utworzyć plik `src/pages/profile.astro`. Dodać podstawowy layout i osadzić w nim pusty kontener dla aplikacji React.
3.  **Implementacja hooka `useProfileManager`**: Stworzyć plik `src/components/hooks/useProfileManager.ts`. Zaimplementować w nim całą logikę zarządzania stanem, w tym funkcje `fetchProfile` i `saveProfile`.
4.  **Implementacja komponentów widoku**:
    -   Stworzyć komponent `ProfileView.tsx` jako główny kontener, który używa hooka `useProfileManager` i zarządza renderowaniem warunkowym.
    -   Stworzyć komponent `ProfileForm.tsx`, integrując go z `react-hook-form` i `zod` do walidacji. Użyć komponentów `Input`, `Checkbox`, `Button` z `shadcn/ui`.
    -   Stworzyć proste, statyczne komponenty `LocationStatus.tsx` i `QuickActions.tsx`.
5.  **Logika statusu geokodowania**: W komponencie `ProfileView.tsx` zaimplementować logikę, która na podstawie danych z `ProfileDTO` wyprowadza `GeocodingStatus` i przekazuje go do `LocationStatus.tsx`.
6.  **Middleware (jeśli konieczne)**: Zweryfikować i ewentualnie rozbudować middleware w `src/middleware/index.ts`, aby wymuszał przekierowanie na `/profile` dla nowych użytkowników bez profilu.
7.  **Stylowanie i UX**: Dopracować wygląd komponentów za pomocą Tailwind CSS, upewniając się, że stany ładowania, błędów i sukcesu są jasno komunikowane użytkownikowi (np. przez `Skeleton`, `Alert` z `shadcn/ui` i `sonner` dla toastów).
8.  **Testowanie manualne**: Przetestować wszystkie ścieżki użytkownika:
    -   Nowy użytkownik (formularz jest pusty, zapis tworzy profil).
    -   Istniejący użytkownik (formularz jest wypełniony, zapis aktualizuje profil).
    -   Przypadki błędów (pusta nazwa, zajęta nazwa, błąd serwera).

