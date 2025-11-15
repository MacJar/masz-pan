# Specyfikacja Techniczna - Moduł Uwierzytelniania

## 1. Wprowadzenie

### 1.1. Cel dokumentu

Niniejszy dokument opisuje architekturę i szczegóły techniczne wdrożenia modułu uwierzytelniania użytkowników w aplikacji MaszPan. Celem jest zaprojektowanie bezpiecznego, skalowalnego i zgodnego z wymaganiami PRD systemu do rejestracji, logowania, wylogowywania oraz odzyskiwania hasła.

### 1.2. Opis funkcjonalności

Moduł obejmuje następujące funkcjonalności:
-   **Rejestracja:** Tworzenie nowego konta użytkownika za pomocą adresu e-mail i hasła, z wymaganym potwierdzeniem e-mail.
-   **Logowanie:** Uwierzytelnianie użytkownika i tworzenie bezpiecznej sesji.
-   **Wylogowywanie:** Bezpieczne zakończenie sesji użytkownika.
-   **Odzyskiwanie hasła:** Proces umożliwiający użytkownikowi zresetowanie zapomnianego hasła.

### 1.3. Używane technologie

-   **Framework:** Astro 5 (w trybie Server-Side Rendering)
-   **Komponenty UI:** React 19, Shadcn/ui, Tailwind CSS
-   **Backend (BaaS):** Supabase (Auth, Postgres)
-   **Walidacja:** TypeScript 5, Zod
-   **Powiadomienia:** Sonner

---

## 2. Architektura Interfejsu Użytkownika (Frontend)

### 2.1. Zmiany w Layoutach i Komponentach Globalnych

-   **`src/layouts/Layout.astro`**:
    -   Layout pozostanie głównym kontenerem dla stron, ale będzie przekazywał informację o stanie zalogowania (lub cały obiekt użytkownika z `Astro.locals.user`) do komponentów podrzędnych, takich jak `Header`.

-   **`src/components/Header.astro`**:
    -   Komponent zostanie rozbudowany o logikę warunkowego renderowania.
    -   **Dla użytkownika niezalogowanego (non-auth):** Wyświetlane będą przyciski "Zaloguj się" i "Zarejestruj się", kierujące do odpowiednich stron.
    -   **Dla użytkownika zalogowanego (auth):** Zamiast przycisków pojawi się komponent-avatar użytkownika z menu rozwijanym (`DropdownMenu` z Shadcn/ui), zawierającym linki: "Mój profil", "Moje narzędzia", "Rezerwacje", "Tokeny" oraz przycisk "Wyloguj".

### 2.2. Nowe Strony (Astro Pages)

Zostaną utworzone dedykowane strony dla procesów autentykacji, które będą renderować odpowiednie komponenty React.

-   **`src/pages/login.astro`**: Strona logowania. Będzie zawierać komponent `LoginForm` i obsługiwać przekierowania dla użytkowników już zalogowanych.
-   **`src/pages/register.astro`**: Strona rejestracji z komponentem `RegisterForm`.
-   **`src/pages/recover-password.astro`**: Strona do inicjowania procesu odzyskiwania hasła, zawierająca `RecoverPasswordForm`.
-   **`src/pages/update-password.astro`**: Strona do ustawiania nowego hasła, dostępna z linku w e-mailu. Będzie zawierać komponent `UpdatePasswordForm`.
-   **`src/pages/auth/confirm.astro`**: Strona informująca użytkownika o konieczności potwierdzenia adresu e-mail po rejestracji.

### 2.3. Nowe Komponenty React (Client-side)

Wszystkie nowe komponenty formularzy zostaną umieszczone w nowym katalogu `src/components/auth/`. Będą one w pełni client-side (`client:only="react"`) i odpowiedzialne za interakcję z użytkownikiem oraz komunikację z backendem.

-   **`LoginForm.tsx`**: Formularz logowania (email, hasło).
-   **`RegisterForm.tsx`**: Formularz rejestracji (email, hasło, powtórz hasło).
-   **`RecoverPasswordForm.tsx`**: Formularz odzyskiwania hasła (email).
-   **`UpdatePasswordForm.tsx`**: Formularz zmiany hasła (nowe hasło, powtórz hasło).

