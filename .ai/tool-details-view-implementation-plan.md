# Plan implementacji widoku – Szczegóły Narzędzia

## 1. Przegląd

Widok "Szczegóły Narzędzia" ma za zadanie prezentować kompletne informacje o wybranym narzędziu. Umożliwia potencjalnemu pożyczającemu zapoznanie się ze szczegółami przedmiotu, jego zdjęciami, ceną oraz reputacją właściciela. Dla właściciela narzędzia, widok ten stanowi punkt wyjścia do zarządzania ofertą. Jest to kluczowy ekran w procesie podejmowania decyzji o wypożyczeniu.

## 2. Routing widoku

Widok będzie dostępny pod dynamiczną ścieżką URL, gdzie `[id]` to unikalny identyfikator UUID narzędzia.

- **Ścieżka**: `/tools/[id]`
- **Przykład**: `/tools/123e4567-e89b-12d3-a456-426614174000`

## 3. Struktura komponentów

Widok zostanie zaimplementowany jako strona Astro (`.astro`), która renderuje po stronie serwera główny komponent React. Taka architektura zapewnia szybkie pierwsze załadowanie (FCP) i korzyści SEO, jednocześnie umożliwiając dynamiczną interaktywność po stronie klienta.

```
/src/pages/tools/[id].astro
└── /src/components/tools/ToolDetailsView.tsx (client:load)
    ├── /src/components/tools/ImageGallery.tsx
    ├── /src/components/tools/ToolInfo.tsx
    │   └── /src/components/ui/badge.tsx (shadcn)
    ├── /src/components/tools/OwnerBadge.tsx
    │   └── /src/components/ui/StarRating.tsx (display-only)
    └── /src/components/tools/ActionBar.tsx
        └── /src/components/ui/button.tsx (shadcn)
```

## 4. Szczegóły komponentów

### ToolDetailsPage (`[id].astro`)
- **Opis**: Główny plik strony Astro. Odpowiada za pobranie `id` narzędzia z URL, wykonanie zapytania po stronie serwera po dane narzędzia i przekazanie ich jako `props` do komponentu React. Obsługuje również błędy 404, jeśli narzędzie nie zostanie znalezione.
- **Główne elementy**:
  - `Layout.astro` jako główny szablon strony.
  - Komponent `<ToolDetailsView />` z atrybutem `client:load` do hydracji po stronie klienta.
- **Obsługiwane zdarzenia**: Brak (logika po stronie serwera).
- **Warunki walidacji**:
  - Sprawdzenie, czy `id` z URL jest poprawnym UUID.
  - Weryfikacja, czy narzędzie o danym `id` istnieje; w przeciwnym razie zwrot strony 404.
- **Typy**: `ToolWithImagesDTO`.
- **Propsy**: Brak.

### ToolDetailsView (`ToolDetailsView.tsx`)
- **Opis**: Główny komponent React, który agreguje wszystkie podkomponenty widoku. Otrzymuje dane narzędzia jako `props` od Astro, a następnie po stronie klienta dociąga dane o profilu właściciela. Zarządza stanem ładowania i błędów dla danych właściciela.
- **Główne elementy**: `ImageGallery`, `ToolInfo`, `OwnerBadge`, `ActionBar`.
- **Obsługiwane zdarzenia**: Brak (deleguje do `ActionBar`).
- **Warunki walidacji**: Brak (deleguje do `ActionBar`).
- **Typy**: `ToolDetailsViewModel`.
- **Propsy**:
  - `initialToolData: ToolWithImagesDTO`
  - `currentUserId: string | null`

### ImageGallery (`ImageGallery.tsx`)
- **Opis**: Wyświetla zdjęcia narzędzia w formie karuzeli lub siatki. Obsługuje przypadek braku zdjęć, wyświetlając placeholder.
- **Główne elementy**: Elementy `<img>` lub komponent karuzeli.
- **Obsługiwane zdarzenia**: Nawigacja między zdjęciami (jeśli jest to karuzela).
- **Warunki walidacji**: Brak.
- **Typy**: `ToolImageDTO[]`.
- **Propsy**:
  - `images: ToolImageDTO[]`
  - `toolName: string` (dla atrybutów `alt`).

### ToolInfo (`ToolInfo.tsx`)
- **Opis**: Komponent prezentacyjny, wyświetlający podstawowe informacje o narzędziu: nazwę, opis, status oraz sugerowaną cenę w tokenach.
- **Główne elementy**: Nagłówki `<h1>`, paragrafy `<p>`, komponent `<Badge />` (z shadcn) dla ceny i statusu.
- **Obsługiwane zdarzenia**: Brak.
- **Warunki walidacji**: Brak.
- **Typy**: `ToolDTO`.
- **Propsy**:
  - `name: string`
  - `description: string | null`
  - `status: ToolStatus`
  - `suggestedPrice: number | null`

