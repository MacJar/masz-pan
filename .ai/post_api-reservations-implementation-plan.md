# API Endpoint Implementation Plan: Create Reservation Request

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia uwierzytelnionemu użytkownikowi (wypożyczającemu) złożenie prośby o rezerwację narzędzia. Po pomyślnej walidacji i utworzeniu, zwraca nową rezerwację ze statusem `requested`.

## 2. Szczegóły żądania

- **Metoda HTTP:** `POST`
- **Struktura URL:** `/api/reservations`
- **Parametry:**
  - **Wymagane (w ciele żądania):**
    - `tool_id` (string, uuid): Identyfikator narzędzia do rezerwacji.
    - `owner_id` (string, uuid): Identyfikator właściciela narzędzia.
- **Request Body:**
  ```json
  {
    "tool_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "owner_id": "f0e9d8c7-b6a5-4321-fedc-ba9876543210"
  }
  ```

## 3. Wykorzystywane typy

- **DTO wejściowe (Command Model):** `CreateReservationCommand` zwalidowany przez Zod.
  ```typescript
  // src/lib/schemas/reservation.schema.ts
  import { z } from 'zod';

  export const CreateReservationSchema = z.object({
    tool_id: z.string().uuid({ message: 'Tool ID must be a valid UUID.' }),
    owner_id: z.string().uuid({ message: 'Owner ID must be a valid UUID.' }),
  });

  export type CreateReservationCommand = z.infer<typeof CreateReservationSchema>;
  ```
- **DTO wyjściowe:** `Reservation` (z `src/types.ts`)
  ```typescript
  // Fragment z src/types.ts
  export interface Reservation {
    id: string;
    status: 'requested' | 'owner_accepted' | 'borrower_confirmed' | 'picked_up' | 'returned' | 'cancelled' | 'rejected';
    tool_id: string;
    owner_id: string;
    borrower_id: string;
    created_at: string;
    // ... inne pola
  }
  ```

## 4. Szczegóły odpowiedzi

- **Pomyślna odpowiedź (201 Created):**
  ```json
  {
    "id": "a0b1c2d3-e4f5-6789-0123-456789abcdef",
    "status": "requested",
    "tool_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "owner_id": "f0e9d8c7-b6a5-4321-fedc-ba9876543210",
    "borrower_id": "cba98765-4321-fedc-b6a5-f0e9d8c7b6a5",
    "created_at": "2025-11-14T10:00:00.000Z"
  }
  ```

## 5. Przepływ danych

1.  Klient wysyła żądanie `POST /api/reservations` z `tool_id` i `owner_id`.
2.  Middleware Astro (`src/middleware/index.ts`) weryfikuje sesję użytkownika. Jeśli sesja jest nieprawidłowa, zwraca `401 Unauthorized`.
3.  Handler `POST` w `src/pages/api/reservations/index.ts` jest wywoływany.
4.  Handler pobiera `borrower_id` z `context.locals.user.id`.
5.  Handler parsuje i waliduje ciało żądania za pomocą `CreateReservationSchema`. W przypadku błędu zwraca `400 Bad Request`.
6.  Handler wywołuje metodę `reservationsService.createReservation(command, borrowerId)`.
7.  Serwis `reservations.service.ts` wykonuje logikę biznesową:
    a. Sprawdza, czy `borrower_id` nie jest identyczny z `owner_id`.
    b. Pobiera narzędzie z bazy danych, weryfikując, czy istnieje, czy jego status to `active` i czy `owner_id` się zgadza.
    c. Sprawdza, czy dla danego narzędzia nie istnieje już inna rezerwacja o statusie uniemożliwiającym nową (np. 'requested', 'accepted', 'picked_up').
    d. Wstawia nowy rekord do tabeli `reservations` z domyślnym statusem `requested`.