**Cechy wspólne komponentów:**
-   **Zarządzanie stanem:** Użycie hooków React (`useState`, `useEffect`).
-   **Obsługa formularzy:** Wykorzystanie biblioteki `react-hook-form` do zarządzania stanem pól, walidacją i submisją.
-   **Walidacja:** Integracja z `zodResolver` w celu walidacji danych formularza w czasie rzeczywistym po stronie klienta na podstawie schematów Zod.
-   **Komunikacja z API:** Użycie `fetch` API do wysyłania zapytań do endpointów w `src/pages/api/auth/`.

### 2.4. Scenariusze Użytkownika i Obsługa Błędów

-   **Logowanie:**
    -   **Sukces:** Użytkownik jest przekierowywany na stronę główną (`/`) lub na stronę, z której został przekierowany do logowania (jeśli w URL-u jest parametr `redirect_to`).
    -   **Błąd:** Pod formularzem wyświetlany jest ogólny komunikat błędu, np. "Nieprawidłowy adres e-mail lub hasło".
-   **Rejestracja:**
    -   **Sukces:** Użytkownik jest przekierowywany na stronę `/auth/confirm` z informacją o konieczności sprawdzenia skrzynki e-mail.
    -   **Błąd:** Wyświetlany jest komunikat błędu, np. "Użytkownik o tym adresie e-mail już istnieje".
-   **Walidacja:** Komunikaty o błędach (np. "Pole wymagane", "Nieprawidłowy format e-mail", "Hasła muszą być identyczne") pojawiają się bezpośrednio pod odpowiednimi polami formularza, gdy tracą one focus lub po próbie wysłania formularza.
-   **Powiadomienia globalne:** Kluczowe informacje zwrotne niezwiązane z walidacją (np. "Wysłano link do odzyskiwania hasła na Twój adres e-mail") będą wyświetlane za pomocą komponentu `Toaster` z biblioteki `sonner`.

---

## 3. Logika Backendowa

### 3.1. Middleware (`src/middleware/index.ts`)

Istniejący plik middleware zostanie rozszerzony i stanie się centralnym punktem zarządzania sesją i autoryzacją.

-   **Zarządzanie sesją:** Na każde żądanie (z wyłączeniem publicznych assetów i konkretnych stron jak `/login`), middleware będzie próbował odczytać sesję użytkownika z `HttpRequest` cookies przy użyciu serwerowego klienta Supabase.
-   **Kontekst użytkownika:** Po pomyślnej weryfikacji sesji, dane użytkownika i sesji zostaną wstrzyknięte do `Astro.locals` (np. `Astro.locals.user`, `Astro.locals.session`), co udostępni je wszystkim stroną i endpointom renderowanym na serwerze.
-   **Ochrona tras:** Jeśli `Astro.locals.user` jest `null`, middleware sprawdzi, czy żądana trasa jest chroniona. Jeśli tak, nastąpi przekierowanie na stronę `/logowanie` z dodaniem parametru `redirect_to`, aby po zalogowaniu użytkownik wrócił na docelową stronę.
-   **Logika `AUTH_BYPASS`:** Istniejący mechanizm mockowania sesji dla celów deweloperskich zostanie zachowany. Będzie on wykonywany na początku middleware'a – jeśli zmienne `AUTH_BYPASS` i `AUTH_BYPASS_USER_ID` są ustawione w trybie `DEV`, zostanie utworzona mockowa sesja, a logika Supabase zostanie pominięta.

### 3.2. Nowe Endpointy API

Zostanie utworzony nowy katalog `src/pages/api/auth/` z następującymi endpointami:

-   **`POST /api/auth/login`**:
    -   Przyjmuje: `email`, `password`.
    -   Wywołuje `supabase.auth.signInWithPassword()`.
    -   W odpowiedzi Supabase ustawi w przeglądarce bezpieczne, `HttpOnly` cookie z sesją.
-   **`POST /api/auth/register`**:
    -   Przyjmuje: `email`, `password`.
    -   Wywołuje `supabase.auth.signUp()`. Supabase wyśle e-mail z linkiem potwierdzającym.
