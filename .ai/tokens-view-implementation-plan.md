# Plan implementacji widoku Żetony

## 1. Przegląd
Widok "Żetony" ma na celu zapewnienie użytkownikom wglądu w ich saldo i historię transakcji żetonami w systemie. Umożliwia również zdobywanie dodatkowych żetonów poprzez realizację jednorazowych akcji bonusowych, takich jak bonus za rejestrację, za wystawienie pierwszych narzędzi oraz dzienny "bonus ratunkowy" dla użytkowników z zerowym saldem.

## 2. Routing widoku
Widok będzie dostępny pod chronioną ścieżką `/tokens`. Dostęp do niego będzie wymagał uwierzytelnienia użytkownika.

## 3. Struktura komponentów
Komponenty zostaną zaimplementowane w React i osadzone na stronie Astro (`/src/pages/tokens.astro`) z dyrektywą `client:load`.

```
/src/pages/tokens.astro
  └── TokensView (React)
      ├── TokenBalanceCard
      ├── BonusActions
      |   ├── SignupBonusButton
      |   ├── ListingBonusForm
      |   |   └── ToolSelector
      |   └── RescueBonusButton
      |       └── RescueInfo
      └── LedgerList
          ├── LedgerFilterControls
          └── LedgerEntryItem (mapowany)
          └── LoadMoreButton
```

## 4. Szczegóły komponentów

### `TokensView` (Komponent główny)
- **Opis komponentu**: Główny kontener widoku, odpowiedzialny za orkiestrację stanu, pobieranie danych i komunikację między komponentami podrzędnymi. Wykorzysta customowy hook `useTokensView` do zarządzania logiką.
- **Główne elementy**: `TokenBalanceCard`, `BonusActions`, `LedgerList`.
- **Obsługiwane interakcje**: Brak bezpośrednich. Przekazuje obsługę zdarzeń do `useTokensView`.
- **Obsługiwana walidacja**: Brak.
- **Typy**: `TokenBalance`, `TokenLedgerEntry`, `EligibleTool`.
- **Propsy**: Brak.

### `TokenBalanceCard`
- **Opis komponentu**: Komponent prezentacyjny, wyświetlający w formie kart saldo całkowite, zablokowane i dostępne żetony użytkownika.
- **Główne elementy**: Komponent `Card` z Shadcn/ui, zawierający 3 sekcje z tytułem (np. "Dostępne") i wartością.
- **Obsługiwane interakcje**: Brak.
- **Obsługiwana walidacja**: Brak.
- **Typy**: `TokenBalance`.
- **Propsy**: `interface Props { balance: TokenBalance | null; isLoading: boolean; }`.

### `BonusActions`
- **Opis komponentu**: Sekcja zawierająca przyciski i formularze do aktywacji dostępnych bonusów. Komponent dynamicznie renderuje i zarządza stanem aktywności poszczególnych akcji.
- **Główne elementy**: Przyciski `Button` i formularz z `Select` (dla bonusu za wystawienie) z biblioteki Shadcn/ui.
- **Obsługiwane interakcje**: Kliknięcie przycisku "Odbierz bonus startowy", "Odbierz bonus ratunkowy", wybór narzędzia i wysłanie formularza "Odbierz bonus za wystawienie".
- **Obsługiwana walidacja**:
    - **Bonus startowy**: Przycisk nieaktywny, jeśli bonus został już odebrany.
    - **Bonus za wystawienie**: Formularz nieaktywny/ukryty, jeśli użytkownik wykorzystał limit (3) lub nie ma narzędzi kwalifikujących się do bonusu.
    - **Bonus ratunkowy**: Przycisk nieaktywny, jeśli saldo dostępne > 0 lub bonus na dany dzień został już odebrany.
- **Typy**: `BonusStateViewModel`, `TokenBalance`.
- **Propsy**: `interface Props { bonusState: BonusStateViewModel; balance: TokenBalance | null; onClaimSignup: () => void; onClaimListing: (toolId: string) => void; onClaimRescue: () => void; }`.

