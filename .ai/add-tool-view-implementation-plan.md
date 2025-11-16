# Plan implementacji widoku: Dodawanie Narzędzia

## 1. Przegląd
Celem tego widoku jest umożliwienie zalogowanemu użytkownikowi dodania nowego narzędzia do katalogu. Proces jest podzielony na dwa główne etapy:
1.  **Tworzenie wersji roboczej (draft)**: Użytkownik wypełnia formularz z danymi narzędzia (nazwa, opis, cena) i dodaje zdjęcia. Zmiany są zapisywane automatycznie w tle.
2.  **Publikacja**: Gdy wersja robocza jest kompletna (zawiera co najmniej jedno zdjęcie i poprawną nazwę), użytkownik może opublikować narzędzie, co czyni je widocznym dla innych.

Widok będzie zawierał interaktywny formularz, system przesyłania i przetwarzania zdjęć po stronie klienta oraz integrację z API do generowania opisów przez AI.

## 2. Routing widoku
- **Ścieżka**: `/tools/new`
- **Ochrona**: Widok musi być chroniony i dostępny tylko dla zalogowanych użytkowników. Odpowiednie przekierowanie do strony logowania powinno być obsługiwane przez middleware.

## 3. Struktura komponentów
Hierarchia komponentów zostanie zorganizowana w następujący sposób, gdzie główny komponent React (`NewToolView`) zarządza stanem i logiką.

```
- NewToolPage.astro        (Strona Astro, renderuje komponent React)
  - NewToolView.tsx        (Główny komponent React, właściciel stanu)
    - ToolForm.tsx         (Formularz z polami tekstowymi)
      - AIDescribeButton.tsx (Przycisk do generowania opisu AI)
    - ImageUploader.tsx    (Komponent do przesyłania i zarządzania zdjęciami)
    - PublishCallout.tsx   (Sekcja z przyciskiem do publikacji i warunkami)
```

## 4. Szczegóły komponentów

### `NewToolView.tsx`
- **Opis**: Główny kontener widoku. Inicjuje tworzenie wersji roboczej narzędzia przy montowaniu, zarządza całym stanem formularza (`ToolFormViewModel`) i orkiestruje wywołania API.
- **Główne elementy**: Renderuje komponenty `ToolForm`, `ImageUploader` i `PublishCallout`, przekazując im odpowiednie propsy i listenery.
- **Obsługiwane interakcje**:
  - Inicjowanie tworzenia wersji roboczej narzędzia.
  - Agregowanie i delegowanie zmian stanu z komponentów podrzędnych.
  - Obsługa logiki publikacji.
- **Typy**: `ToolFormViewModel`
- **Propsy**: Brak.

### `ToolForm.tsx`
- **Opis**: Kontrolowany komponent formularza dla pól tekstowych narzędzia.
- **Główne elementy**:
  - `Input` dla nazwy narzędzia (z `shadcn/ui`).
  - `Textarea` dla opisu narzędzia (z `shadcn/ui`).
  - `AIDescribeButton.tsx` zintegrowany z polem opisu.
  - `Input type="number"` dla sugerowanej ceny w żetonach.
- **Obsługiwane interakcje**: `onChange` dla każdego pola, które jest propagowane do `NewToolView`.
- **Obsługiwana walidacja**:
  - **Nazwa**: Pole wymagane, nie może być puste.
  - **Sugerowana cena**: Musi być liczbą całkowitą w zakresie `1-5`.
- **Typy**: `ToolFormViewModel` (częściowo).
- **Propsy**:
  - `formData: Pick<ToolFormViewModel, "name" | "description" | "suggested_price_tokens">`
  - `onFormChange: (field: string, value: any) => void`
  - `onGenerateDescription: () => Promise<void>`
  - `isGeneratingDescription: boolean`

### `ImageUploader.tsx`
- **Opis**: Komponent do obsługi przesyłania zdjęć. Umożliwia wybór plików, kompresję po stronie klienta, przesyłanie na serwer (zgodnie z wieloetapowym procesem API) i wyświetlanie postępu.
- **Główne elementy**:
  - Obszar "upuść plik" (Dropzone).
  - Lista podglądów zdjęć (`ImagePreviewItem`) z paskiem postępu, statusem i przyciskiem do usunięcia.
- **Obsługiwane interakcje**:
  - Dodawanie nowych zdjęć (przez kliknięcie lub przeciągnięcie).
  - Usuwanie istniejących zdjęć.
- **Obsługiwana walidacja**:
  - **Typ pliku**: Sprawdza, czy typ MIME pliku znajduje się na liście `ALLOWED_IMAGE_TYPES`.
  - **Rozmiar pliku**: Sprawdza, czy rozmiar pliku nie przekracza `MAX_IMAGE_SIZE_BYTES`.
