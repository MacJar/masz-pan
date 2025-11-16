# Plan implementacji widoku Edycja Narzędzia

## 1. Przegląd

Widok "Edycja Narzędzia" umożliwia właścicielowi modyfikację szczegółów swojego narzędzia, zarządzanie zdjęciami oraz archiwizację. Widok ten wykorzystuje istniejące komponenty, takie jak formularz dodawania narzędzia, dostosowując je do potrzeb edycji istniejących danych. Zapewnia spójność z procesem tworzenia nowego narzędzia, jednocześnie wprowadzając funkcje specyficzne dla zarządzania istniejącym zasobem.

## 2. Routing widoku

Widok będzie dostępny pod chronioną ścieżką, dostępną tylko dla zalogowanego właściciela narzędzia:

- **Ścieżka**: `/tools/:id/edit`

## 3. Struktura komponentów

Hierarchia komponentów dla widoku edycji narzędzia będzie następująca:

```
/pages/tools/[id]/edit.astro
└── EditToolView.tsx (client:load)
    ├── StateContainer.tsx (Zarządzanie stanami ładowania/błędu)
    │   ├── ToolForm.tsx
    │   │   ├── ui/Input (nazwa)
    │   │   ├── ui/Textarea (opis)
    │   │   ├── ui/Input (sugerowana cena)
    │   │   └── ui/Button (zapisz zmiany)
    │   ├── ImageManager.tsx
    │   │   ├── ImageUploader.tsx
    │   │   └── SortableImageList.tsx (z przyciskami do usuwania)
    │   └── DangerZone.tsx
    │       ├── ui/Button (Archiwizuj)
    │       └── ui/ActionConfirmationDialog.tsx (Potwierdzenie)
    └── PublishCallout.tsx (jeśli narzędzie jest w stanie 'draft')
```

## 4. Szczegóły komponentów

### `EditToolView.tsx`

- **Opis komponentu**: Główny komponent widoku, odpowiedzialny za pobranie danych narzędzia, zarządzanie stanem i koordynację akcji (zapis, archiwizacja). Będzie renderowany po stronie klienta.
- **Główne elementy**: Wykorzystuje `StateContainer` do obsługi stanu ładowania i błędów. Renderuje `ToolForm`, `ImageManager` i `DangerZone`.
- **Obsługiwane interakcje**:
    - Pobranie danych narzędzia po załadowaniu komponentu.
    - Przekazanie danych do `ToolForm` i `ImageManager`.
    - Obsługa zapisu zmian z `ToolForm`.
    - Obsługa archiwizacji z `DangerZone`.
- **Typy**: `ToolWithImagesDTO`
- **Propsy**: `toolId: string`

### `ToolForm.tsx` (rozszerzony)

- **Opis komponentu**: Formularz do edycji podstawowych danych narzędzia. Będzie to ten sam komponent, co w widoku tworzenia narzędzia, ale z możliwością inicjalizacji danymi istniejącego narzędzia.
- **Główne elementy**: `Input` dla nazwy i ceny, `Textarea` dla opisu, `Button` do zapisu.
- **Obsługiwane interakcje**: `onSubmit`, `onFieldChange`.
- **Obsługiwana walidacja**:
    - `name`: Wymagane, niepuste.
    - `description`: Opcjonalne.
    - `suggested_price_tokens`: Wymagane, liczba całkowita dodatnia.
- **Typy**: `UpdateToolCommand` (dla danych formularza), `ToolWithImagesDTO` (dla danych początkowych).
- **Propsy**:
    - `initialData?: ToolWithImagesDTO`
    - `onSubmit: (data: UpdateToolCommand) => void`
    - `isSubmitting: boolean`

### `ImageManager.tsx`

- **Opis komponentu**: Komponent do zarządzania zdjęciami narzędzia. Umożliwia dodawanie nowych zdjęć, usuwanie istniejących oraz zmianę ich kolejności.
- **Główne elementy**: `ImageUploader` do dodawania plików, `SortableImageList` do wyświetlania i zarządzania listą zdjęć.
- **Obsługiwane interakcje**: Przeciągnij i upuść (`drag-and-drop`) do zmiany kolejności, kliknięcie przycisku "usuń", wybór plików do wgrania.
- **Typy**: `ToolImageDTO[]`.
- **Propsy**:
    - `images: ToolImageDTO[]`
    - `toolId: string`
    - `onImagesChange: (images: ToolImageDTO[]) => void`