### `LedgerList`
- **Opis komponentu**: Wyświetla historię transakcji żetonami. Zarządza paginacją kursorową i filtrowaniem.
- **Główne elementy**: Lista elementów `LedgerEntryItem`, kontrolki do filtrowania (np. `Select` z Shadcn/ui) oraz przycisk "Załaduj więcej".
- **Obsługiwane interakcje**: Zmiana filtra rodzaju transakcji, kliknięcie przycisku "Załaduj więcej".
- **Obsługiwana walidacja**: Brak.
- **Typy**: `TokenLedgerEntryViewModel`.
- **Propsy**: `interface Props { entries: TokenLedgerEntryViewModel[]; hasMore: boolean; isLoading: boolean; onFilterChange: (kind: LedgerKind | null) => void; onLoadMore: () => void; }`.

## 5. Typy

### DTO (z API)
```typescript
// GET /api/tokens/balance
interface TokenBalanceDto {
  user_id: string;
  total: number;
  held: number;
  available: number;
}

// GET /api/tokens/ledger
type LedgerKind = 'debit' | 'credit' | 'hold' | 'release' | 'transfer' | 'award';
interface TokenLedgerEntryDto {
  id: string;
  kind: LedgerKind;
  amount: number;
  details: Record<string, any>;
  created_at: string; // ISO 8601
}

// GET /api/tools?bonus_eligible=true (ZAŁOŻENIE)
interface EligibleToolDto {
  id: string;
  name: string;
}
```

### ViewModel (na potrzeby UI)
```typescript
// Typ używany przez komponenty do przechowywania stanu bonusów
interface BonusStateViewModel {
  signup: {
    isClaimed: boolean;
    isLoading: boolean;
  };
  listing: {
    eligibleTools: EligibleToolDto[];
    claimsUsed: number;
    isLoading: boolean;
  };
  rescue: {
    isAvailable: boolean; // Dostępne saldo == 0
    isClaimedToday: boolean;
    isLoading: boolean;
  }
}

// Wzbogacony typ wpisu w historii do łatwiejszego wyświetlania
interface TokenLedgerEntryViewModel extends TokenLedgerEntryDto {
  formattedDate: string;
  description: string;
}
```

## 6. Zarządzanie stanem
Logika biznesowa, stan oraz operacje API zostaną scentralizowane w customowym hooku `useTokensView`.

**`useTokensView` hook:**
- **Zarządzany stan**:
    - `balance: TokenBalance | null`
    - `ledgerEntries: TokenLedgerEntryViewModel[]`
    - `ledgerCursor: string | null`
    - `ledgerFilter: LedgerKind | null`
    - `bonusState: BonusStateViewModel`
    - `isLoading: Record<string, boolean>` (np. `isLoading.balance`, `isLoading.ledger`)
    - `error: Error | null`
- **Udostępniane funkcje**:
    - `handleClaimSignupBonus`
    - `handleClaimListingBonus(toolId: string)`
    - `handleClaimRescueBonus`
    - `loadMoreLedgerEntries`
    - `setLedgerFilter`
- **Implementacja**: Zaleca się użycie biblioteki SWR lub React Query do obsługi pobierania danych, cache'owania i rewalidacji.

## 7. Integracja API
Integracja będzie opierać się na punktach końcowych zdefiniowanych w `api-plan.md`.

- **Pobieranie danych (GET)**:
    - `GET /api/tokens/balance` - do pobrania salda.
    - `GET /api/tokens/ledger` - do pobrania historii transakcji (z parametrami `cursor` i `kind`).
    - `GET /api/tools?bonus_eligible=true` - **(wymaga implementacji backendowej)** do pobrania listy narzędzi kwalifikujących się do bonusu.
- **Akcje (POST)**:
    - `POST /api/tokens/award/signup`
        - **Odpowiedź (200)**: `{ "awarded": true, "amount": 10 }`
    - `POST /api/tokens/award/listing`
        - **Request**: `{ "tool_id": "uuid" }`
        - **Odpowiedź (200)**: `{ "awarded": true, "amount": 2, "count_used": number }`
    - `POST /api/tokens/rescue`
        - **Odpowiedź (200)**: `{ "awarded": true, "amount": 1, "claim_date_cet": "YYYY-MM-DD" }`