### OwnerBadge (`OwnerBadge.tsx`)
- **Opis**: Wyświetla skondensowane informacje o właścicielu: jego nazwę użytkownika, średnią ocenę w formie gwiazdek oraz liczbę otrzymanych ocen. Całość jest linkiem do publicznego profilu właściciela.
- **Główne elementy**: Link `<a>`, komponent `StarRating` (tylko do wyświetlania), tekst z nazwą użytkownika i liczbą ocen.
- **Obsługiwane zdarzenia**: Kliknięcie przenoszące do profilu użytkownika.
- **Warunki walidacji**: Brak.
- **Typy**: `PublicProfileDTO`.
- **Propsy**:
  - `owner: PublicProfileDTO`
  - `isLoading: boolean`
  - `error: Error | null`

### ActionBar (`ActionBar.tsx`)
- **Opis**: Komponent warunkowy, który renderuje odpowiedni przycisk akcji w zależności od kontekstu użytkownika i statusu narzędzia.
- **Główne elementy**: Komponent `<Button />` (z shadcn).
- **Obsługiwane zdarzenia**: `onClick` na przycisku.
- **Warunki walidacji**:
  - Jeśli `currentUserId === ownerId`, renderuje przycisk "Edytuj".
  - Jeśli `currentUserId !== ownerId` ORAZ `toolStatus === 'available'`, renderuje przycisk "Zgłoś zapytanie".
  - Jeśli `toolStatus !== 'available'`, przycisk "Zgłoś zapytanie" jest wyłączony (`disabled`).
- **Typy**: `ToolStatus`.
- **Propsy**:
  - `ownerId: string`
  - `currentUserId: string | null`
  - `toolStatus: ToolStatus`
  - `onReservationRequest: () => void`

## 5. Typy

Do implementacji widoku, oprócz istniejących DTO, potrzebny będzie nowy `ViewModel`, który połączy dane z dwóch różnych źródeł API w jeden spójny obiekt.

### `ToolDetailsViewModel`
Ten typ będzie używany w głównym komponencie `ToolDetailsView.tsx` do zarządzania wszystkimi danymi potrzebnymi do wyrenderowania widoku.

```typescript
import type { ToolWithImagesDTO, PublicProfileDTO } from "../../../../types";

// ViewModel łączący dane o narzędziu i jego właścicielu
export interface ToolDetailsViewModel {
  tool: ToolWithImagesDTO;
  owner: PublicProfileDTO;
}

// Struktura szczegółowa:
//
// tool: {
//   id: string;
//   name: string;
//   description: string | null;
//   owner_id: string;
//   status: "available" | "unavailable" | "archived";
//   suggested_price_tokens: number | null;
//   images: {
//     storage_key: string;
//     position: number;
//     // ... inne pola
//   }[];
// };
// owner: {
//   id: string;
//   username: string | null;
//   avg_rating: number | null;
//   ratings_count: number | null;
//   // ... inne pola
// };
```

## 6. Zarządzanie stanem

Stan będzie zarządzany głównie w komponencie `ToolDetailsView.tsx` przy użyciu wbudowanych hooków React. Rekomendowane jest stworzenie dedykowanego hooka `useOwnerProfile` do hermetyzacji logiki pobierania danych właściciela.

### Custom Hook: `useOwnerProfile`
- **Cel**: Zarządzanie cyklem życia zapytania o publiczny profil właściciela narzędzia (ładowanie, błąd, dane).
- **Stan wewnętrzny**:
  - `owner: PublicProfileDTO | null`
  - `isLoading: boolean`
  - `error: Error | null`
- **Logika**: Używa `useEffect` do wywołania zapytania API, gdy otrzyma `ownerId`. Aktualizuje stan w zależności od odpowiedzi serwera.
- **Użycie**: `const { owner, isLoading, error } = useOwnerProfile(tool.owner_id);`

## 7. Integracja API

Widok wymaga integracji z dwoma endpointami API.

1.  **Pobranie danych narzędzia (SSR)**
    - **Endpoint**: `GET /api/tools/:id`
    - **Wywołanie**: Po stronie serwera w pliku `[id].astro`.
    - **Typ odpowiedzi**: `ToolWithImagesDTO`
    - **Opis**: Astro pobiera dane narzędzia i przekazuje je jako `props` do komponentu React.

