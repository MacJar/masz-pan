# API Endpoint Implementation Plan: DELETE /api/tools/:id/images/:imageId

## 1. Przegląd punktu końcowego

Ten punkt końcowy jest przeznaczony do usuwania zdjęcia powiązanego z narzędziem. Operacja jest permanentna i obejmuje zarówno usunięcie rekordu z bazy danych, jak i usunięcie samego pliku z usługi przechowywania (Supabase Storage). Dostęp do tego endpointu jest ograniczony wyłącznie do właściciela narzędzia.

## 2. Szczegóły żądania

- **Metoda HTTP:** `DELETE`
- **Struktura URL:** `/api/tools/[id]/images/[imageId]`
- **Parametry:**
  - **Wymagane (w ścieżce URL):**
    - `id` (string, format UUID): Unikalny identyfikator narzędzia.
    - `imageId` (string, format UUID): Unikalny identyfikator zdjęcia do usunięcia.
- **Ciało żądania (Request Body):** Brak.

## 3. Wykorzystywane typy

- **Schemat walidacji Zod dla parametrów:**
  ```typescript
  // src/pages/api/tools/[id]/images/[imageId].ts
  import { z } from 'zod';

  export const DeleteToolImageParamsSchema = z.object({
    id: z.string().uuid({ message: 'Invalid tool ID format' }),
    imageId: z.string().uuid({ message: 'Invalid image ID format' }),
  });
  ```
- **Model polecenia (Command Model) dla serwisu:**
  ```typescript
  // src/lib/services/tools.service.ts
  export interface DeleteToolImageCommand {
    toolId: string;
    imageId: string;
    userId: string;
  }
  ```

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (200 OK):**
  - Ciało odpowiedzi: `{ "deleted": true }`
  - Opis: Zwracane, gdy zarówno rekord w bazie danych, jak i plik w storage zostały pomyślnie usunięte.
- **Odpowiedzi błędów:**
  - `400 Bad Request`: Parametry `id` lub `imageId` są nieprawidłowe.
  - `401 Unauthorized`: Użytkownik nie jest uwierzytelniony.
  - `403 Forbidden`: Użytkownik jest uwierzytelniony, ale nie jest właścicielem narzędzia.
  - `404 Not Found`: Narzędzie lub zdjęcie o podanych ID nie istnieje.
  - `500 Internal Server Error`: Wystąpił błąd serwera podczas przetwarzania żądania.

## 5. Przepływ danych

1.  Żądanie `DELETE` trafia do endpointu Astro `src/pages/api/tools/[id]/images/[imageId].ts`.
2.  Middleware Astro weryfikuje sesję użytkownika. Jeśli użytkownik nie jest zalogowany, zwraca `401 Unauthorized`.
3.  Handler endpointu pobiera `id` i `imageId` z `Astro.params`.
4.  Parametry są walidowane przy użyciu schemy `DeleteToolImageParamsSchema`. W przypadku błędu zwracany jest status `400 Bad Request`.
5.  Handler wywołuje metodę `toolsService.deleteToolImage` przekazując jej `toolId`, `imageId` oraz ID zalogowanego użytkownika z `context.locals.user.id`.
6.  Metoda `deleteToolImage` w `tools.service.ts` wykonuje następujące kroki w ramach jednej transakcji:
    a. Pobiera z bazy danych rekord `tool_images` wraz z powiązanym `tools.owner_id` na podstawie `imageId`.
    b. Jeśli rekord nie istnieje, zwraca błąd `NotFound`.
    c. Sprawdza, czy pobrany `tools.owner_id` jest zgodny z `userId` przekazanym w poleceniu. Jeśli nie, zwraca błąd `Forbidden`.
    d. Sprawdza, czy pobrany rekord zdjęcia na pewno należy do narzędzia o `toolId`. Jeśli nie, zwraca błąd `NotFound`.
    e. Wywołuje metodę Supabase Storage `storage.from('tool-images').remove([storage_key])` w celu usunięcia fizycznego pliku.
    f. Usuwa rekord z tabeli `tool_images` w bazie danych.
