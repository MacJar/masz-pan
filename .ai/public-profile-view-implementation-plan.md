# Plan implementacji widoku profilu publicznego

## 1. Przegląd

Celem jest stworzenie publicznego, dostępnego dla wszystkich widoku profilu użytkownika. Widok ten będzie prezentował kluczowe, niewrażliwe informacje o użytkowniku, takie jak jego nazwa, średnia ocen wraz z ich liczbą, oraz listę aktualnie udostępnianych przez niego narzędzi. Strona ma być zoptymalizowana pod kątem SEO poprzez renderowanie po stronie serwera (SSR).

## 2. Routing widoku

Widok będzie dostępny pod dynamiczną ścieżką URL:
- **Ścieżka**: `/u/[id]`
- **Plik**: `src/pages/u/[id].astro`
- Parametr `[id]` odpowiada unikalnemu identyfikatorowi (UUID) użytkownika.

## 3. Struktura komponentów

Hierarchia komponentów dla widoku profilu publicznego będzie następująca:

```
src/pages/u/[id].astro
└── /src/components/profile/PublicProfileView.tsx
    ├── /src/components/profile/PublicProfileHeader.tsx
    ├── /src/components/profile/RatingSummary.tsx
    └── /src/components/tools/PublicToolsGrid.tsx
        └── /src/components/tools/ToolCard.tsx (istniejący)
```

## 4. Szczegóły komponentów

### `PublicProfilePage` (`[id].astro`)
- **Opis komponentu**: Strona Astro odpowiedzialna za routing, pobieranie danych na serwerze (SSR) i renderowanie głównego komponentu React (`PublicProfileView`). Ekstrahuje `id` użytkownika z URL, wywołuje API i przekazuje pobrane dane jako propsy. Obsługuje również błędy na poziomie strony (np. 404, 500).
- **Główne elementy**: `Layout`, komponent `PublicProfileView`.
- **Obsługiwane interakcje**: Brak (renderowanie serwerowe).
- **Obsługiwana walidacja**: Sprawdzenie, czy `id` z URL jest w poprawnym formacie (np. UUID) przed wywołaniem API.
- **Typy**: `PublicProfileDTO`
- **Propsy**: Brak.

### `PublicProfileView.tsx`
- **Opis komponentu**: Główny komponent React, który otrzymuje dane z serwera. Odpowiada za wyświetlanie odpowiedniego stanu widoku (dane, ładowanie, błąd) oraz organizuje renderowanie komponentów podrzędnych.
- **Główne elementy**: `PublicProfileHeader`, `RatingSummary`, `PublicToolsGrid`.
- **Obsługiwane interakcje**: Brak.
- **Obsługiwana walidacja**: Renderowanie warunkowe w zależności od otrzymanych danych (np. wyświetlanie stanu pustego, gdy nie ma narzędzi lub ocen).
- **Typy**: `PublicProfileViewModel`.
- **Propsy**:
  - `initialData: PublicProfileViewModel`

### `PublicProfileHeader.tsx`
- **Opis komponentu**: Wyświetla podstawowe informacje o użytkowniku: jego nazwę oraz opcjonalnie lokalizację.
- **Główne elementy**: Tagi `h1` dla nazwy użytkownika, `p` dla lokalizacji.
- **Obsługiwane interakcje**: Brak.
- **Obsługiwana walidacja**: Ukrywa element lokalizacji, jeśli `locationText` jest `null`.
- **Typy**: `PublicProfileViewModel`.
- **Propsy**:
  - `username: string`
  - `locationText: string | null`

### `RatingSummary.tsx`
- **Opis komponentu**: Prezentuje zagregowane informacje o ocenach użytkownika – średnią ocen oraz ich całkowitą liczbę. Może zawierać wizualizację w postaci gwiazdek.
- **Główne elementy**: Komponenty UI do wyświetlania gwiazdek, tekst z wartością średniej i liczbą ocen.
- **Obsługiwane interakcje**: Brak.
- **Obsługiwana walidacja**: Wyświetla informację "Brak ocen", gdy `ratingsCount` wynosi 0.
- **Typy**: `PublicProfileViewModel`.
- **Propsy**:
  - `avgRating: number | null`
  - `ratingsCount: number`

### `PublicToolsGrid.tsx`
- **Opis komponentu**: Renderuje siatkę z kartami narzędzi (`ToolCard`) udostępnianych przez użytkownika.
- **Główne elementy**: Kontener siatki (`grid`), pętla mapująca po liście narzędzi i renderująca komponent `ToolCard`.
- **Obsługiwane interakcje**: Kliknięcie na kartę narzędzia, które przekierowuje na stronę szczegółów narzędzia.
- **Obsługiwana walidacja**: Wyświetla informację "Użytkownik nie udostępnia żadnych narzędzi", gdy lista `activeTools` jest pusta.
- **Typy**: `ToolSummaryViewModel[]`.
- **Propsy**:
  - `tools: ToolSummaryViewModel[]`

## 5. Typy

Wymagane jest zdefiniowanie następujących, nowych typów danych w `src/types.ts` lub nowym pliku dedykowanym dla profilu.

**DTO (Data Transfer Object) - Oczekiwany z API**
```typescript
// Podsumowanie narzędzia
export interface ToolSummaryDTO {
  id: string;
  name: string;
  imageUrl: string | null;
  description: string;
}

// Publiczny profil użytkownika
export interface PublicProfileDTO {
  id: string;
  username: string;
  location_text: string | null;
  avg_rating: number | null;
  ratings_count: number;
  active_tools: ToolSummaryDTO[]; // Kluczowe rozszerzenie względem pierwotnego planu API
}
```

