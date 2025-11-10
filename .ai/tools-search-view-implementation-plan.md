# Plan implementacji widoku Wyszukiwanie narzędzi

## 1. Przegląd

Widok służy do wyszukiwania aktywnych narzędzi w promieniu 10 km od lokalizacji profilu użytkownika, filtrowanych po tekście. Wyniki są sortowane rosnąco po odległości i obsługują stronicowanie kursorem (infinite scroll). Wymaga ustawionej lokalizacji profilu; w przeciwnym razie użytkownik widzi baner z CTA do uzupełnienia profilu.

Zakres funkcjonalny (MVP):
- Wyszukiwanie po `q` (tekst 1–128 znaków), profil z geolokalizacją.
- Prezentacja listy wyników: nazwa narzędzia i dystans w metrach/km.
- Stronicowanie kursorem, infinite scroll, skeletony, stany Empty i Error.
- Obsługa błędów: 401 (logowanie), 400 `profile_location_missing` (CTA do profilu), 400 `validation_error`, 500.

Uwaga dot. prezentacji dodatkowych pól (cena, właściciel, ocena): obecny endpoint zwraca tylko `id`, `name`, `distance_m`. Te pola są opcjonalne w UI planie – można dodać w przyszłej iteracji po rozszerzeniu endpointu lub dołączeniu dodatkowych zapytań.

## 2. Routing widoku

- Ścieżka: `/tools/search`
- Plik strony: `src/pages/tools/search.astro` (SSR), renderujący wyspę React dla interaktywnej części.
- Query parametry (opcjonalne): `q` (string), `limit` (number), `cursor` (string; tylko programowo).
- SSR może wczytać bieżące `q` z URL i przekazać jako props do wyspy; fetch danych – po stronie klienta (z debounce).

## 3. Struktura komponentów

- `ToolsSearchPage` (Astro)
  - `ToolsSearchApp` (React island)
    - `LocationBanner` (opcjonalny baner/CTA, widoczny przy błędzie lokalizacji lub 0 wyników + pomocny tekst)
    - `SearchBar`
    - `StateContainer` (layout logiczny – przełącza widoki ładowania/pustki/błędu/listy)
      - `SkeletonList` (główne ładowanie + dogrywanie)
      - `ErrorState`
      - `EmptyState`
      - `ResultsList`
        - `ToolCard` (dla każdego wyniku)
        - `InfiniteScrollSentinel` (intersekcja/obserwator do dociągania kolejnej strony)

## 4. Szczegóły komponentów

### ToolsSearchPage (Astro)
- Opis: Kontener strony Astro; odpowiada za layout, nagłówek, breadcrumb (opcjonalnie), osadzenie wyspy React i przekazanie `initialQuery` z URL.
- Główne elementy: `Layout.astro`, wrapper `div`, osadzenie `ToolsSearchApp` z props.
- Obsługiwane interakcje: brak (tylko SSR/układ).
- Walidacja: brak.
- Typy: `{ initialQuery?: string }` – przekazywane do React.
- Propsy: `initialQuery?: string`.

### ToolsSearchApp (React)
- Opis: Orkiestruje stan wyszukiwania, wołania API, renderuje pod-komponenty, zarządza debounce i infinite scroll.
- Główne elementy: `SearchBar`, `StateContainer` (zawiera stany ładowania/błędu/pustki/listy).
- Obsługiwane interakcje:
  - Zmiana tekstu w `SearchBar` (debounce 300–500 ms).
  - Wywołanie dociągnięcia kolejnej strony przy przecięciu `InfiniteScrollSentinel`.
  - Ręczne kliknięcie „Spróbuj ponownie” w `ErrorState`.
- Walidacja:
  - Nie wykonuje zapytań, jeśli `q.trim().length < 1` lub `q.length > 128`.
  - Reset listy przy zmianie `q`.
  - Zapobiega równoległym fetchom (kontrola `isLoading`/`isLoadingMore`).
- Typy: `ToolSearchItemDTO`, `ToolSearchPageDTO`, `ApiErrorEnvelope`, `ToolSearchItemVM`, stany hooka.
- Propsy: `{ initialQuery?: string }`.