### `DangerZone.tsx`

- **Opis komponentu**: Sekcja dla akcji destrukcyjnych, w tym przypadku archiwizacji narzędzia.
- **Główne elementy**: Przycisk "Archiwizuj", który otwiera modal z potwierdzeniem `ActionConfirmationDialog`.
- **Obsługiwane interakcje**: Kliknięcie przycisku archiwizacji.
- **Typy**: Wymaga `toolId` oraz `status` narzędzia.
- **Propsy**:
    - `toolId: string`
    - `toolStatus: ToolStatus`
    - `onArchive: () => void`

## 5. Typy

Do implementacji widoku wymagane będą następujące, już istniejące, typy:

- **`ToolWithImagesDTO`**: Główny obiekt danych dla widoku, zawierający szczegóły narzędzia oraz listę powiązanych zdjęć.
  ```typescript
  export type ToolWithImagesDTO = ToolDTO & { images: ToolImageDTO[] };
  ```
- **`UpdateToolCommand`**: Obiekt transferu danych (DTO) wysyłany do API podczas aktualizacji narzędzia.
  ```typescript
  export type UpdateToolCommand = z.infer<typeof UpdateToolCommandSchema>;
  // { name?: string; description?: string; suggested_price_tokens?: number; }
  ```
- **`ToolImageDTO`**: Reprezentacja pojedynczego zdjęcia narzędzia.
  ```typescript
  export type ToolImageDTO = Row<"tool_images">;
  ```

## 6. Zarządzanie stanem

Stan widoku będzie zarządzany lokalnie w komponencie `EditToolView.tsx` przy użyciu hooków React. W celu hermetyzacji logiki i oddzielenia jej od warstwy prezentacji, zostanie stworzony dedykowany custom hook `useToolEditor`.

- **`useToolEditor(toolId: string)`**:
    - **Cel**: Zarządzanie cyklem życia danych w widoku: pobieranie, aktualizacja, archiwizacja oraz obsługa stanów ładowania i błędów.
    - **Zwracane wartości**:
      ```typescript
      {
        tool: ToolWithImagesDTO | null;
        isLoading: boolean;
        isSubmitting: boolean;
        error: string | null;
        updateTool: (data: UpdateToolCommand) => Promise<void>;
        archiveTool: () => Promise<void>;
        deleteImage: (imageId: string) => Promise<void>;
        reorderImages: (images: ToolImageDTO[]) => Promise<void>;
        // ... inne funkcje do zarządzania zdjęciami
      }
      ```

## 7. Integracja API

Integracja z API będzie realizowana poprzez wywołania do istniejących i nowych endpointów:

-   **Pobranie danych narzędzia**:
    -   `GET /api/tools/:id`
    -   **Odpowiedź**: `ToolWithImagesDTO`
-   **Aktualizacja danych narzędzia**:
    -   `PATCH /api/tools/:id`
    -   **Żądanie**: `UpdateToolCommand`
    -   **Odpowiedź**: `ToolDTO` (zaktualizowane narzędzie)
-   **Usunięcie zdjęcia**:
    -   `DELETE /api/tools/:id/images/:imageId`
    -   **Odpowiedź**: `204 No Content`
-   **Archiwizacja narzędzia**:
    -   `POST /api/tools/:id/archive` (mapowane na RPC `archive_tool`)
    -   **Odpowiedź**: `{ archivedAt: string }`
-   **Zmiana kolejności zdjęć** (wymaga nowego endpointu):
    -   `PATCH /api/tools/:id/images/order`
    -   **Żądanie**: `{ imageIds: string[] }`
    -   **Odpowiedź**: `ToolImageDTO[]` (zaktualizowana lista zdjęć)

## 8. Interakcje użytkownika

