# Plan implementacji widoku "Moje narzędzia"

## 1. Przegląd

Widok "Moje narzędzia" to chroniona sekcja aplikacji, która pozwala zalogowanym użytkownikom na przeglądanie i zarządzanie listą narzędzi, których są właścicielami. Celem widoku jest zapewnienie przejrzystego interfejsu do monitorowania statusu narzędzi (np. "Szkic", "Aktywne", "Zarchiwizowane") oraz wykonywania kluczowych akcji, takich jak edycja, publikacja i archiwizacja.

## 2. Routing widoku

Widok będzie dostępny pod dedykowaną, chronioną ścieżką:
- `/tools/my`

Dostęp do tej ścieżki będzie wymagał uwierzytelnienia użytkownika. Niezalogowani użytkownicy zostaną przekierowani na stronę logowania.

## 3. Struktura komponentów

Hierarchia komponentów dla tego widoku będzie następująca:

```
- MyToolsPage.astro
  - Layout.astro
    - MyToolsView.tsx (Główny komponent kliencki)
      - StatusFilter.tsx (Filtry statusu)
      - if (ładowanie) -> SkeletonList.tsx
      - if (błąd) -> ErrorState.tsx
      - if (brak narzędzi) -> EmptyState.tsx
      - if (są narzędzia) -> MyToolsList.tsx
        - ToolRow.tsx[] (Wiersz z danymi narzędzia)
          - Badge.tsx (Etykieta statusu)
          - Button.tsx (Przyciski akcji)
        - InfiniteScrollSentinel.tsx (Element do obsługi "nieskończonego przewijania")
      - ActionConfirmationDialog.tsx (Modal potwierdzający akcję)
```

## 4. Szczegóły komponentów

### `MyToolsView.tsx`

-   **Opis komponentu**: Główny kontener widoku, który zarządza stanem, komunikacją z API oraz renderowaniem komponentów podrzędnych w zależności od aktualnego stanu (ładowanie, błąd, dane, brak danych).
-   **Główne elementy**: `div` jako kontener, `StatusFilter`, `MyToolsList`, `SkeletonList`, `ErrorState`, `EmptyState`.
-   **Obsługiwane interakcje**: Zmiana aktywnego filtra statusu.
-   **Obsługiwana walidacja**: Brak.
-   **Typy**: `MyToolListItemViewModel`.
-   **Propsy**: Brak.

### `StatusFilter.tsx`

-   **Opis komponentu**: Komponent renderujący przyciski lub listę rozwijaną, umożliwiającą filtrowanie narzędzi po ich statusie.
-   **Główne elementy**: Grupa komponentów `Button` z `shadcn/ui`.
-   **Obsługiwane interakcje**: Kliknięcie na przycisk filtra.
-   **Obsługiwana walidacja**: Brak.
-   **Typy**: `ToolStatus`.
-   **Propsy**:
    -   `activeFilter: ToolStatus | 'all'`
    -   `onFilterChange: (status: ToolStatus | 'all') => void`

### `MyToolsList.tsx`

-   **Opis komponentu**: Renderuje listę narzędzi (`ToolRow`) oraz obsługuje mechanizm nieskończonego przewijania.
-   **Główne elementy**: `ul` lub `div` jako kontener listy, iteracja po `ToolRow`, `InfiniteScrollSentinel`.
-   **Obsługiwane interakcje**: Dojście do końca listy w celu załadowania kolejnej partii danych.
-   **Obsługiwana walidacja**: Brak.
-   **Typy**: `MyToolListItemViewModel[]`.
-   **Propsy**:
    -   `tools: MyToolListItemViewModel[]`
    -   `onLoadMore: () => void`
    -   `onUpdateTool: (toolId: string, newStatus: ToolStatus) => Promise<void>`

### `ToolRow.tsx`

