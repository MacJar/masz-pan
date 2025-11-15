# API Endpoint Implementation Plan: `POST /api/tokens/rescue`

## 1. Przegląd punktu końcowego

Ten punkt końcowy umożliwia uwierzytelnionym użytkownikom odebranie dziennego "tokena ratunkowego". Użytkownik może otrzymać jeden token, ale tylko wtedy, gdy jego saldo dostępnych tokenów wynosi zero. Operacja jest ograniczona do jednego razu na dzień kalendarzowy w strefie czasowej CET.

## 2. Szczegóły żądania

- **Metoda HTTP:** `POST`
- **Struktura URL:** `/api/tokens/rescue`
- **Parametry:**
  - **Wymagane:** Brak
  - **Opcjonalne:** Brak
- **Request Body:** Puste
- **Nagłówki:**
  - `Authorization: Bearer <SUPABASE_JWT>` (wymagane, zarządzane przez klienta Supabase)
  - `Content-Type: application/json`

## 3. Wykorzystywane typy

- **`RescueTokenResponseDto`** (odpowiedź):
  ```typescript
  // src/lib/schemas/token.schema.ts
  import { z } from 'zod';

  export const RescueTokenResponseDtoSchema = z.object({
    awarded: z.literal(true),
    amount: z.literal(1),
    claim_date_cet: z.string().date(), // Format YYYY-MM-DD
  });

  export type RescueTokenResponseDto = z.infer<typeof RescueTokenResponseDtoSchema>;
  ```

## 4. Szczegóły odpowiedzi

- **Odpowiedź sukcesu (200 OK):**
  ```json
  {
    "awarded": true,
    "amount": 1,
    "claim_date_cet": "2025-11-14"
  }
  ```
- **Odpowiedzi błędów:**
  - `401 Unauthorized`: Użytkownik nie jest zalogowany.
  - `409 Conflict`: Użytkownik już odebrał token w danym dniu.
  - `422 Unprocessable Entity`: Saldo dostępnych tokenów użytkownika jest większe niż zero.
  - `500 Internal Server Error`: Wewnętrzny błąd serwera.

## 5. Przepływ danych

1.  Użytkownik wysyła żądanie `POST` na adres `/api/tokens/rescue`.
2.  Middleware Astro weryfikuje token JWT i udostępnia sesję użytkownika w `context.locals`.
3.  Handler API (`src/pages/api/tokens/rescue.ts`) sprawdza, czy sesja istnieje. Jeśli nie, zwraca `401`.
4.  Handler wywołuje metodę `tokensService.claimRescueToken(supabase, session.user.id)`.
5.  Metoda `claimRescueToken` w `TokensService` wywołuje funkcję PostgreSQL `claim_rescue_token` za pomocą RPC.
6.  Funkcja `claim_rescue_token` w bazie danych wykonuje transakcyjnie następujące operacje:
    a. Sprawdza, czy dostępne saldo tokenów użytkownika (z widoku `balances`) jest równe 0. Jeśli nie, zgłasza wyjątek.
    b. Próbuje wstawić nowy wiersz do tabeli `rescue_claims`. Jeśli istnieje już wpis dla danego `user_id` i bieżącej daty CET, ograniczenie `UNIQUE` spowoduje błąd.
    c. Jeśli powyższe kroki się powiodą, wstawia nowy rekord do `token_ledger` (`kind: 'award'`, `amount: 1`).
7.  `TokensService` przechwytuje ewentualne błędy z RPC:
    - Błąd naruszenia unikalności mapuje na `ServiceError` z kodem `CONFLICT`.
    - Błąd zgłoszony z powodu salda > 0 mapuje na `ServiceError` z kodem `UNPROCESSABLE_ENTITY`.
8.  Handler API przechwytuje `ServiceError` i zwraca odpowiedni kod statusu HTTP (409 lub 422).
9.  W przypadku powodzenia, handler API pobiera bieżącą datę w strefie CET, tworzy obiekt `RescueTokenResponseDto` i zwraca go z kodem `200 OK`.
10. W przypadku nieoczekiwanego błędu, jest on logowany, a API zwraca `500 Internal Server Error`.

## 6. Względy bezpieczeństwa

- **Uwierzytelnianie:** Endpoint musi być chroniony i dostępny tylko dla zalogowanych użytkowników. Weryfikacja sesji jest kluczowa.
- **Autoryzacja:** Każdy uwierzytelniony użytkownik ma prawo do wywołania tego endpointu. Nie są wymagane żadne dodatkowe role.
- **Ochrona przed nadużyciami:** Logika "raz dziennie" jest zaimplementowana na poziomie bazy danych za pomocą ograniczenia `UNIQUE`, co stanowi skuteczną ochronę przed wielokrotnym przyznawaniem tokenów.

## 7. Rozważania dotyczące wydajności

- Operacja opiera się na pojedynczym wywołaniu RPC do funkcji bazy danych, która powinna być bardzo wydajna.
- Tabela `rescue_claims` powinna mieć indeks na `(user_id, claim_date_cet)`, który jest automatycznie tworzony przez ograniczenie `UNIQUE`.
- Widok `balances` powinien być zoptymalizowany.
- Przy normalnym obciążeniu nie przewiduje się problemów z wydajnością.

## 8. Etapy wdrożenia

1.  **Baza Danych:**
    - Utwórz nowy plik migracji w `supabase/migrations/`.
    - W pliku migracji zdefiniuj funkcję `claim_rescue_token(p_user_id uuid)`, która implementuje logikę opisaną w sekcji "Przepływ danych" (sprawdzenie salda, wstawienie do `rescue_claims` i `token_ledger`). Funkcja powinna rzucać wyjątki w przypadku naruszenia reguł biznesowych.

2.  **Schema (DTO):**
    - W pliku `src/lib/schemas/token.schema.ts` dodaj eksportowany schemat Zod `RescueTokenResponseDtoSchema` oraz typ `RescueTokenResponseDto`.

3.  **Serwis:**
    - W pliku `src/lib/services/tokens.service.ts` dodaj nową metodę `async claimRescueToken(supabase: SupabaseClient, userId: string)`.
    - Wewnątrz metody wywołaj `supabase.rpc('claim_rescue_token', { p_user_id: userId })`.
    - Dodaj blok `try...catch` do obsługi `PostgrestError` z RPC. Mapuj specyficzne kody błędów bazy danych (np. `23505` dla naruszenia unikalności) na odpowiednie `ServiceError` (`CONFLICT`, `UNPROCESSABLE_ENTITY`).

4.  **Endpoint API:**
    - Utwórz nowy plik `src/pages/api/tokens/rescue.ts`.
    - Zaimplementuj handler `POST({ locals })`.
    - Dodaj `export const prerender = false;`
    - Sprawdź istnienie `locals.session`. Jeśli brak, zwróć `new Response(null, { status: 401 })`.
    - Wywołaj `tokensService.claimRescueToken(...)` w bloku `try...catch`.
    - Przechwyć `ServiceError` i użyj `error()` z Astro, aby zwrócić odpowiedni status (409 lub 422).
    - W przypadku powodzenia, uzyskaj aktualną datę CET, stwórz obiekt odpowiedzi i zwróć go jako JSON z kodem `200 OK`.

