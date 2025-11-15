---

description:

globs:

alwaysApply: false

---

# Mermaid Diagram - UI Components

Jesteś doświadczonym architektem oprogramowania, którego zadaniem jest utworzenie diagramu Mermaid w celu wizualizacji architektury stron Astro i komponentów React dla modułu logowania i rejestracji. Diagram powinien zostać utworzony w następującym pliku: DESTINATION

Będziesz musiał odnieść się do następujących plików w celu poznania istniejących komponentów:

<file_references>

@prd.md 

</file_references>

<destination>

.ai/diagrams/ui.md

</destination>

Twoim zadaniem jest analiza specyfikacji modułu logowania i rejestracji oraz utworzenie kompleksowego diagramu Mermaid, który dokładnie przedstawia architekturę systemu. Diagram powinien być w języku polskim.

Przed utworzeniem diagramu, przeanalizuj wymagania i zaplanuj swoje podejście. Umieść swoją analizę wewnątrz tagów <architecture_analysis>. W tej analizie:

1. Wypisz wszystkie komponenty wymienione w plikach referencyjnych.

2. Zidentyfikuj główne strony i ich odpowiadające komponenty.

3. Określ przepływ danych między komponentami.

4. Dostarcz krótki opis funkcjonalności każdego komponentu.

Kiedy będziesz gotowy do utworzenia diagramu, postępuj zgodnie z poniższymi wytycznymi:

1. Rozpocznij diagram od następującej składni:

   ```mermaid

   flowchart TD

   ```

2. Uwzględnij następujące elementy w swoim diagramie:

   - Zaktualizowaną strukturę UI po wdrożeniu nowych wymagań

   - Layouts, server pages i aktualizacje istniejących komponentów

   - Grupowanie elementów według funkcjonalności

   - Kierunek przepływu danych między komponentami

   - Moduły odpowiedzialne za stan aplikacji

   - Podział na komponenty współdzielone i komponenty specyficzne dla stron

   - Zależności między komponentami związanymi z autentykacją a resztą aplikacji

   - Wyróżnij komponenty, które wymagały aktualizacji ze względu na nowe wymagania

3. Przestrzegaj tych zasad składni Mermaid:

   - Używaj spójnego formatowania ID węzłów:

     ```

     A[Panel Główny] --> B[Formularz Logowania]

     B --> C[Walidacja Danych]

     ```

   - Pamiętaj, że ID węzłów rozróżniają wielkość liter i muszą być unikalne

   - Używaj poprawnych kształtów węzłów:

     - `[Tekst]` dla prostokątów

     - `(Tekst)` dla zaokrąglonych prostokątów

     - `((Tekst))` dla okręgów

     - `{Tekst}` dla rombów

     - `>Tekst]` dla flag

     - `[[Tekst]]` dla podprogramów

   - Grupuj powiązane elementy za pomocą subgrafów:

     ```

     subgraph "Moduł Autentykacji"

       A[Formularz Logowania]

       B[Walidacja Danych]

       C[Zarządzanie Sesją]

     end

     ```

   - Używaj węzłów pośrednich dla złożonych relacji zamiast skomplikowanych połączeń

   - Preferuj układ pionowy dla hierarchii i poziomy dla przepływu procesu

   - Używaj poprawnych typów połączeń:

     - `-->` dla standardowych strzałek

     - `---` dla linii bez strzałek

     - `-.->` dla linii kropkowanych ze strzałkami

     - `==>` dla grubych linii ze strzałkami

     - `--Tekst-->` dla strzałek z etykietami

   - Unikaj używania adresów URL, adresów endpointów, nawiasów, długich nazw funkcji lub złożonych wyrażeń w nazwach węzłów

   - Używaj spójnego nazewnictwa w całym dokumencie

   - Unikaj długich etykiet, które mogą powodować problemy z renderowaniem

   - Używaj cudzysłowów dla tekstu zawierającego spacje:

     ```

     A["Komponent Autentykacji"] --> B["Zarządzanie Stanem"]

     ```

   - Dla stylizacji węzłów, używaj poprawnej składni:

     ```

     A:::styleClass --> B

     ```

     z definicją klasy:

     ```

     classDef styleClass fill:#f96,stroke:#333,stroke-width:2px;

     ```