- **Typy**: `ImageUploadState[]`
- **Propsy**:
  - `toolId: string`
  - `images: ImageUploadState[]`
  - `onImageAdd: (file: File) => void`
  - `onImageRemove: (imageId: string) => void`

### `PublishCallout.tsx`
- **Opis**: Wyświetla informację o warunkach koniecznych do publikacji narzędzia i zawiera przycisk "Publikuj".
- **Główne elementy**:
  - Tekst informacyjny (np. "Dodaj co najmniej jedno zdjęcie, aby opublikować").
  - `Button` "Publikuj" (z `shadcn/ui`).
- **Obsługiwane interakcje**: Kliknięcie przycisku "Publikuj".
- **Obsługiwana walidacja**: Przycisk "Publikuj" jest wyłączony, jeśli warunki nie są spełnione.
- **Typy**: Brak specyficznych.
- **Propsy**:
  - `canPublish: boolean`
  - `onPublish: () => void`
  - `isPublishing: boolean`

## 5. Typy
Do implementacji widoku potrzebne będą następujące niestandardowe typy ViewModel, które będą zarządzać stanem po stronie klienta.

```typescript
// Typ do śledzenia statusu przesyłania pojedynczego zdjęcia
type ImageUploadStatus = 
  | "pending" 
  | "compressing" 
  | "getting_url" 
  | "uploading" 
  | "saving" 
  | "completed" 
  | "error";

// Interfejs reprezentujący stan pojedynczego zdjęcia w procesie przesyłania
interface ImageUploadState {
  id: string; // Tymczasowe ID po stronie klienta
  file: File;
  status: ImageUploadStatus;
  progressPercent: number;
  storage_key?: string;
  errorMessage?: string;
  databaseId?: string; // ID z bazy danych po pomyślnym zapisie
}

// Główny ViewModel dla całego widoku dodawania narzędzia
interface ToolFormViewModel {
  toolId: string | null;
  name: string;
  description: string;
  suggested_price_tokens: number;
  images: ImageUploadState[];
  status: "idle" | "creating_draft" | "saving" | "publishing" | "error" | "success";
  errorMessage: string | null;
}
```

## 6. Zarządzanie stanem
Zarządzanie stanem będzie scentralizowane w komponencie `NewToolView.tsx`. Ze względu na złożoność logiki (wieloetapowe przesyłanie plików, automatyczne zapisywanie, stany ładowania i błędów), zalecane jest użycie hooka `useReducer` do zarządzania obiektem `ToolFormViewModel`.

Sugeruje się stworzenie customowego hooka `useNewToolManager`, który zamknie w sobie całą logikę:
- Inicjalizację (tworzenie wersji roboczej).
- Obsługę zmian w formularzu (z debouncowanym zapisem).
- Orkiestrację procesu przesyłania zdjęć.
- Obsługę akcji publikacji.
- Zarządzanie stanami ładowania i błędów.

## 7. Integracja API

1.  **Tworzenie wersji roboczej (przy wejściu na stronę)**
    -   **Endpoint**: `POST /api/tools`
    -   **Request Body**: `CreateToolCommand` (może być pusty lub z domyślnymi wartościami)
    -   **Response Body**: `ToolDTO` (zawiera nowo utworzony `toolId`)

2.  **Aktualizacja wersji roboczej (w tle, po zmianach w formularzu)**
    -   **Endpoint**: `PATCH /api/tools/:id`
    -   **Request Body**: `UpdateToolCommand` (zawiera tylko zmienione pola)
    -   **Response Body**: `ToolDTO`

3.  **Pobranie URL do wysłania zdjęcia**
    -   **Endpoint**: `POST /api/tools/:id/images/upload-url`
    -   **Request Body**: `CreateToolImageUploadUrlCommand` (`{ content_type: string, size_bytes: number }`)
    -   **Response Body**: `ImageUploadURLDTO` (`{ upload_url, headers, storage_key }`)

4.  **Przesłanie pliku zdjęcia**
    -   **Endpoint**: `upload_url` z poprzedniego kroku
    -   **Metoda**: `PUT`
    -   **Request Body**: `File` (plik binarny)

5.  **Zapisanie rekordu zdjęcia w bazie**
    -   **Endpoint**: `POST /api/tools/:id/images`
    -   **Request Body**: `CreateToolImageCommand` (`{ storage_key: string, position: number }`)
    -   **Response Body**: `ToolImageDTO`