**ViewModel - Używane w komponentach React**
```typescript
// Podsumowanie narzędzia z polem na link
export interface ToolSummaryViewModel {
  id: string;
  name: string;
  imageUrl: string | null;
  description: string;
  href: string; // np. /tools/some-tool-id
}

// Publiczny profil użytkownika (konwencja camelCase)
export interface PublicProfileViewModel {
  id: string;
  username: string;
  locationText: string | null;
  avgRating: number | null;
  ratingsCount: number;
  activeTools: ToolSummaryViewModel[];
}
```

## 6. Zarządzanie stanem

Stan będzie zarządzany głównie na poziomie strony Astro (`[id].astro`) poprzez pobranie danych na serwerze. Komponenty React będą bezstanowe (`stateless`) i będą renderować UI na podstawie danych otrzymanych w `props`.

Nie ma potrzeby tworzenia customowego hooka na tym etapie, ponieważ wszystkie dane są dostępne od razu przy renderowaniu serwerowym. Logika pobierania danych znajdzie się w kliencie API, a jej wywołanie w pliku strony Astro.

## 7. Integracja API

Integracja z backendem wymaga stworzenia i wykorzystania nowego punktu końcowego API.

- **Endpoint**: `GET /api/profiles/:id/public`
- **Opis**: Zwraca publiczne dane profilu dla użytkownika o podanym `id`.
- **Klient API**: Należy stworzyć nową funkcję kliencką, np. `fetchPublicProfile(userId: string)` w nowym pliku `src/lib/api/profile.client.ts`.
- **Typ żądania**: Brak (dane przekazywane w URL).
- **Typ odpowiedzi ( sukces, 200 OK)**: `PublicProfileDTO`.
- **Typ odpowiedzi (błąd, 404 Not Found)**: Standardowy obiekt błędu.

**Uwaga**: Implementacja tego endpointu po stronie backendu jest warunkiem koniecznym do rozpoczęcia prac. Endpoint musi zwracać dane zgodne z typem `PublicProfileDTO`, włączając w to pole `active_tools`.

## 8. Interakcje użytkownika

- **Nawigacja do profilu**: Użytkownik wchodzi na stronę o ścieżce `/u/{userId}`. Strona ładuje się (SSR) i natychmiast wyświetla pełne dane profilu.
- **Przejście do narzędzia**: Użytkownik klika na jedną z kart narzędzi w siatce. Zostaje przekierowany na stronę szczegółów danego narzędzia (`/tools/{toolId}`).

## 9. Warunki i walidacja

- **ID użytkownika w URL**: Strona Astro (`[id].astro`) powinna zweryfikować, czy `id` pobrane z parametrów ścieżki jest w poprawnym formacie (np. UUID). W przypadku niepoprawnego formatu strona powinna od razu zwrócić błąd 404, bez odpytywania API.
- **Brak ocen**: Jeśli `ratings_count` wynosi 0, komponent `RatingSummary` wyświetli stosowny komunikat.
- **Brak narzędzi**: Jeśli tablica `active_tools` jest pusta, komponent `PublicToolsGrid` wyświetli stosowny komunikat.

## 10. Obsługa błędów

- **Użytkownik nie znaleziony (API zwraca 404)**: Strona Astro (`[id].astro`) powinna przechwycić ten błąd podczas pobierania danych na serwerze i zwrócić standardową stronę błędu 404.
- **Błąd serwera (API zwraca 5xx)**: Strona Astro powinna przechwycić błąd i zwrócić stronę błędu 500.
- **Błąd walidacji DTO**: Klient API powinien używać Zod do walidacji odpowiedzi. W przypadku niezgodności schematu, błąd powinien być traktowany jako błąd serwera.

## 11. Kroki implementacji

1. **Koordynacja z backendem**: Potwierdzenie implementacji endpointu `GET /api/profiles/:id/public` oraz upewnienie się, że jego odpowiedź zawiera pole `active_tools` z listą narzędzi.
2. **Definicja typów**: Dodanie `PublicProfileDTO`, `ToolSummaryDTO`, `PublicProfileViewModel` i `ToolSummaryViewModel` do odpowiednich plików (`src/types.ts` lub dedykowanego).
3. **Klient API**: Stworzenie funkcji `fetchPublicProfile` w `src/lib/api/profile.client.ts` do komunikacji z nowym endpointem.
4. **Struktura plików**: Utworzenie nowych plików komponentów: `src/pages/u/[id].astro`, `src/components/profile/PublicProfileView.tsx`, `src/components/profile/PublicProfileHeader.tsx`, `src/components/profile/RatingSummary.tsx` i `src/components/tools/PublicToolsGrid.tsx`.
5. **Implementacja strony Astro**: W pliku `[id].astro` zaimplementować logikę pobierania `id` z URL, wywołania `fetchPublicProfile`, obsługi błędów (404/500) i przekazania danych do `PublicProfileView`.
6. **Implementacja komponentów React**: Zgodnie ze specyfikacją zaimplementować każdy z nowych komponentów, dbając o przekazywanie propsów i obsługę stanów pustych.
7. **Stylowanie**: Ostylowanie wszystkich nowych komponentów przy użyciu Tailwind CSS, zgodnie z ogólnym designem aplikacji.
8. **Testowanie**: Ręczne przetestowanie widoku dla różnych scenariuszy:
    - Użytkownik z ocenami i narzędziami.
    - Użytkownik bez ocen.
    - Użytkownik bez narzędzi.
    - Próba wejścia na profil nieistniejącego użytkownika (oczekiwane 404).
    - Użycie niepoprawnego UUID w URL.

