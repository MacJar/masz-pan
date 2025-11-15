# API Endpoint Implementation Plan: `POST /api/tools/:id/images/upload-url`

## 1. Przegląd punktu końcowego

Celem tego punktu końcowego jest bezpieczne generowanie czasowego, podpisanego adresu URL (signed URL), który umożliwi klientowi bezpośrednie przesłanie pliku obrazu do dedykowanego bucketa w Supabase Storage. Endpoint weryfikuje uprawnienia użytkownika do narzędzia oraz parametry przesyłanego pliku (rozmiar, typ), zanim zezwoli na operację.

## 2. Szczegóły żądania

-   **Metoda HTTP:** `POST`
-   **Struktura URL:** `/api/tools/:id/images/upload-url`
-   **Parametry:**
    -   **Wymagane:**
        -   `:id` (w ścieżce) - UUID narzędzia, do którego dodawany jest obraz.
-   **Ciało żądania (Request Body):**
    ```json
    {
      "content_type": "image/jpeg",
      "size_bytes": 1234567
    }
    ```
    -   `content_type` (string): Typ MIME obrazu. Dozwolone wartości: `image/jpeg`, `image/png`, `image/webp`, `image/gif`.
    -   `size_bytes` (integer): Rozmiar pliku w bajtach. Maksymalna wartość: `5242880` (5 MB).

## 3. Wykorzystywane typy

-   **`CreateToolImageUploadUrlCommand` (Zod Schema):**
    ```typescript
    import { z } from 'zod';

    const MAX_IMAGE_SIZE_MB = 5;
    const MAX_IMAGE_SIZE_BYTES = MAX_IMAGE_SIZE_MB * 1024 * 1024;
    const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

    export const CreateToolImageUploadUrlCommand = z.object({
      content_type: z.string().refine(
        (value) => ALLOWED_IMAGE_TYPES.includes(value),
        { message: 'Unsupported image type' }
      ),
      size_bytes: z.number().int().positive().max(
        MAX_IMAGE_SIZE_BYTES,
        { message: `Image size cannot exceed ${MAX_IMAGE_SIZE_MB}MB` }
      ),
    });

    export type CreateToolImageUploadUrlCommand = z.infer<typeof CreateToolImageUploadUrlCommand>;
    ```

-   **`ToolImageUploadUrlDto` (Type):**
    ```typescript
    export type ToolImageUploadUrlDto = {
      upload_url: string;
      headers: Record<string, string>;
      storage_key: string;
    };
    ```

## 4. Szczegóły odpowiedzi

-   **Odpowiedź sukcesu (200 OK):**
    ```json
    {
      "upload_url": "https://<project_ref>.supabase.co/storage/v1/upload/object/sign/tool_images/tools/<tool_id>/<uuid>.jpg?token=...",
      "headers": {
        "x-upsert": "true"
      },
      "storage_key": "tools/<tool_id>/<uuid>.jpg"
    }
    ```
-   **Kody statusu:**
    -   `200 OK`: Pomyślnie wygenerowano podpisany URL.
    -   `400 Bad Request`: Błędne dane wejściowe (niepoprawny UUID, błędy walidacji Zod).
    -   `401 Unauthorized`: Użytkownik niezalogowany.
    -   `403 Forbidden`: Użytkownik nie jest właścicielem narzędzia.
    -   `404 Not Found`: Narzędzie o podanym ID nie zostało znalezione.
    -   `413 Payload Too Large`: Plik jest za duży.
    -   `415 Unsupported Media Type`: Nieobsługiwany typ pliku.
    -   `500 Internal Server Error`: Wewnętrzny błąd serwera, np. błąd komunikacji z Supabase.

## 5. Przepływ danych

1.  Klient wysyła żądanie `POST` na adres `/api/tools/:id/images/upload-url` z `content_type` i `size_bytes` w ciele.
2.  Middleware Astro weryfikuje sesję użytkownika. Jeśli użytkownik nie jest zalogowany, zwraca `401 Unauthorized`.
3.  Handler API w `src/pages/api/tools/[id]/images/upload-url.ts` weryfikuje, czy `id` jest poprawnym UUID.
4.  Handler waliduje ciało żądania przy użyciu schemy Zod `CreateToolImageUploadUrlCommand`.
5.  Handler wywołuje funkcję `toolsService.createSignedImageUploadUrl`, przekazując `id` narzędzia, `id` użytkownika z sesji oraz zwalidowane dane.
6.  Serwis `tools.service.ts` sprawdza w bazie danych, czy narzędzie o danym `id` istnieje i czy zalogowany użytkownik jest jego właścicielem.
7.  Jeśli weryfikacja się powiedzie, serwis generuje unikalną ścieżkę do pliku w Storage (np. `tools/{toolId}/{uuid}.ext`).
8.  Serwis wywołuje `supabase.storage.from('tool_images').createSignedUploadUrl()` z wygenerowaną ścieżką i czasem ważności (np. 60 sekund).
9.  Supabase zwraca podpisany URL i token.
10. Serwis opakowuje odpowiedź w `ToolImageUploadUrlDto` i zwraca ją do handlera API.
11. Handler API wysyła odpowiedź JSON z kodem `200 OK` do klienta.
12. Klient używa otrzymanego `upload_url` do wysłania pliku za pomocą żądania `PUT` bezpośrednio do Supabase Storage.