4. Unikaj tych typowych błędów:

   - Brak deklaracji sekcji Mermaid i typu diagramu na początku

   - Nieprawidłowe ID węzłów (zawierające niedozwolone znaki)

   - Niezamknięte subgrafy (brakujący "end" dla rozpoczętego "subgraph")

   - Niezamknięte nawiasy kwadratowe w opisach węzłów

   - Niespójne kierunki przepływu (mieszanie TD i LR bez uzasadnienia)

   - Zbyt złożone diagramy bez odpowiedniego grupowania

   - Nakładające się etykiety i połączenia

Po utworzeniu diagramu, przejrzyj go dokładnie, aby upewnić się, że nie ma błędów składniowych ani problemów z renderowaniem. Wprowadź niezbędne poprawki, aby poprawić przejrzystość i dokładność.

Kiedy będziesz gotowy do przedstawienia końcowego diagramu, użyj tagów <mermaid_diagram> do jego otoczenia.

<architecture_analysis>
### 1. Komponenty i Strony (Components and Pages)

*   **Strony Astro (Server Pages):**
    *   `/auth`: Strona hostująca formularz logowania, rejestracji i odzyskiwania hasła.
    *   `/profile/setup`: Strona dla nowych użytkowników do obowiązkowego uzupełnienia profilu (nazwa, lokalizacja, zgoda RODO).
    *   Strony chronione (np. `/tools/new`, `/reservations`): Dostępne tylko dla zalogowanych użytkowników z uzupełnionym profilem.
*   **Layout Astro:**
    *   `Layout.astro`: Główny layout aplikacji.
    *   `Header.astro`: Komponent nagłówka, który będzie wyświetlał przyciski "Zaloguj/Zarejestruj" dla gości oraz menu profilu i przycisk "Wyloguj" dla zalogowanych użytkowników.
*   **Komponenty React (Client-side):**
    *   `AuthForm.tsx`: Komponent-wrapper dla biblioteki `@supabase/auth-ui-react`. Odpowiedzialny za renderowanie interfejsu logowania, rejestracji i odzyskiwania hasła.
    *   `ProfileSetupForm.tsx`: Formularz do uzupełnienia danych profilowych (nazwa, lokalizacja) przez nowego użytkownika.
*   **Middleware Astro:**
    *   `src/middleware/index.ts`: Centralny punkt kontroli dostępu. Przechwytuje żądania do chronionych stron, weryfikuje sesję użytkownika i stan jego profilu.

### 2. Główne Strony i ich Komponenty (Main Pages and their Components)

*   **Strona `/auth`:** Renderuje komponent `AuthForm.tsx`.
*   **Strona `/profile/setup`:** Renderuje komponent `ProfileSetupForm.tsx`.
*   **Wszystkie strony:** Używają `Layout.astro`, który zawiera `Header.astro` do nawigacji i wyświetlania statusu logowania.

### 3. Przepływ Danych (Data Flow)

*   Użytkownik wchodzący na chronioną stronę bez aktywnej sesji jest przekierowywany przez `Middleware` na stronę `/auth`.
*   Komponent `AuthForm.tsx` komunikuje się bezpośrednio z `Supabase Auth` w celu uwierzytelnienia użytkownika.
*   Po pomyślnym logowaniu lub rejestracji, `Supabase` tworzy sesję (zapisywaną w cookies).
*   `Middleware` ponownie sprawdza sesję. Jeśli użytkownik jest nowy (profil jest niekompletny), zostaje przekierowany na `/profile/setup`.
*   Na stronie `/profile/setup`, komponent `ProfileSetupForm.tsx` wysyła dane do API, które aktualizuje profil użytkownika w bazie danych Supabase.
*   Po uzupełnieniu profilu, użytkownik uzyskuje pełen dostęp do aplikacji.
*   Komponent `Header.astro` w `Layout.astro` otrzymuje informacje o sesji z `Astro.locals` (wypełniane przez middleware) i dynamicznie renderuje odpowiednie opcje nawigacyjne.