-   **Ładowanie widoku**: Użytkownik widzi szkielet interfejsu (`Skeleton`), a następnie formularz wypełniony danymi narzędzia.
-   **Edycja pól formularza**: Zmiany w polach są odzwierciedlane w stanie komponentu. Przycisk zapisu staje się aktywny.
-   **Zapis zmian**: Kliknięcie "Zapisz zmiany" blokuje formularz, wyświetla wskaźnik ładowania i wysyła żądanie `PATCH`. Po sukcesie wyświetlany jest komunikat toast.
-   **Usunięcie zdjęcia**: Kliknięcie ikony usunięcia na zdjęciu wyświetla modal z prośbą o potwierdzenie. Po potwierdzeniu zdjęcie znika z listy.
-   **Zmiana kolejności zdjęć**: Użytkownik przeciąga zdjęcie w nowe miejsce. Zmiana jest widoczna w UI i zapisywana w stanie lokalnym. Zapisana kolejność zostanie wysłana do API przy zapisie głównych zmian.
-   **Archiwizacja**: Kliknięcie "Archiwizuj" otwiera modal z ostrzeżeniem. Po potwierdzeniu, jeśli operacja się powiedzie, użytkownik jest przekierowywany na listę swoich narzędzi (`/tools/my`).

## 9. Warunki i walidacja

-   **Formularz (`ToolForm`)**:
    -   `name`: Musi być niepustym ciągiem znaków. Komunikat "Nazwa jest wymagana" pojawi się, jeśli pole będzie puste.
    -   `suggested_price_tokens`: Musi być liczbą całkowitą większą od 0. Walidacja po stronie klienta zablokuje wprowadzenie nieprawidłowych wartości.
-   **Zdjęcia (`ImageManager`)**:
    -   Próba wgrania pliku o nieprawidłowym typie lub rozmiarze zostanie zablokowana na poziomie klienta z odpowiednim komunikatem.
-   **Przycisk "Zapisz zmiany"**: Jest nieaktywny, jeśli formularz jest w stanie `pristine` (brak zmian) lub jeśli walidacja pól nie przechodzi.

## 10. Obsługa błędów

-   **404 (Nie znaleziono narzędzia)** / **403 (Brak uprawnień)**: Widok wyświetli centralny komunikat o błędzie informujący użytkownika o problemie.
-   **422 (Błędy walidacji po stronie serwera)**: Komunikaty o błędach zostaną wyświetlone pod odpowiednimi polami formularza.
-   **Błąd archiwizacji (aktywne rezerwacje)**: Po próbie archiwizacji pojawi się komunikat `Alert` lub toast, wyjaśniający, że operacja jest niemożliwa z powodu aktywnych rezerwacji.
-   **Błędy sieciowe**: Generyczny komunikat o błędzie zostanie wyświetlony, sugerując próbę ponowienia akcji.

## 11. Kroki implementacji

1.  **Stworzenie strony i komponentu widoku**: Utworzenie pliku `/pages/tools/[id]/edit.astro` oraz głównego komponentu `/src/components/tools/edit/EditToolView.tsx`.
2.  **Implementacja custom hooka `useToolEditor`**: Zawarcie w nim logiki do pobierania danych (`GET /api/tools/:id`) oraz podstawowej obsługi stanu ładowania i błędów.
3.  **Adaptacja `ToolForm.tsx`**: Modyfikacja komponentu, aby przyjmował `initialData` i poprawnie inicjalizował swój stan. Podłączenie go do `EditToolView`.
4.  **Implementacja logiki aktualizacji**: Dodanie funkcji `updateTool` w hooku, która będzie wywoływać `PATCH /api/tools/:id` i obsługiwać odpowiedź.
5.  **Stworzenie `ImageManager.tsx`**: Implementacja komponentu do wyświetlania, usuwania i wgrywania zdjęć. Na tym etapie zmiana kolejności będzie tylko wizualna.
6.  **Stworzenie `DangerZone.tsx`**: Implementacja komponentu z przyciskiem do archiwizacji i dialogiem potwierdzającym.
7.  **Implementacja logiki archiwizacji**: Dodanie funkcji `archiveTool` w hooku, która wywoła odpowiedni endpoint i obsłuży przekierowanie lub błąd.
8.  **Implementacja zmiany kolejności zdjęć**:
    -   Zgłoszenie potrzeby stworzenia endpointu `PATCH /api/tools/:id/images/order`.
    -   Dodanie logiki do zapisywania nowej kolejności zdjęć w `useToolEditor`.
9.  **Finalizacja obsługi błędów i stanów UI**: Upewnienie się, że wszystkie stany (ładowanie, błędy, sukces) są poprawnie komunikowane użytkownikowi za pomocą komponentów `Skeleton`, `Alert`, `Toast`.
10. **Testowanie manualne**: Przejście przez wszystkie ścieżki użytkownika, włączając przypadki brzegowe.