## 6. Względy bezpieczeństwa

-   **Uwierzytelnianie:** Endpoint jest chroniony przez middleware, który weryfikuje aktywną sesję użytkownika i udostępnia jego dane w `context.locals`.
-   **Autoryzacja:** Logika serwisu musi bezwzględnie sprawdzać, czy `auth.uid()` zalogowanego użytkownika jest równe `owner_id` w tabeli `tools` dla danego `toolId`. Uniemożliwia to dodawanie obrazów do cudzych narzędzi.
-   **Walidacja danych:**
    -   Ścisła walidacja `content_type` i `size_bytes` po stronie serwera zapobiega próbom wgrania niebezpiecznych lub zbyt dużych plików.
    -   Parametr `id` jest walidowany jako UUID.
-   **Podpisane URL-e:** Użycie podpisanych URL-i z krótkim czasem życia (`expiresIn`) minimalizuje ryzyko ich ponownego użycia lub przechwycenia. Opcja `upsert: true` jest bezpieczna w tym kontekście, ponieważ generujemy unikalny UUID dla każdego pliku, więc nadpisanie jest mało prawdopodobne.

## 7. Rozważania dotyczące wydajności

-   Generowanie podpisanego URL-a jest szybką operacją i nie powinno stanowić wąskiego gardła.
-   Główna zaleta wydajnościowa tego podejścia polega na tym, że serwer aplikacji nie pośredniczy w przesyłaniu samego pliku, co znacznie redukuje jego obciążenie i zużycie przepustowości.

## 8. Etapy wdrożenia

1.  **Aktualizacja typów:**
    -   W pliku `src/types.ts` (lub dedykowanym pliku DTO) zdefiniuj i wyeksportuj schemę Zod `CreateToolImageUploadUrlCommand` oraz typ `ToolImageUploadUrlDto`.

2.  **Rozbudowa serwisu `tools.service.ts`:**
    -   Dodaj nową, asynchroniczną metodę `createSignedImageUploadUrl`.
    -   Metoda powinna przyjmować `supabaseClient`, `userId`, `toolId` oraz `command` jako argumenty.
    -   Wewnątrz metody:
        -   Pobierz narzędzie z bazy danych na podstawie `toolId`.
        -   Jeśli narzędzie nie istnieje, rzuć błąd `ToolNotFoundError`.
        -   Sprawdź, czy `tool.owner_id` jest równe `userId`. Jeśli nie, rzuć błąd `ForbiddenError`.
        -   Wyodrębnij rozszerzenie pliku z `command.content_type`.
        -   Wygeneruj unikalną nazwę pliku za pomocą `crypto.randomUUID()`.
        -   Skonstruuj ścieżkę w storage: `tools/${toolId}/${uuid}.${extension}`.
        -   Wywołaj `supabase.storage.from('tool_images').createSignedUploadUrl(path, 60, { upsert: true })`.
        -   Obsłuż ewentualny błąd z Supabase i rzuć `InternalServerError`.
        -   Zwróć obiekt `{ upload_url, storage_key, headers: { 'x-upsert': 'true' } }`.

3.  **Utworzenie pliku endpointu:**
    -   Stwórz nowy plik: `src/pages/api/tools/[id]/images/upload-url.ts`.
    -   Ustaw `export const prerender = false;`.

4.  **Implementacja handlera `POST`:**
    -   W pliku endpointu, zaimplementuj `export const POST: APIRoute = async ({ params, request, locals }) => { ... }`.
    -   Sprawdź, czy `locals.session.user` istnieje.
    -   Sprawdź, czy `params.id` jest poprawnym UUID. Jeśli nie, zwróć `400`.
    -   Odczytaj ciało żądania za pomocą `request.json()`.
    -   Zwaliduj ciało żądania za pomocą `CreateToolImageUploadUrlCommand.safeParse()`. W przypadku błędu, zwróć `400` ze szczegółami błędu.
    -   Wywołaj `toolsService.createSignedImageUploadUrl(...)` w bloku `try...catch`.
    -   W bloku `catch` obsłuż specyficzne błędy (`ToolNotFoundError`, `ForbiddenError`) i zwróć odpowiednie kody statusu (`404`, `403`). Ogólne błędy obsłuż jako `500`.
    -   Jeśli wywołanie serwisu się powiedzie, zwróć odpowiedź JSON z danymi i statusem `200 OK`.

5.  **Konfiguracja zmiennych środowiskowych:**
    -   Upewnij się, że stałe `MAX_IMAGE_SIZE_BYTES` i `ALLOWED_IMAGE_TYPES` są zdefiniowane w sposób umożliwiający łatwą konfigurację (np. w `src/config.ts` lub bezpośrednio w pliku z typami, jeśli nie przewiduje się ich częstej zmiany).