### 4. Opis Funkcjonalności Komponentów (Component Functionality Description)

*   `AuthForm.tsx`: Zapewnia gotowy interfejs użytkownika do wszystkich operacji związanych z uwierzytelnianiem, zgodnie z rekomendacją użycia `@supabase/auth-ui-react`.
*   `ProfileSetupForm.tsx`: Umożliwia nowym użytkownikom wprowadzenie i zapisanie podstawowych danych profilowych, co jest warunkiem koniecznym do korzystania z aplikacji.
*   `Header.astro`: Odpowiada za globalną nawigację i prezentację stanu zalogowania użytkownika, dostosowując UI w zależności od obecności sesji.
*   `middleware/index.ts`: Pełni rolę strażnika (guard), chroniąc zasoby aplikacji i kierując przepływem użytkownika w zależności od jego statusu uwierzytelnienia i kompletności profilu.

</architecture_analysis>
<mermaid_diagram>
```mermaid
flowchart TD

    classDef page fill:#E6F3FF,stroke:#0066CC,stroke-width:2px;
    classDef component fill:#E6FFF3,stroke:#00994D,stroke-width:2px;
    classDef updatedComponent fill:#E6FFF3,stroke:#FF9900,stroke-width:4px;
    classDef middleware fill:#FFF2E6,stroke:#FF8000,stroke-width:2px;
    classDef supabase fill:#F9E6FF,stroke:#9900FF,stroke-width:2px;

    subgraph "Użytkownik"
        U_Guest["Gość"]
        U_Auth["Zalogowany Użytkownik"]
    end

    subgraph "Architektura Aplikacji (Astro + React)"
        
        subgraph "Middleware (Logika serwera)"
            MW["Astro Middleware (/src/middleware)"]:::middleware
        end

        subgraph "Layouts"
            Layout["Layout.astro"]:::page
            Header["Header.astro (zaktualizowany)"]:::updatedComponent
        end

        subgraph "Strony (Pages)"
            PageAuth["/auth (Logowanie/Rejestracja)"]:::page
            PageProfileSetup["/profile/setup (Wymuszone uzupełnienie profilu)"]:::page
            PageProtected["Inne strony chronione (np. /tools/new)"]:::page
        end

        subgraph "Komponenty UI (React)"
            CompAuthUI["AuthForm.tsx (wrapper na Supabase UI)"]:::component
            CompProfileForm["ProfileSetupForm.tsx"]:::component
        end

    end

    subgraph "Backend (Supabase)"
        SupabaseAuth["Supabase Auth"]:::supabase
        SupabaseDB["Baza Danych (tabela 'profiles')"]:::supabase
    end

    %% Definicja przepływów
    U_Guest -- "1. Próba dostępu do strony chronionej" --> MW
    MW -- "2. Brak sesji -> Przekierowanie" --> PageAuth
    PageAuth -- "3. Renderuje komponent" --> CompAuthUI
    U_Guest -- "4. Loguje się lub rejestruje" --> CompAuthUI
    CompAuthUI -- "5. Komunikacja z Supabase" --> SupabaseAuth
    SupabaseAuth -- "6. Tworzy sesję (cookie) i zwraca usera" --> MW

    MW -- "7a. Sesja OK, profil kompletny" --> PageProtected
    PageProtected -- "Wyświetla treść" --> U_Auth

    MW -- "7b. Sesja OK, profil niekompletny" --> PageProfileSetup
    PageProfileSetup -- "8. Renderuje formularz" --> CompProfileForm
    U_Auth -- "9. Wypełnia i wysyła formularz" --> CompProfileForm
    CompProfileForm -- "10. Zapisuje dane w bazie" --> SupabaseDB
    SupabaseDB -- "11. Profil zaktualizowany" --> PageProtected
    
    %% Przepływ w Layoucie
    Layout -- "Pobiera stan sesji z `Astro.locals`" --> Header
    Header -- "Wyświetla UI dla gościa lub zalogowanego" --> U_Guest
    Header --> U_Auth

    %% Powiązania
    Layout --> PageAuth
    Layout --> PageProfileSetup
    Layout --> PageProtected

end
```
</mermaid_diagram>