7.  Serwis zwraca potwierdzenie sukcesu do handlera.
8.  Handler API wysyła odpowiedź `200 OK` z ciałem `{ "deleted": true }`.
9.  W przypadku błędu na którymkolwiek etapie w serwisie, rzucany jest odpowiedni wyjątek (np. `ServiceError`), który jest łapany w handlerze i mapowany na odpowiedni kod statusu HTTP.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie:** Dostęp do endpointu musi być chroniony i wymaga aktywnej sesji użytkownika, co jest zapewniane przez middleware Astro.
- **Autoryzacja:** Kluczowym elementem jest weryfikacja w warstwie serwisowej, czy ID zalogowanego użytkownika (`userId`) jest identyczne z `owner_id` narzędzia, z którym powiązane jest usuwane zdjęcie. Zapobiega to usunięciu zasobów przez nieuprawnione osoby.
- **Walidacja danych wejściowych:** Walidacja formatu UUID dla `id` i `imageId` na poziomie handlera chroni przed próbami ataków z użyciem nieprawidłowych danych wejściowych.
- **Polityki RLS (Row-Level Security):** Jako dodatkowa warstwa zabezpieczeń, na tabeli `tool_images` powinna być skonfigurowana polityka RLS, która zezwala na operację `DELETE` tylko wtedy, gdy `auth.uid()` jest równe `owner_id` powiązanego narzędzia.

## 7. Rozważania dotyczące wydajności

- Operacja usuwania jest z natury szybka. Wąskim gardłem może być czas odpowiedzi od Supabase Storage.
- Baza danych powinna mieć indeksy na kluczach głównych (`tools.id`, `tool_images.id`) oraz kluczach obcych, co jest standardową praktyką i zapewnia szybkie wyszukiwanie.
- Operacje na bazie danych (weryfikacja, usunięcie) powinny być wykonane w ramach jednej transakcji, aby zapewnić spójność danych w przypadku błędu.

## 8. Etapy wdrożenia

1.  **Utworzenie pliku endpointu:** Stwórz nowy plik `src/pages/api/tools/[id]/images/[imageId].ts`.
2.  **Implementacja handlera `DELETE`:** W nowo utworzonym pliku zaimplementuj `export const DELETE: APIRoute = async ({ params, locals }) => { ... };`.
3.  **Dodanie walidacji Zod:** Wewnątrz handlera, zaimplementuj walidację parametrów `id` i `imageId` z `params` przy użyciu zdefiniowanej schemy `DeleteToolImageParamsSchema`.
4.  **Rozszerzenie `tools.service.ts`:**
    - Dodaj nową metodę publiczną `deleteToolImage(command: DeleteToolImageCommand): Promise<void>`.
    - Zaimplementuj w niej logikę opisaną w sekcji "Przepływ danych", włączając w to pobranie danych, sprawdzenie uprawnień, usunięcie pliku ze Storage i usunięcie rekordu z bazy.
    - Zadbaj o odpowiednią obsługę błędów i rzucanie wyjątków `ServiceError` z odpowiednimi typami (`NOT_FOUND`, `FORBIDDEN`).
5.  **Połączenie handlera z serwisem:** W handlerze `DELETE` wywołaj nową metodę serwisu w bloku `try...catch`. Przechwyć ewentualne błędy `ServiceError` i zwróć odpowiednie odpowiedzi HTTP z kodami statusu.
6.  **Weryfikacja polityk RLS:** Upewnij się, że w Supabase istnieją odpowiednie polityki RLS dla tabeli `tool_images`, które zabezpieczają operacje `DELETE`.
7.  **Testowanie:** Przygotuj testy jednostkowe dla logiki serwisu oraz testy integracyjne dla endpointu API, obejmujące scenariusze pomyślne oraz wszystkie zidentyfikowane scenariusze błędów.