- Po każdej udanej akcji POST, stan salda i historii transakcji powinien zostać odświeżony (rewalidacja danych).

## 8. Interakcje użytkownika
- **Ładowanie widoku**: Użytkownik widzi loadery, a następnie swoje saldo, historię transakcji i dostępne akcje bonusowe.
- **Kliknięcie akcji bonusowej**:
    - Przycisk przechodzi w stan ładowania.
    - Po pomyślnej odpowiedzi API, wyświetlany jest toast (np. `Toast` z Shadcn/ui) z informacją o sukcesie (np. "+10 żetonów przyznane!").
    - Stan interfejsu (saldo, historia, dostępność przycisku) jest aktualizowany.
- **Filtrowanie historii**: Wybór opcji z filtra powoduje ponowne załadowanie listy transakcji z nowym kryterium.
- **Paginacja historii**: Kliknięcie "Załaduj więcej" dołącza kolejne wpisy do listy i aktualizuje kursor.

## 9. Warunki i walidacja
Walidacja odbywa się na poziomie komponentu `BonusActions` i jest sterowana przez `BonusStateViewModel` oraz `TokenBalance`.
- **Dostępność bonusu startowego**: `!bonusState.signup.isClaimed && !bonusState.signup.isLoading`
- **Dostępność bonusu za wystawienie**: `bonusState.listing.eligibleTools.length > 0 && !bonusState.listing.isLoading`
- **Dostępność bonusu ratunkowego**: `balance.available === 0 && !bonusState.rescue.isClaimedToday && !bonusState.rescue.isLoading`
- Stan `isLoading` dla każdej akcji zapobiega wielokrotnemu kliknięciu.

## 10. Obsługa błędów
- **Błędy krytyczne (5xx, błąd sieci)**: W przypadku niepowodzenia pobrania początkowych danych (saldo, historia), należy wyświetlić komunikat błędu na całą stronę z opcją ponowienia próby.
- **Błędy logiki biznesowej (4xx)**:
    - `401 Unauthorized`: Przekierowanie na stronę logowania (obsługiwane globalnie).
    - `409 Conflict`: Wyświetlenie informacyjnego toasta, np. "Bonus został już odebrany" lub "Dzienny limit bonusu ratunkowego został wykorzystany".
    - `422 Unprocessable Entity`: Wyświetlenie toasta z błędem, np. "Bonus ratunkowy jest dostępny tylko przy zerowym saldzie".
- Dla każdej akcji POST, błędy powinny być komunikowane za pomocą toastów, nie blokując całego widoku.

## 11. Kroki implementacji
1.  Utworzenie pliku strony `/src/pages/tokens.astro`.
2.  Implementacja szkieletu komponentu `TokensView` w `/src/components/views/TokensView.tsx`.
3.  Zdefiniowanie typów (DTO, ViewModel) w pliku `/src/types.ts` lub dedykowanym pliku dla widoku.
4.  Stworzenie customowego hooka `useTokensView` z logiką pobierania salda i historii transakcji.
5.  Implementacja komponentów prezentacyjnych: `TokenBalanceCard` i `LedgerList` (wraz z `LedgerEntryItem`).
6.  **Komunikacja z backendem w celu potwierdzenia/stworzenia endpointu `GET /api/tools?bonus_eligible=true`.**
7.  Implementacja hooka `useTokensView` o logikę pobierania stanu bonusów i obsługę akcji POST.
8.  Implementacja komponentu `BonusActions` z warunkowym renderowaniem i logiką walidacji.
9.  Połączenie wszystkich komponentów w `TokensView` i przekazanie stanu oraz funkcji z hooka jako propsy.
10. Implementacja obsługi błędów i stanów ładowania we wszystkich komponentach.
11. Stylizacja całości za pomocą TailwindCSS zgodnie z design systemem.
12. Przeprowadzenie testów manualnych dla wszystkich scenariuszy (sukces, błąd, warunki brzegowe).