### SearchBar (React)
- Opis: Pole tekstowe + przycisk „Szukaj” (opcjonalny), debounce na onChange; validacja długości.
- Główne elementy: shadcn/ui `Input`, `Button`, etykiety; dostępność: `aria-label`, focus ring.
- Obsługiwane interakcje: `onChange(q)`, `onSubmit()` (enter/click), czyszczenie pola.
- Walidacja: `1 ≤ q.trim().length ≤ 128`; disable przy niepoprawnych danych; komunikat przy przekroczeniu limitu.
- Typy: `{ value: string; onChange(value: string): void; onSubmit(): void; isPending: boolean; }`.
- Propsy: jak wyżej.

### LocationBanner (React)
- Opis: Baner informujący o konieczności ustawienia lokalizacji profilu, z linkiem do `/profile/edit`.
- Główne elementy: `Alert`/`Callout` (shadcn/ui), `Link`/`Button` → `/profile/edit`.
- Obsługiwane interakcje: kliknięcie CTA.
- Walidacja: render tylko, gdy kod błędu `profile_location_missing` lub 0 wyników (opcjonalna wskazówka).
- Typy: `{ visible: boolean; reason?: "missing_location" | "no_results" }`.
- Propsy: jak wyżej.

### StateContainer (React)
- Opis: Abstrakcyjny kontener przełączający widok między stanami: loading, error, empty, results.
- Główne elementy: conditional rendering dzieci.
- Obsługiwane interakcje: delegowane z dzieci (`retry`, `loadMore`).
- Walidacja: logiczna spójność stanów (priorytet błędu > ładowania > pustki > listy).
- Typy: `{ status: "loading" | "error" | "empty" | "ready"; }`.
- Propsy: `{ status, children }`.

### SkeletonList (React)
- Opis: Lista placeholderów podczas ładowania pierwszej strony lub dociągania następnych.
- Główne elementy: kilka linii skeletonów (shadcn/ui `Skeleton`), różne szerokości.
- Obsługiwane interakcje: brak.
- Walidacja: brak.
- Typy/propsy: `{ count?: number }`.

### ErrorState (React)
- Opis: Prezentuje błędy domenowe/infrastrukturalne z CTA „Spróbuj ponownie” i ewentualnymi linkami (np. do profilu).
- Główne elementy: `Alert`/`Callout`, komunikat wg `error.code`.
- Obsługiwane interakcje: `onRetry()`.
- Walidacja: mapowanie kodów błędów na przyjazne komunikaty.
- Typy/propsy: `{ errorCode: string; details?: unknown; onRetry(): void }`.

### EmptyState (React)
- Opis: Pusty stan przy braku wyników; wskazówki co dalej (spróbuj później/dodaj narzędzie).
- Główne elementy: ikonografia, krótki tekst, sugestie.
- Obsługiwane interakcje: link do dodania narzędzia (gdy dostępny w aplikacji).
- Walidacja: render przy `items.length === 0`, `status === "ready"` i braku błędu.
- Typy/propsy: `{ query: string }`.

### ResultsList (React)
- Opis: Lista wyników, odpowiada za wyświetlanie, klawiszologię/focus, i sentinel do dociągania kolejnych stron.
- Główne elementy: `ul > li` z `ToolCard`, sentinel na końcu listy.
- Obsługiwane interakcje: focus, klawiatura (strzałki/Tab), klik w kartę (na razie brak szczegółów – opcjonalnie link do szczegółów narzędzia, jeśli istnieje widok).
- Walidacja: brak.
- Typy/propsy: `{ items: ToolSearchItemVM[]; onLoadMore(): void; hasNext: boolean; isLoadingMore: boolean }`.

### ToolCard (React)
- Opis: Pojedynczy wynik. MVP: nazwa i dystans (format km/m). W przyszłości: miniatura, cena, właściciel, rating.
- Główne elementy: `Card` (shadcn/ui) lub prosty kontener z Tailwind; teksty, opcjonalne ikony.
- Obsługiwane interakcje: klik (opcjonalnie nawigacja do szczegółów).
- Walidacja: brak.
- Typy/propsy: `{ item: ToolSearchItemVM }`.