-   **Opis komponentu**: Wyświetla informacje o pojedynczym narzędziu oraz przyciski akcji.
-   **Główne elementy**: Elementy `div`, `span` do wyświetlania nazwy i dat, komponent `Badge` (shadcn/ui) dla statusu, komponenty `Button` (shadcn/ui) dla akcji.
-   **Obsługiwane interakcje**: Kliknięcie przycisków "Edytuj", "Publikuj"/"Cofnij publikację", "Archiwizuj".
-   **Obsługiwana walidacja**: Logika biznesowa decydująca o widoczności poszczególnych przycisków (np. nie można opublikować już aktywnego narzędzia).
-   **Typy**: `MyToolListItemViewModel`.
-   **Propsy**:
    -   `tool: MyToolListItemViewModel`
    -   `onUpdate: (toolId: string, newStatus: ToolStatus) => Promise<void>`

## 5. Typy

Do implementacji widoku wymagany będzie nowy typ `ViewModel`, który dostosuje dane z API do potrzeb interfejsu.

-   **`ToolDTO` (z `src/types.ts`)**: Podstawowy obiekt danych narzędzia pobierany z API. Zakłada się, że endpoint zwróci ten pełny obiekt, a nie `ToolListItemDTO`.
-   **`ToolStatus` (z `src/types.ts`)**: `"draft" | "inactive" | "active" | "archived"`.

### Nowy typ: `MyToolListItemViewModel`

Ten typ będzie wynikiem mapowania `ToolDTO` na obiekt zoptymalizowany pod kątem logiki widoku.

-   `id`: `string` - ID narzędzia.
-   `name`: `string` - Nazwa narzędzia.
-   `status`: `ToolStatus` - Aktualny status.
-   `createdAt`: `string` - Sformatowana data utworzenia (np. "7 lis 2025").
-   `updatedAt`: `string` - Sformatowana data ostatniej modyfikacji.
-   `canPublish`: `boolean` - Flaga określająca, czy można opublikować narzędzie (status `draft`).
-   `canUnpublish`: `boolean` - Flaga określająca, czy można cofnąć publikację (status `active`).
-   `canArchive`: `boolean` - Flaga określająca, czy można zarchiwizować narzędzie (status inny niż `archived`).
-   `canEdit`: `boolean` - Flaga określająca, czy można edytować narzędzie (status inny niż `archived`).

## 6. Zarządzanie stanem

Logika zarządzania stanem, w tym pobieranie danych, filtrowanie, paginacja i akcje modyfikujące, zostanie zamknięta w dedykowanym customowym hooku `useMyToolsManager`.

### `useMyToolsManager`

-   **Cel**: Abstrakcja i centralizacja logiki komponentu `MyToolsView`.
-   **Zarządzany stan**:
    -   `tools: MyToolListItemViewModel[]` - Lista załadowanych narzędzi.
    -   `statusFilter: ToolStatus | 'all'` - Aktywny filtr.
    -   `isLoading: boolean` - Stan ładowania danych.
    -   `error: Error | null` - Obiekt błędu.
    -   `nextCursor: string | null` - Kursor do następnej strony wyników.
    -   `hasNextPage: boolean` - Czy istnieją kolejne strony do załadowania.
-   **Udostępniane funkcje**:
    -   `setStatusFilter(status)`: Zmienia filtr i resetuje listę, pobierając dane od nowa.
    -   `loadMore()`: Pobiera kolejną partię danych.
    -   `updateToolStatus(toolId, newStatus)`: Aktualizuje status narzędzia na serwerze i w lokalnym stanie.

## 7. Integracja API

Integracja z backendem będzie opierać się na dwóch głównych endpointach:

1.  **Pobieranie listy narzędzi**
    -   **Endpoint**: `GET /api/tools`
    -   **Parametry zapytania**:
        -   `owner_id=me` (wartość `me` będzie interpretowana na backendzie jako ID zalogowanego użytkownika)
        -   `status: ToolStatus` (opcjonalny, do filtrowania)
        -   `limit: number` (np. 10)
        -   `cursor: string` (opcjonalny)
    -   **Typ odpowiedzi**: `CursorPage<ToolDTO>` (zakładamy modyfikację API, by zwracało `ToolDTO`).

2.  **Aktualizacja statusu narzędzia**
    -   **Endpoint**: `PATCH /api/tools/{id}`
    -   **Typ body zapytania**: `UpdateToolCommand` (z `src/types.ts`), np. `{ "status": "active" }`.
    -   **Typ odpowiedzi**: `ToolDTO` ze zaktualizowanymi danymi.

