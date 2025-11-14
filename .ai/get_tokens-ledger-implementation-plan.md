# API Endpoint Implementation Plan: GET /api/tokens/ledger

## 1. Przegląd punktu końcowego

Ten punkt końcowy jest odpowiedzialny za pobieranie historii transakcji tokenów (księgi) dla aktualnie uwierzytelnionego użytkownika. Umożliwia paginację wyników za pomocą kursora oraz filtrowanie wpisów po ich rodzaju. Jest to operacja tylko do odczytu.

## 2. Szczegóły żądania

- **Metoda HTTP:** `GET`
- **Struktura URL:** `/api/tokens/ledger`
- **Parametry zapytania (Query Parameters):**
  - `kind` (opcjonalny): `string` - Filtruje wyniki po rodzaju wpisu. Dopuszczalne wartości: `debit`, `credit`, `hold`, `release`, `transfer`, `award`.
  - `cursor` (opcjonalny): `string` - Zakodowany w Base64 ciąg znaków reprezentujący punkt startowy dla następnej strony wyników.
  - `limit` (opcjonalny): `number` - Liczba wpisów do zwrócenia. Domyślnie: `20`, Maksymalnie: `50`.

## 3. Wykorzystywane typy

### Schematy Walidacji (Zod)
Plik: `src/lib/schemas/token.schema.ts`
```typescript
import { z } from 'zod';

export const LedgerKindSchema = z.enum([
  'debit',
  'credit',
  'hold',
  'release',
  'transfer',
  'award',
]);

export const GetLedgerEntriesQuerySchema = z.object({
  kind: LedgerKindSchema.optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().positive().max(50).optional().default(20),
});
```

### DTO (Data Transfer Objects)
Plik: `src/types.ts` (do dodania/weryfikacji)
```typescript
// ... existing types
export type LedgerEntryKind = z.infer<typeof LedgerKindSchema>;

export interface LedgerEntryDto {
  id: string;
  kind: LedgerEntryKind;
  amount: number;
  details: Record<string, any>;
  createdAt: string;
}

export interface LedgerEntriesResponseDto {
  items: LedgerEntryDto[];
  nextCursor: string | null;
}
```

## 4. Przepływ danych

1.  Klient wysyła żądanie `GET` do `/api/tokens/ledger` z opcjonalnymi parametrami `kind`, `cursor`, `limit`.
2.  Middleware Astro (`src/middleware/index.ts`) weryfikuje sesję użytkownika. Jeśli sesja jest nieprawidłowa, zwraca `401 Unauthorized`.
3.  Handler API w `src/pages/api/tokens/ledger.ts` przejmuje żądanie.
4.  Parametry zapytania są walidowane i parsowane przy użyciu `GetLedgerEntriesQuerySchema`. W przypadku błędu walidacji zwracany jest status `400 Bad Request`.
5.  Handler wywołuje metodę `TokensService.getLedgerEntries`, przekazując ID użytkownika z sesji oraz zwalidowane parametry.
6.  `TokensService` dekoduje `cursor` (jeśli istnieje), aby uzyskać znacznik czasu i ID ostatniego pobranego elementu.
7.  Serwis buduje zapytanie SQL do Supabase, wybierając dane z tabeli `token_ledger`.
8.  Zapytanie bezwzględnie zawiera klauzulę `WHERE user_id = :userId`.
9.  Jeśli podano `kind`, do zapytania dodawany jest warunek `AND kind = :kind`.
10. Implementowana jest paginacja oparta na kursorze (keyset pagination). Warunek `WHERE` będzie filtrował rekordy starsze niż te wskazane przez kursor: `(created_at, id) < (:cursorCreatedAt, :cursorId)`.
11. Wyniki są sortowane malejąco: `ORDER BY created_at DESC, id DESC`.
12. Do zapytania dodawany jest `LIMIT` o jeden większy niż żądany, aby sprawdzić, czy istnieje następna strona.
13. Serwis mapuje wyniki z bazy danych na `LedgerEntryDto[]`.
14. Jeśli pobrano więcej wyników niż `limit`, ostatni element jest usuwany, a na podstawie jego danych (`created_at`, `id`) generowany jest nowy `nextCursor` (zakodowany w Base64). W przeciwnym razie `nextCursor` jest `null`.
15. Serwis zwraca obiekt `LedgerEntriesResponseDto`.
16. Handler API serializuje odpowiedź do formatu JSON i wysyła ją do klienta ze statusem `200 OK`.