### InfiniteScrollSentinel (React)
- Opis: Obserwuje przecięcie widoku z końcem listy i wyzwala `onLoadMore` jeśli `hasNext && !isLoadingMore`.
- Główne elementy: `div` z `IntersectionObserver` (hook).
- Obsługiwane interakcje: automatyczne ładowanie.
- Walidacja: zabezpieczenie przed wielokrotnym wyzwalaniem (throttle/guard flags).
- Typy/propsy: `{ onIntersect(): void; disabled: boolean }`.

## 5. Typy

Wykorzystanie typów z backendu (`src/types.ts`):
- `ToolSearchItemDTO = { id: string; name: string; distance_m: number }`
- `ToolSearchPageDTO = { items: ToolSearchItemDTO[]; next_cursor: string | null }`
- `ApiErrorDTO = { error: { code: string; message: string; details?: unknown } }`

Nowe typy ViewModel (frontend):
- `ToolSearchItemVM`:
  - `id: string`
  - `name: string`
  - `distanceMeters: number` – źródło `distance_m`
  - `distanceText: string` – sformatowana odległość (np. „850 m”, „1,2 km”)

- `ApiErrorEnvelope` (frontendowy alias do mapowania): równoważny `ApiErrorDTO` z `code` używanym do rozgałęzienia UI.

- `ToolSearchState`:
  - `query: string`
  - `items: ToolSearchItemVM[]`
  - `nextCursor: string | null`
  - `status: "idle" | "loading" | "ready" | "error"`
  - `isLoadingMore: boolean`
  - `errorCode?: string`
  - `errorDetails?: unknown`

- `ToolSearchActions`:
  - `setQuery(q: string): void`
  - `submit(): void` (opcjonalne: wymuszenie fetchu poza debounce)
  - `loadNext(): void`
  - `retry(): void`

## 6. Zarządzanie stanem

- Custom hook: `useToolSearch(initialQuery?: string)`
  - Debounce wpisywania (`useDebouncedValue` 300–500 ms).
  - `AbortController` do przerywania trwających requestów przy zmianie zapytania.
  - Reset listy przy zmianie `queryDebounced`.
  - `fetchPage({ q, limit, cursor })`:
    - Pierwsza strona: ustawia `status="loading"`, czyści `items`.
    - Kolejne strony: `isLoadingMore=true`.
    - Po sukcesie: mapuje DTO → VM (z `distanceText`), scala `items`, aktualizuje `nextCursor`, ustawia `status="ready"`.
    - Po pustej pierwszej stronie: `status="ready"` + `items=[]` (EmptyState).
    - Po błędzie: `status="error"`, `errorCode`, `errorDetails`.
  - `loadNext()`: guardy: `!nextCursor || isLoadingMore || status==="loading"` → no-op.
  - `retry()`: ponawia ostatnią operację (pierwsza strona lub dociąganie) – w praktyce najczęściej pierwszą.

## 7. Integracja API

- Endpoint: `GET /api/tools/search`
- Query params:
  - `q` (string, required, trim, 1–128)
  - `limit` (1–100, domyślnie 20)
  - `cursor` (string, opcjonalny, base64)
- Odpowiedzi:
  - `200 OK` → `ToolSearchPageDTO`
  - `400 validation_error` → błędy walidacji (nieprawidłowe `q`, `cursor`)
  - `400 profile_location_missing`
  - `401 auth_required`
  - `500 internal_error`
- Implementacja klienta (zarys):
  - `fetchTools({ q, limit, cursor }): Promise<ToolSearchPageDTO>` – buduje URLSearchParams; `fetch` z `AbortSignal`; parsowanie `response.json()`; w razie `!ok` rzutuje do `ApiErrorEnvelope`.
  - Mapowanie `ToolSearchItemDTO.distance_m` → `ToolSearchItemVM.distanceMeters` + `distanceText` (format: `< 1000 m` w metrach; `>= 1000` w km z jedną cyfrą po przecinku).