2.  **Pobranie danych właściciela (CSR)**
    - **Endpoint**: `GET /api/users/:id/profile` (założenie: ten endpoint zostanie stworzony, aby zwracać `PublicProfileDTO`, co jest bardziej wydajne niż osobne zapytania o profil i rating).
    - **Wywołanie**: Po stronie klienta, wewnątrz hooka `useOwnerProfile`.
    - **Typ odpowiedzi**: `PublicProfileDTO`
    - **Opis**: Po zamontowaniu komponentu React, wywoływane jest zapytanie o dane właściciela. W trakcie ładowania `OwnerBadge` wyświetla stan `loading`.

## 8. Interakcje użytkownika

- **Przeglądanie galerii**: Użytkownik może przeglądać zdjęcia narzędzia.
- **Kliknięcie w odznakę właściciela**: Użytkownik jest przenoszony na stronę publicznego profilu właściciela (`/u/:id`).
- **Kliknięcie "Zgłoś zapytanie"**: Użytkownik (niebędący właścicielem) inicjuje proces rezerwacji (np. przejście do nowej strony `/tools/:id/reserve`).
- **Kliknięcie "Edytuj"**: Użytkownik (będący właścicielem) jest przenoszony do formularza edycji narzędzia.

## 9. Warunki i walidacja

- **Rola użytkownika (Właściciel vs Gość)**: Komponent `ActionBar` weryfikuje, czy `currentUserId` jest równe `tool.owner_id`. Na tej podstawie renderuje odpowiedni przycisk ("Edytuj" lub "Zgłoś zapytanie"). Ta informacja musi być przekazana z serwera (Astro `locals`).
- **Status narzędzia**: `ActionBar` sprawdza `tool.status`. Jeśli status jest inny niż `'available'`, przycisk "Zgłoś zapytanie" jest nieaktywny (`disabled`), aby uniemożliwić rezerwację niedostępnego narzędzia.

## 10. Obsługa błędów

- **Narzędzie nie znalezione (404)**: Serwer (Astro) powinien zwrócić dedykowaną stronę błędu 404.
- **Błąd serwera przy pobieraniu narzędzia (500)**: Serwer (Astro) powinien zwrócić stronę błędu 500.
- **Błąd pobierania danych właściciela**: Komponent `OwnerBadge` wyświetli komunikat o błędzie (np. "Nie udało się załadować danych właściciela") lub wersję UI bez tych danych. Reszta strony pozostaje funkcjonalna.
- **Brak zdjęć**: Komponent `ImageGallery` wyświetli domyślny obrazek (placeholder).
- **Brak danych właściciela**: Jeśli dane właściciela nie zostaną załadowane, `OwnerBadge` wyświetli stan pusty lub informację o braku danych.

## 11. Kroki implementacji

1.  **Stworzenie struktury plików**: Utworzenie plików `/src/pages/tools/[id].astro` oraz komponentów React w katalogu `/src/components/tools/`, np. w podfolderze `ToolDetails`.
2.  **Implementacja strony Astro (`[id].astro`)**:
    - Dodanie logiki pobierania `id` z `Astro.params`.
    - Implementacja serwerowego wywołania API w celu pobrania danych narzędzia (`ToolWithImagesDTO`).
    - Obsługa błędu 404 w przypadku braku narzędzia.
    - Przekazanie pobranych danych oraz `currentUserId` jako `props` do komponentu `ToolDetailsView`.
3.  **Stworzenie typów `ViewModel`**: Zdefiniowanie interfejsu `ToolDetailsViewModel`.
4.  **Implementacja komponentów prezentacyjnych**: Stworzenie komponentów `ImageGallery`, `ToolInfo` i `OwnerBadge` (w stanie ładowania/błędu).
5.  **Implementacja hooka `useOwnerProfile`**: Zaimplementowanie logiki pobierania danych o właścicielu, wraz z zarządzaniem stanem ładowania i błędu.
6.  **Implementacja komponentu `ToolDetailsView`**: Zintegrowanie wszystkich podkomponentów, przekazanie im `props` oraz wywołanie hooka `useOwnerProfile`.
7.  **Implementacja `ActionBar`**: Dodanie logiki warunkowej renderującej odpowiednie przyciski na podstawie `propsów`.
8.  **Stylowanie**: Ostylowanie wszystkich komponentów przy użyciu Tailwind CSS, zgodnie z design systemem.
9.  **Testowanie**: Manualne przetestowanie wszystkich scenariuszy: widok gościa, widok właściciela, narzędzie niedostępne, błędy API, brak zdjęć.
10. **Backend (jeśli konieczne)**: Upewnienie się, że istnieje endpoint `GET /api/users/:id/profile` zwracający `PublicProfileDTO` lub modyfikacja `GET /api/tools/:id` w celu dołączenia tych danych.