## 5. Względy bezpieczeństwa

- **Uwierzytelnianie:** Endpoint musi być dostępny wyłącznie dla zalogowanych użytkowników. Middleware Astro zapewni, że `Astro.locals.session` istnieje.
- **Autoryzacja:** Każde zapytanie do bazy danych musi zawierać warunek `WHERE user_id = :current_user_id`, aby uniemożliwić dostęp do danych innych użytkowników. Jest to krytyczny wymóg bezpieczeństwa.
- **Walidacja Danych Wejściowych:** Wszystkie parametry pochodzące od klienta (`kind`, `cursor`, `limit`) muszą być rygorystycznie walidowane za pomocą Zod, aby zapobiec błędom i atakom (np. SQL Injection, nadmierne zużycie zasobów).

## 6. Obsługa błędów

- **`400 Bad Request`:** Zwracany, gdy walidacja parametrów zapytania przy użyciu Zod nie powiedzie się. Odpowiedź powinna zawierać szczegóły błędu.
- **`401 Unauthorized`:** Zwracany przez middleware, gdy użytkownik nie jest uwierzytelniony.
- **`500 Internal Server Error`:** Zwracany w przypadku nieoczekiwanych problemów, takich jak błąd połączenia z bazą danych. Błąd powinien być logowany po stronie serwera w celu dalszej analizy.

## 7. Rozważania dotyczące wydajności

- **Indeksowanie bazy danych:** Aby zapewnić szybkie działanie zapytań, kluczowe jest założenie złożonego indeksu na tabeli `token_ledger` dla kolumn używanych w klauzulach `WHERE` i `ORDER BY`. Sugerowany indeks: `(user_id, kind, created_at DESC, id DESC)`.
- **Paginacja:** Wykorzystanie paginacji opartej na kursorze (keyset pagination) jest znacznie wydajniejsze dla dużych zbiorów danych w porównaniu do paginacji opartej na offsecie, ponieważ unika skanowania całej tabeli.
- **Limit wyników:** Twardy maksymalny `limit` (np. 50) w walidacji Zod chroni bazę danych przed zbyt dużymi i kosztownymi zapytaniami.

## 8. Etapy wdrożenia

1.  **Typy i Schematy:**
    -   Utwórz nowy plik `src/lib/schemas/token.schema.ts`.
    -   Zdefiniuj w nim `LedgerKindSchema` oraz `GetLedgerEntriesQuerySchema`.
    -   W pliku `src/types.ts` dodaj typy `LedgerEntryKind`, `LedgerEntryDto` i `LedgerEntriesResponseDto`.

2.  **Migracja Bazy Danych:**
    -   Utwórz nowy plik migracji w `supabase/migrations/`.
    -   Dodaj w nim polecenie SQL tworzące złożony indeks na tabeli `token_ledger`:
        ```sql
        CREATE INDEX IF NOT EXISTS idx_token_ledger_user_kind_created_at_id ON public.token_ledger (user_id, kind, created_at DESC, id DESC);
        ```

3.  **Logika Serwisu:**
    -   W pliku `src/lib/services/tokens.service.ts` zaimplementuj metodę `getLedgerEntries`.
    -   Metoda powinna przyjmować `userId` i zwalidowane parametry zapytania.
    -   Zaimplementuj logikę dekodowania kursora, budowania dynamicznego zapytania Supabase, pobierania danych i generowania nowego kursora.

4.  **Endpoint API:**
    -   Utwórz plik `src/pages/api/tokens/ledger.ts`.
    -   Dodaj `export const prerender = false;`.
    -   Zaimplementuj handler `GET`, który:
        -   Sprawdza sesję użytkownika.
        -   Waliduje parametry zapytania przychodzącego za pomocą `GetLedgerEntriesQuerySchema`.
        -   Wywołuje `TokensService.getLedgerEntries`.
        -   Obsługuje potencjalne błędy i zwraca odpowiednie kody statusu.
        -   Zwraca pomyślną odpowiedź w formacie JSON.