## 8. Interakcje użytkownika

- Wpisanie tekstu w `SearchBar` → po 300–500 ms bezpisania wywołanie fetch pierwszej strony (jeśli `1 ≤ q ≤ 128`).
- Enter/klik „Szukaj” → natychmiastowe fetch (pomija debounce).
- Przewinięcie listy do końca → automatyczny fetch kolejnej strony, jeśli `nextCursor != null`.
- Klik „Spróbuj ponownie” (ErrorState) → ponowny fetch pierwszej strony.
- Klik CTA w `LocationBanner` → nawigacja do `/profile/edit`.

## 9. Warunki i walidacja

- `q.trim().length < 1` → disable submit, nie wykonuj fetchu; pokaż subtelną walidację w polu.
- `q.length > 128` → komunikat walidacyjny, brak fetchu.
- Po zmianie `q` → reset listy i kursora; pierwsze zapytanie po debounce.
- `401` → komunikat o konieczności logowania; opcjonalnie link do ekranu logowania (wg polityki app).
- `profile_location_missing` → pokaż `LocationBanner` z CTA do `/profile/edit`.
- `validation_error` z API (np. niepoprawny `cursor`) → zresetuj kursora i spróbuj ponownie (bez crashu).

## 10. Obsługa błędów

- Mapa błędów:
  - `auth_required` → informacja o konieczności logowania (zachowaj wpisane `q`).
  - `profile_location_missing` → baner z CTA i opisem (zgodnie z PRD US‑021).
  - `validation_error` → toast/callout; jeśli dotyczy kursora, zresetuj stronicowanie.
  - `internal_error`/inne → ogólny callout + „Spróbuj ponownie”.
- Retry logic: `onRetry()` ponawia fetch pierwszej strony; przy nieudanym dociąganiu – zachowuje dotychczasowe `items`.
- Anulowanie: `AbortController` przy zmianie `q` – zapobiega wyścigom odpowiedzi.

## 11. Kroki implementacji

1) Routing/strona:
   - Utwórz `src/pages/tools/search.astro` z layoutem i wyspą `ToolsSearchApp`.
   - Odczytaj `q` z URL i przekaż jako `initialQuery` (opcjonalnie).

2) Hooki narzędziowe:
   - `useDebouncedValue(value, delay)` – prosty debounce.
   - `useIntersection`/`useInfiniteScroll` – hook dla sentinela (threshold ~0.1).

3) Klient API:
   - `lib/api/tools.search.client.ts` (lub w dedykowanej sekcji) z funkcją `fetchTools({ q, limit, cursor, signal })` + mapowanie DTO→VM.

4) Stan i logika:
   - `useToolSearch(initialQuery?)` – implementacja zgodnie z rozdz. 6 (statusy, guardy, aborty).

5) Komponenty UI:
   - `SearchBar` z walidacją długości i debounce.
   - `LocationBanner` (Alert + CTA).
   - `SkeletonList`, `ErrorState`, `EmptyState`.
   - `ResultsList` + `ToolCard` (MVP: nazwa + dystans).
   - `InfiniteScrollSentinel` osadzony na końcu listy.

6) Style i dostępność:
   - Tailwind 4 + shadcn/ui (`Input`, `Button`, `Alert`, `Skeleton`, `Card`).
   - ARIA dla pól/komunikatów, focus management na liście.

7) Integracja i testy manualne:
   - Sprawdź ścieżki 200/400/401/500 (devtools → Network).
   - Weryfikuj przypadki: brak `q`, za długie `q`, brak lokalizacji (symuluj/wywołaj błąd), puste wyniki.
   - Przetestuj infinite scroll i ochronę przed wielokrotnym wywołaniem.

8) (Opcjonalna przyszła iteracja)
   - Rozszerzenie endpointu o `suggested_price_tokens`, `owner.username`, `owner.avg_rating`, `thumbnail_url`.
   - Dodanie miniatury, ceny, właściciela i ratingu do `ToolCard` oraz typów VM.