## 8. Interakcje użytkownika

-   **Filtrowanie listy**: Użytkownik klika przycisk statusu (np. "Szkice"). Wywoływana jest funkcja `setStatusFilter`, co skutkuje nowym zapytaniem do API i odświeżeniem listy.
-   **Przewijanie listy**: Użytkownik przewija listę do końca. Komponent `InfiniteScrollSentinel` staje się widoczny, co uruchamia funkcję `loadMore` w celu doładowania kolejnych wyników.
-   **Edycja narzędzia**: Użytkownik klika "Edytuj". Następuje nawigacja do strony edycji, np. `/tools/{tool.id}/edit`.
-   **Publikacja narzędzia**: Użytkownik klika "Publikuj". Wywoływana jest funkcja `updateToolStatus` z `newStatus: 'active'`. Po pomyślnej odpowiedzi API, UI jest aktualizowane (status, dostępne akcje).
-   **Archiwizacja narzędzia**: Użytkownik klika "Archiwizuj". Otwiera się `ActionConfirmationDialog`. Po potwierdzeniu, wywoływana jest funkcja `updateToolStatus` z `newStatus: 'archived'`. Narzędzie znika z listy (jeśli filtr nie obejmuje zarchiwizowanych).

## 9. Warunki i walidacja

-   **Uwierzytelnienie**: Cały widok jest chroniony. Middleware Astro zweryfikuje sesję użytkownika przed renderowaniem strony.
-   **Uprawnienia**: API (`/api/tools`) na poziomie backendu zweryfikuje, czy żądania modyfikacji (`PATCH`) są wykonywane przez właściciela narzędzia.
-   **Logika biznesowa w UI**: Komponent `ToolRow` będzie renderował przyciski akcji warunkowo, w oparciu o `ViewModel` (np. `canPublish`, `canArchive`). Uniemożliwi to użytkownikowi wykonanie niedozwolonej akcji (np. ponowne archiwizowanie już zarchiwizowanego narzędzia).

## 10. Obsługa błędów

-   **Błąd pobierania danych**: Jeśli początkowe zapytanie `GET /api/tools` zakończy się błędem, `MyToolsView` wyświetli komponent `ErrorState` z komunikatem o błędzie i przyciskiem "Spróbuj ponownie".
-   **Błąd doładowywania danych**: W przypadku błędu podczas "nieskończonego przewijania", zostanie wyświetlone powiadomienie typu "toast" z informacją o problemie, a mechanizm `loadMore` powinien umożliwić ponowną próbę.
-   **Błąd aktualizacji narzędzia**: Jeśli operacja `PATCH` się nie powiedzie, użytkownik zobaczy powiadomienie "toast" z informacją o błędzie. Ewentualne optymistyczne aktualizacje UI zostaną cofnięte.

## 11. Kroki implementacji

1.  Utworzenie pliku strony `src/pages/tools/my.astro` i zabezpieczenie go middlewarem.
2.  Stworzenie głównego komponentu `src/components/tools/my/MyToolsView.tsx` jako punktu wejścia dla logiki klienckiej.
3.  Implementacja customowego hooka `useMyToolsManager` do zarządzania stanem i komunikacją z API.
4.  Stworzenie komponentu `src/components/tools/my/StatusFilter.tsx`.
5.  Stworzenie komponentów `src/components/tools/my/MyToolsList.tsx` i `src/components/tools/my/ToolRow.tsx`, które będą wyświetlać dane.
6.  Zdefiniowanie typu `MyToolListItemViewModel` i logiki mapującej `ToolDTO` na ten `ViewModel`.
7.  Integracja `useMyToolsManager` z `MyToolsView` w celu połączenia wszystkich elementów.
8.  Dodanie obsługi stanów ładowania (`SkeletonList`), błędu (`ErrorState`) i braku danych (`EmptyState`).
9.  Implementacja modalu potwierdzającego (`ActionConfirmationDialog`) dla akcji archiwizacji.
10. Dodanie klienta API do `src/lib/api/tools.client.ts` dla nowych operacji (pobieranie listy i aktualizacja).
11. Ostylizowanie komponentów przy użyciu Tailwind CSS i `shadcn/ui` zgodnie z projektem.

