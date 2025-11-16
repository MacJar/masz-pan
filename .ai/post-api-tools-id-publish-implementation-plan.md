# API Endpoint Implementation Plan: POST /api/tools/:id/publish

## 1. Przegląd punktu końcowego

Celem tego punktu końcowego jest publikacja narzędzia, czyli zmiana jego statusu z `draft` na `active`. Operacja ta jest dostępna tylko dla właściciela narzędzia i wymaga, aby do narzędzia było przypisane co najmniej jedno zdjęcie. Pomyślna publikacja udostępnia narzędzie innym użytkownikom w systemie.

## 2. Szczegóły żądania

- **Metoda HTTP**: `POST`
- **Struktura URL**: `/api/tools/{id}/publish`
- **Parametry**:
  - **Wymagane**:
    - `id` (w ścieżce URL): Identyfikator UUID narzędzia, które ma zostać opublikowane.
- **Request Body**: Brak (puste ciało).

## 3. Wykorzystywane typy

- **Walidacja parametrów**:
  ```typescript
  // src/lib/schemas/tool.schema.ts
  import { z } from 'zod';

  export const ToolIdParamSchema = z.object({
    id: z.string().uuid({ message: 'Tool ID must be a valid UUID' }),
  });
  ```
- **Odpowiedź API**:
  - W przypadku sukcesu, odpowiedź będzie zgodna z typem `Tool` zdefiniowanym w `src/types.ts`.

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (200 OK)**:
  - Zwraca pełny obiekt opublikowanego narzędzia w formacie JSON, zgodnie z typem `Tool`. Status narzędzia będzie zmieniony na `active`.
  ```json
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "owner_id": "876e4567-e89b-12d3-a456-426614174000",
    "name": "Młotek",
    "description": "Solidny młotek do prac domowych.",
    "suggested_price_tokens": 2,
    "status": "active",
    "created_at": "2025-11-12T10:00:00Z",
    "updated_at": "2025-11-12T12:30:00Z",
    "archived_at": null
  }
  ```
- **Odpowiedzi błędów**:
  - `400 Bad Request`: Nieprawidłowy format ID narzędzia.
  - `401 Unauthorized`: Brak sesji użytkownika.
  - `403 Forbidden`: Użytkownik nie jest właścicielem narzędzia.
  - `404 Not Found`: Narzędzie o podanym ID nie istnieje.
  - `409 Conflict`: Brak zdjęć uniemożliwia publikację.
  - `422 Unprocessable Entity`: Nieprawidłowy stan narzędzia (np. już opublikowane).
  - `500 Internal Server Error`: Wewnętrzny błąd serwera.

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `POST` na endpoint `/api/tools/{id}/publish`.
2.  Middleware w Astro weryfikuje sesję użytkownika na podstawie ciasteczka. Jeśli sesja jest nieprawidłowa, zwraca `401`.
3.  Handler API w `src/pages/api/tools/[id]/publish.ts` przejmuje żądanie.
4.  Handler waliduje parametr `id` ze ścieżki URL przy użyciu `ToolIdParamSchema` (Zod). W przypadku błędu zwraca `400`.
5.  Handler wywołuje metodę `publishTool` z serwisu `ToolService`, przekazując jej klienta Supabase (`Astro.locals.supabase`), ID narzędzia oraz ID zalogowanego użytkownika.
6.  `ToolService` wywołuje funkcję RPC w bazie danych PostgreSQL o nazwie `publish_tool` z parametrem `tool_id`.
7.  Funkcja `publish_tool` w PostgreSQL:
    a. Weryfikuje, czy narzędzie o podanym ID istnieje. Jeśli nie, rzuca wyjątek (np. `PGRST_NOT_FOUND`).
    b. Sprawdza, czy `auth.uid()` jest równe `owner_id` w tabeli `tools`. Jeśli nie, rzuca wyjątek (np. `PGRST_FORBIDDEN`).
    c. Sprawdza, czy istnieje co najmniej jeden rekord w tabeli `tool_images` dla danego `tool_id`. Jeśli nie, rzuca wyjątek (np. `PGRST_CONFLICT`).
    d. Sprawdza, czy status narzędzia to `draft`. Jeśli nie, rzuca wyjątek (np. `PGRST_UNPROCESSABLE`).
    e. Jeśli wszystkie warunki są spełnione, aktualizuje status narzędzia na `active` i dodaje wpis do tabeli `audit_log`.