6.  **Publikacja narzędzia**
    -   **Endpoint**: `POST /api/tools/:id/publish`
    -   **Request Body**: Pusty
    -   **Response Body**: `ToolDTO` ze statusem `active`.

## 8. Interakcje użytkownika
- **Wpisanie danych w formularzu**: Stan komponentu jest aktualizowany na bieżąco. Po krótkiej chwili bezczynności (debounce) wysyłane jest żądanie `PATCH` w celu zapisania wersji roboczej.
- **Dodanie zdjęcia**: Użytkownik wybiera plik, który pojawia się na liście. Rozpoczyna się proces: kompresja, pobranie URL, wysyłka, zapis rekordu. Postęp jest wizualizowany na bieżąco.
- **Usunięcie zdjęcia**: Użytkownik klika przycisk usuwania. Wysyłane jest żądanie `DELETE /api/tools/:id/images/:imageId`.
- **Kliknięcie "Publikuj"**: Jeśli warunki są spełnione, wysyłane jest żądanie `POST`. Po sukcesie następuje przekierowanie na stronę opublikowanego narzędzia.

## 9. Warunki i walidacja
- **Nazwa narzędzia**: Musi być podana. Przycisk "Publikuj" jest nieaktywny, jeśli pole jest puste.
- **Sugerowana cena**: Musi być liczbą z przedziału 1-5. Walidacja na poziomie `input` oraz logiki biznesowej. Przycisk "Publikuj" jest nieaktywny, jeśli wartość jest niepoprawna.
- **Zdjęcia**: Do publikacji wymagane jest co najmniej jedno poprawnie przesłane zdjęcie. Przycisk "Publikuj" jest nieaktywny, dopóki ten warunek nie zostanie spełniony.
- **Format i rozmiar zdjęcia**: Walidowane po stronie klienta przed rozpoczęciem procesu przesyłania.

## 10. Obsługa błędów
- **Błąd tworzenia wersji roboczej**: Widok wyświetli ogólny komunikat błędu z przyciskiem "Spróbuj ponownie", ponieważ dalsze działania są niemożliwe.
- **Błąd zapisu wersji roboczej**: Wyświetlony zostanie dyskretny komunikat (np. toast) informujący o problemie, a system może podjąć próbę ponownego zapisu.
- **Błąd generowania opisu AI**: Zgodnie z PRD, wyświetlony zostanie mały komunikat przy przycisku, a formularz pozostanie w pełni funkcjonalny.
- **Błąd przesyłania zdjęcia**: Komunikat o błędzie pojawi się bezpośrednio przy danym zdjęciu na liście, z ewentualną opcją ponowienia próby.
- **Błąd publikacji**: Wyświetlony zostanie wyraźny komunikat (toast) z informacją o przyczynie błędu (jeśli jest dostępna).

## 11. Kroki implementacji
1.  **Stworzenie strony Astro**: Utworzenie pliku `src/pages/tools/new.astro`, który będzie renderował komponent React w trybie `client:load` i będzie chroniony przez middleware.
2.  **Implementacja `NewToolView.tsx` i hooka `useNewToolManager`**:
    -   Zdefiniowanie `ToolFormViewModel` i powiązanych typów.
    -   Implementacja logiki `useReducer` do zarządzania stanem.
    -   Implementacja funkcji `useEffect` do tworzenia wersji roboczej przy montowaniu komponentu.
3.  **Implementacja komponentu `ToolForm.tsx`**:
    -   Budowa formularza przy użyciu komponentów `shadcn/ui`.
    -   Podłączenie walidacji po stronie klienta dla pól `name` i `suggested_price_tokens`.
4.  **Implementacja komponentu `ImageUploader.tsx`**:
    -   Integracja z biblioteką `browser-image-compression`.
    -   Implementacja logiki wieloetapowego przesyłania plików.
    -   Stworzenie interfejsu do wyświetlania listy zdjęć z ich stanem.
5.  **Implementacja `PublishCallout.tsx`**: Stworzenie komponentu z logiką włączania/wyłączania przycisku "Publikuj" na podstawie propsów.
6.  **Integracja z API**: Stworzenie funkcji klienckich (np. w `src/lib/api/`) do komunikacji z wszystkimi wymaganymi endpointami.
7.  **Połączenie wszystkiego**: Złożenie wszystkich komponentów w `NewToolView.tsx`, przekazanie odpowiednich propsów i obsługa logiki.
8.  **Obsługa błędów i stanów ładowania**: Implementacja wizualnych wskaźników ładowania i czytelnych komunikatów o błędach dla wszystkich interakcji asynchronicznych.
9.  **Testowanie**: Przetestowanie całego przepływu, w tym przypadków brzegowych (błędne dane, problemy z siecią, etc.).