-   **`POST /api/auth/logout`**:
    -   Nie przyjmuje danych.
    -   Wywołuje `supabase.auth.signOut()`, co unieważni sesję i usunie cookie.
-   **`POST /api/auth/recover-password`**:
    -   Przyjmuje: `email`.
    -   Wywołuje `supabase.auth.resetPasswordForEmail()`, co zainicjuje wysyłkę e-maila z linkiem do zmiany hasła.
-   **`POST /api/auth/update-password`**:
    -   Endpoint ten będzie wywoływany przez Supabase po stronie serwera po kliknięciu linku w mailu. Należy go zaimplementować zgodnie z przepływem Supabase Password Reset.

### 3.3. Walidacja i Modele Danych

-   **Walidacja serwerowa:** Każdy endpoint API będzie walidował dane wejściowe przy użyciu schematów Zod, aby zapewnić integralność danych, nawet jeśli walidacja kliencka zostanie ominięta. Schematy zostaną zdefiniowane w `src/lib/schemas/auth.schema.ts`.
-   **Kontrakty Danych (DTOs):** Typy dla żądań i odpowiedzi API (np. `LoginDto`, `RegisterDto`) zostaną zdefiniowane w pliku `src/types.ts` w celu zapewnienia spójności między frontendem a backendem.

### 3.4. Obsługa Wyjątków

Endpointy API będą korzystać z ustandaryzowanego mechanizmu obsługi błędów. Błędy rzucane przez Supabase Auth (np. `AuthApiError`) będą przechwytywane i mapowane na odpowiednie kody statusu HTTP (400, 401, 409, 500) i ustrukturyzowane odpowiedzi JSON, które frontend będzie w stanie łatwo zinterpretować i wyświetlić użytkownikowi.

---

## 4. System Autentykacji (Integracja z Supabase)

### 4.1. Konfiguracja Klienta Supabase

-   **`src/db/supabase.client.ts`**: Plik zostanie zaktualizowany, aby eksportować funkcje tworzące instancje klienta Supabase:
    -   Jedna dla środowiska przeglądarki (client-side), używająca `SUPABASE_ANON_KEY`.
    -   Druga dla środowiska serwerowego (server-side, w middleware i API), która może być tworzona na podstawie kontekstu żądania (cookies).

### 4.2. Przepływ Uwierzytelniania (end-to-end)

1.  Użytkownik wypełnia formularz React (np. `LoginForm`).
2.  Po wysłaniu, komponent React wysyła żądanie `fetch` do endpointu Astro (`/api/auth/login`).
3.  Endpoint Astro (działający na serwerze) waliduje dane i wywołuje odpowiednią metodę z Supabase Auth JS SDK (`signInWithPassword`).
4.  Supabase przetwarza żądanie, a w przypadku sukcesu dołącza do odpowiedzi nagłówek `Set-Cookie` z tokenem sesji.
5.  Przeglądarka automatycznie zapisuje cookie. Przy każdym kolejnym żądaniu do domeny aplikacji, cookie będzie dołączane automatycznie.
6.  Middleware Astro odczytuje cookie, weryfikuje sesję z Supabase i udostępnia kontekst użytkownika w `Astro.locals`, chroniąc trasy i personalizując widoki.

### 4.3. Zmienne Środowiskowe

Do pliku `.env` (i `.env.example`) należy dodać następujące zmienne, które są wymagane przez Supabase:
-   `SUPABASE_URL`
-   `SUPABASE_ANON_KEY`

---

## 5. Mockowanie dla Celów Rozwojowych

-   Obecny mechanizm mockowania oparty na zmiennych `AUTH_BYPASS` i `AUTH_BYPASS_USER_ID` zostanie zachowany i zintegrowany z nową logiką.
-   W `src/middleware/index.ts` sprawdzanie tych zmiennych będzie miało najwyższy priorytet. Jeśli warunki mockowania są spełnione (środowisko `DEV` i ustawione zmienne), tworzona jest fałszywa sesja użytkownika w `Astro.locals`, a reszta logiki autentykacji (Supabase) jest pomijana.
-   Pozwoli to na płynny rozwój i testowanie komponentów wymagających zalogowanego użytkownika bez konieczności ciągłego logowania się lub posiadania skonfigurowanego projektu Supabase lokalnie.