8.  `ToolService` przechwytuje odpowiedź z RPC. W przypadku błędu, mapuje go na odpowiedni błąd aplikacyjny i kod statusu.
9.  W przypadku sukcesu, `ToolService` pobiera zaktualizowany obiekt narzędzia i zwraca go do handlera.
10. Handler API serializuje obiekt narzędzia do formatu JSON i wysyła odpowiedź z kodem `200 OK`.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie**: Endpoint musi być chroniony. Dostęp jest możliwy tylko dla zalogowanych użytkowników. Middleware Astro (`src/middleware/index.ts`) będzie odpowiedzialne za weryfikację sesji Supabase.
- **Autoryzacja**: Logika autoryzacji zostanie zaimplementowana bezpośrednio w funkcji bazodanowej `publish_tool`. Będzie ona sprawdzać, czy ID zalogowanego użytkownika (`auth.uid()`) jest zgodne z `owner_id` publikowanego narzędzia. Takie podejście (Row Level Security/logika w funkcji `SECURITY DEFINER`) jest zalecane przez Supabase.
- **Walidacja wejścia**: Parametr `id` będzie rygorystycznie walidowany jako UUID, aby zapobiec błędom i potencjalnym atakom (np. SQL Injection, chociaż parametryzowane zapytania RPC w Supabase minimalizują to ryzyko).

## 7. Rozważania dotyczące wydajności

- Operacja polega na jednej aktualizacji rekordu w tabeli `tools` oraz odczycie z tabeli `tool_images`. Są to szybkie operacje, indeksowane po kluczach głównych.
- Wywołanie funkcji RPC jest efektywne, ponieważ ogranicza liczbę zapytań (round-trips) między serwerem aplikacji a bazą danych do jednego.
- Nie przewiduje się znaczących wąskich gardeł wydajnościowych dla tego punktu końcowego.

## 8. Etapy wdrożenia

1.  **Baza danych**:
    - Zaimplementować lub zaktualizować funkcję PostgreSQL `publish_tool(tool_id uuid)`.
    - Funkcja powinna zawierać pełną logikę walidacji (istnienie, własność, stan, obecność zdjęć) oraz logowanie do `audit_log`.
    - Należy upewnić się, że funkcja rzuca odpowiednie wyjątki z kodami błędów, które mogą być łatwo zinterpretowane po stronie aplikacji (np. poprzez `RAISE EXCEPTION ... USING ERRCODE = '...'`).
2.  **Logika biznesowa (Service)**:
    - Utworzyć plik `src/lib/services/tool.service.ts`, jeśli nie istnieje.
    - Dodać metodę `publishTool`, która przyjmuje klienta Supabase, `toolId` i `userId`.
    - Metoda powinna wywoływać RPC `publish_tool`.
    - Dodać obsługę błędów zwracanych przez RPC i mapowanie ich na zrozumiałe błędy aplikacyjne.
    - W przypadku sukcesu, metoda powinna zwrócić zaktualizowany obiekt narzędzia.
3.  **Schematy walidacji**:
    - Utworzyć plik `src/lib/schemas/tool.schema.ts`, jeśli nie istnieje.
    - Dodać `ToolIdParamSchema` do walidacji parametru `id` z URL.
4.  **Endpoint API**:
    - Utworzyć plik `src/pages/api/tools/[id]/publish.ts`.
    - Dodać `export const prerender = false;`.
    - Zaimplementować handler `POST`, który:
      a. Pobiera sesję użytkownika z `Astro.locals.supabase`. Jeśli brak, zwraca `401`.
      b. Waliduje `Astro.params.id` za pomocą `ToolIdParamSchema`. Jeśli błąd, zwraca `400`.
      c. Wywołuje `toolService.publishTool(...)`.
      d. Obsługuje wynik z serwisu, zwracając `200 OK` z obiektem narzędzia lub odpowiedni kod błędu (`403`, `404`, `409`, `422`, `500`).
5.  **Testowanie**:
    - Przygotować testy jednostkowe dla `ToolService`, mockując wywołania klienta Supabase.
    - Przygotować testy integracyjne dla endpointu API, które sprawdzą wszystkie ścieżki (sukces, różne scenariusze błędów).


