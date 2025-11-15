# API Endpoint Implementation Plan: `POST /api/tools/:id/images`

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia uwierzytelnionemu właścicielowi narzędzia dodanie rekordu obrazu do jednego ze swoich narzędzi. Jest to zazwyczaj wywoływane po pomyślnym przesłaniu pliku obrazu do usługi przechowywania (np. Supabase Storage), a ten punkt końcowy zapisuje metadane obrazu (takie jak klucz przechowywania i pozycja) w bazie danych.

## 2. Szczegóły żądania

- **Metoda HTTP**: `POST`
- **Struktura URL**: `/api/tools/[id]/images`
- **Parametry ścieżki**:
  - `id` (string, UUID): Identyfikator narzędzia (`tools.id`), do którego dodawany jest obraz. **Wymagane**.
- **Ciało żądania (Request Body)**:
  - Typ zawartości: `application/json`
  - Struktura:
    ```json
    {
      "storage_key": "string",
      "position": "number"
    }
    ```
    - `storage_key`: Ścieżka do pliku w Supabase Storage. **Wymagane**.
    - `position`: Liczba całkowita określająca kolejność wyświetlania obrazu (0 oznacza obraz główny). **Wymagane**.

## 3. Wykorzystywane typy

Do walidacji danych wejściowych zostanie użyty schemat Zod.

- **`CreateToolImageDtoSchema`**:
  ```typescript
  import { z } from 'zod';

  export const CreateToolImageDtoSchema = z.object({
    storage_key: z.string().min(1, { message: "Storage key is required" }),
    position: z.number().int().min(0, { message: "Position must be a non-negative integer" })
  });

  export type CreateToolImageDto = z.infer<typeof CreateToolImageDtoSchema>;
  ```

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (`201 Created`)**:
  - Zwraca nowo utworzony obiekt obrazu narzędzia.
    ```json
    {
      "id": "c4a4e6f0-3e2b-4b1d-8e6f-0a7b9d1c3e1a",
      "tool_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "storage_key": "tools/a1b2c3d4-e5f6-7890-1234-567890abcdef/image.png",
      "position": 0,
      "created_at": "2025-11-10T10:00:00Z"
    }
    ```
- **Odpowiedzi błędów**:
  - `400 Bad Request`: Nieprawidłowe dane wejściowe.
  - `401 Unauthorized`: Brak uwierzytelnienia.
  - `403 Forbidden`: Brak uprawnień do zasobu.
  - `404 Not Found`: Narzędzie nie zostało znalezione.
  - `409 Conflict`: Obraz na danej pozycji już istnieje.
  - `500 Internal Server Error`: Błąd serwera.

## 5. Przepływ danych

1.  Klient wysyła żądanie `POST` do `/api/tools/[id]/images` z poprawnym tokenem sesji i ciałem żądania.
2.  Middleware Astro weryfikuje sesję użytkownika. Jeśli jest nieprawidłowa, zwraca `401`.
3.  Handler API (`src/pages/api/tools/[id]/images.ts`) jest wywoływany.
4.  Handler waliduje parametr `id` ze ścieżki URL (musi być poprawnym UUID). Jeśli nie jest, zwraca `400`.
5.  Handler waliduje ciało żądania za pomocą schematu `CreateToolImageDtoSchema`. W przypadku błędu zwraca `400`.
6.  Handler wywołuje metodę `toolsService.createToolImage` przekazując `toolId`, `userId` (z sesji) oraz zwalidowane dane.
7.  `toolsService` najpierw sprawdza, czy narzędzie o podanym `toolId` istnieje i czy `userId` jest jego właścicielem. Jeśli nie, zwraca błąd, który handler mapuje na `404` lub `403`.
8.  Serwis próbuje wstawić nowy rekord do tabeli `tool_images`.
9.  Jeśli operacja `INSERT` naruszy ograniczenie unikalności `(tool_id, position)`, baza danych zwróci błąd. Serwis przechwytuje ten błąd i zwraca odpowiedni typ błędu, który handler mapuje na `409 Conflict`.
10. W przypadku pomyślnego wstawienia, serwis zwraca nowo utworzony obiekt `tool_image`.
11. Handler API otrzymuje pomyślny wynik z serwisu i wysyła odpowiedź `201 Created` z danymi obrazu w formacie JSON.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie**: Endpoint musi być chroniony. Handler sprawdzi istnienie aktywnej sesji użytkownika w `context.locals.session`. W przypadku jej braku, dostęp zostanie zablokowany.
- **Autoryzacja**: Logika biznesowa w `tools.service.ts` musi bezwzględnie weryfikować, czy uwierzytelniony użytkownik jest właścicielem narzędzia (`tools.owner_id`), do którego próbuje dodać obraz.
- **Walidacja danych**: Wszystkie dane wejściowe (`id` z URL oraz `storage_key` i `position` z ciała żądania) muszą być rygorystycznie walidowane, aby zapobiec błędom i atakom. Użycie Zod i sprawdzanie formatu UUID jest kluczowe.

## 7. Rozważania dotyczące wydajności

- Operacja polega na jednym zapytaniu `SELECT` (weryfikacja właściciela) i jednym `INSERT` (dodanie obrazu).
- Ograniczenie `UNIQUE` na `(tool_id, position)` jest wspierane przez indeks, więc sprawdzanie unikalności będzie wydajne.
- Operacja jest atomowa i nie powinna stanowić wąskiego gardła wydajnościowego.

## 8. Etapy wdrożenia

1.  **Utworzenie pliku endpointu**: Utworzyć nowy plik `src/pages/api/tools/[id]/images.ts`.
2.  **Zdefiniowanie schematu walidacji**: W pliku `images.ts` zdefiniować `CreateToolImageDtoSchema` przy użyciu Zod.
3.  **Implementacja handlera `POST`**: W pliku `images.ts` zaimplementować handler `POST`, który:
    - Eksportuje `prerender = false`.
    - Pobiera `id` z `context.params`.
    - Sprawdza sesję użytkownika w `context.locals.session`.
    - Waliduje `id` jako UUID.
    - Parsuje i waliduje ciało żądania za pomocą zdefiniowanego schematu Zod.
    - Wywołuje metodę serwisu w bloku `try...catch`.
    - Mapuje wyniki (sukces lub błędy) z serwisu na odpowiednie odpowiedzi HTTP (`APIResponse`).
4.  **Rozszerzenie serwisu `tools.service.ts`**:
    - Dodać nową metodę `createToolImage(toolId: string, ownerId: string, data: CreateToolImageDto)`.
    - Wewnątrz metody zaimplementować logikę:
      - Pobranie narzędzia z bazy danych w celu weryfikacji istnienia i właściciela.
      - Wstawienie nowego rekordu do tabeli `tool_images`.
      - Obsługa specyficznego błędu bazy danych dla naruszenia unikalności (kod `23505` w PostgreSQL) i opakowanie go w `AppError`.
5.  **Typy**: Upewnić się, że typ `ToolImage` jest dostępny (jeśli nie, wygenerować go na podstawie `database.types.ts`).
6.  **Testowanie**: Ręczne przetestowanie endpointu za pomocą narzędzia API (np. Postman, Insomnia) uwzględniając wszystkie scenariusze sukcesu i błędów.