8.  Serwis zwraca nowo utworzony obiekt rezerwacji lub rzuca dedykowany błąd (np. `ToolNotFoundError`, `ReservationConflictError`).
9.  Handler `POST` łapie ewentualne błędy z serwisu i mapuje je na odpowiednie odpowiedzi HTTP (np. 404, 409).
10. Handler zwraca pomyślną odpowiedź z kodem `201 Created` i danymi rezerwacji.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie:** Dostęp do endpointu jest ograniczony wyłącznie do uwierzytelnionych użytkowników. Middleware Astro sprawdzi istnienie i ważność sesji Supabase.
- **Autoryzacja:** Logika w serwisie uniemożliwi użytkownikowi rezerwację własnego narzędzia, zwracając błąd `403 Forbidden`.
- **Walidacja danych:** Zod jest używany do ścisłej walidacji typów i formatu danych wejściowych, co minimalizuje ryzyko wstrzyknięcia złośliwych danych.
- **Spójność danych:** Serwis weryfikuje, czy `owner_id` podany w żądaniu jest zgodny z właścicielem narzędzia zapisanym w bazie danych, aby zapobiec manipulacji.

## 7. Obsługa błędów

| Kod statusu | Przyczyna                                                                      | Ciało odpowiedzi (przykład)                                     |
| :---------- | :----------------------------------------------------------------------------- | :-------------------------------------------------------------- |
| 400         | Błędne ciało żądania (brakujące pola, zły format UUID)                          | `{ "message": "Invalid input", "errors": [...] }`                |
| 401         | Użytkownik nie jest zalogowany                                                 | `{ "message": "Unauthorized" }`                                 |
| 403         | Użytkownik próbuje zarezerwować własne narzędzie                                | `{ "message": "User cannot reserve their own tool" }`           |
| 404         | Narzędzie o podanym ID nie istnieje lub nie jest aktywne do wypożyczenia        | `{ "message": "Tool not found or not available for reservation" }` |
| 409         | Narzędzie jest już zarezerwowane lub ma oczekującą prośbę                       | `{ "message": "Tool already has an active reservation" }`       |
| 500         | Wewnętrzny błąd serwera (np. błąd bazy danych)                                  | `{ "message": "Internal Server Error" }`                        |

## 8. Rozważania dotyczące wydajności

- Zapytania do bazy danych powinny być zoptymalizowane. Kluczowe jest użycie indeksów na kolumnach `reservations.tool_id`, `tools.id` i `tools.status`.
- Częściowy indeks unikalny `UNIQUE(tool_id)` na tabeli `reservations` (dla statusów aktywnych) jest krytyczny dla wydajnego zapobiegania konfliktom i uniknięcia race conditions.

## 9. Etapy wdrożenia

1.  **Struktura plików:**
    - Utwórz nowy plik `src/pages/api/reservations/index.ts` dla handlera API.
    - Utwórz nowy plik `src/lib/services/reservations.service.ts` dla logiki biznesowej.
    - Utwórz nowy plik `src/lib/schemas/reservation.schema.ts` i zdefiniuj w nim `CreateReservationSchema`.
2.  **Warstwa serwisu (`reservations.service.ts`):**
    - Zaimplementuj metodę `createReservation(command, borrowerId)`.
    - Dodaj logikę weryfikacji:
      - Sprawdzenie rezerwacji własnego narzędzia.
      - Pobranie narzędzia i sprawdzenie jego statusu oraz właściciela.
      - Sprawdzenie istniejących, konfliktowych rezerwacji.
    - Zaimplementuj operację wstawienia nowego rekordu do tabeli `reservations` za pomocą klienta Supabase.
    - Zdefiniuj i rzucaj dedykowane wyjątki dla każdego scenariusza błędu (np. `ForbiddenError`, `NotFoundError`, `ConflictError`).
3.  **Handler API (`/api/reservations/index.ts`):**
    - Zaimplementuj handler `POST`.
    - Dodaj `export const prerender = false;`
    - Zabezpiecz endpoint, sprawdzając `context.locals.user`.
    - Zwaliduj ciało żądania przy użyciu `CreateReservationSchema.safeParse()`.
    - Wywołaj serwis `reservationsService.createReservation` w bloku `try...catch`.
    - W bloku `catch` obsłuż błędy rzucone przez serwis i zwróć odpowiednie kody statusu HTTP oraz komunikaty błędów.
    - W przypadku sukcesu, zwróć dane rezerwacji z kodem statusu `201 Created`.
4.  **Testowanie:**
    - (Opcjonalnie) Dodaj testy jednostkowe dla serwisu `reservations.service.ts`, obejmujące wszystkie ścieżki logiki biznesowej i scenariusze błędów.
    - Przeprowadź testy integracyjne endpointu za pomocą narzędzia do testowania API (np. Postman), aby zweryfikować poprawność działania, obsługę błędów i zabezpieczenia.

