# Plan implementacji widoku – Moje Rezerwacje

## 1. Przegląd

Celem jest stworzenie widoku `/reservations`, który pozwoli zalogowanym użytkownikom zarządzać swoimi rezerwacjami narzędzi. Widok będzie podzielony na dwie główne sekcje (zakładki): "Pożyczam", gdzie użytkownik jest biorcą narzędzia, oraz "Użyczam", gdzie jest jego właścicielem. Komponenty umożliwią śledzenie statusu rezerwacji oraz wykonywanie akcji zmieniających jej stan, zgodnie z zdefiniowanym w PRD cyklem życia transakcji.

## 2. Routing widoku

- **Ścieżka**: `/tools/my-reservations`
- **Dostęp**: Strona chroniona, wymagająca zalogowanego użytkownika. Użytkownicy niezalogowani powinni być przekierowani na stronę logowania.

## 3. Struktura komponentów

Widok zostanie zaimplementowany jako interaktywna "wyspa" React w ramach strony Astro.

```
/src/pages/tools/my-reservations.astro
└── /src/components/reservations/ReservationsView.tsx (client:load)
    ├── useReservationsManager.ts (Custom Hook)
    ├── ui/Tabs.tsx (Komponent shadcn/ui)
    │   ├── ReservationList.tsx
    │   │   ├── SkeletonList.tsx (Stan ładowania)
    │   │   ├── EmptyState.tsx (Brak rezerwacji)
    │   │   └── ReservationCard.tsx
    │   │       ├── ReservationStepper.tsx
    │   │       ├── ContactDetails.tsx
    │   │       └── ActionButtons.tsx
    │   │           └── ActionConfirmationDialog.tsx
    └── ui/sonner.tsx (Toast notifications)
```

## 4. Szczegóły komponentów

### `ReservationsView.tsx`

- **Opis**: Główny komponent widoku, który zarządza stanem (aktywna zakładka) i renderuje odpowiednie komponenty podrzędne. Wykorzystuje hook `useReservationsManager` do całej logiki biznesowej.
- **Główne elementy**: Komponent `Tabs` z `shadcn/ui` do przełączania widoków "Pożyczam" i "Użyczam". Dla każdej zakładki renderowany jest `ReservationList`.
- **Obsługiwane interakcje**: Przełączanie zakładek.
- **Typy**: `ReservationViewModel`.
- **Propsy**: Brak.

### `useReservationsManager.ts`

- **Opis**: Custom hook agregujący całą logikę: pobieranie danych, zarządzanie stanem ładowania i błędów, oraz obsługę akcji (zmiana stanu rezerwacji, anulowanie).
- **Zarządzany stan**:
  - `activeTab: 'borrower' | 'owner'`
  - `reservations: Record<'borrower' | 'owner', ReservationViewModel[]>`
  - `isLoading: boolean`
  - `error: AppError | null`
- **Funkcje eksportowane**:
  - `state`: Obiekt z powyższymi polami stanu.
  - `setActiveTab`: Funkcja do zmiany aktywnej zakładki.
  - `transitionState`: Funkcja do zmiany stanu rezerwacji.
  - `cancelReservation`: Funkcja do anulowania rezerwacji.

### `ReservationList.tsx`

- **Opis**: Renderuje listę rezerwacji dla aktywnej zakładki. Obsługuje stany ładowania (pokazuje `SkeletonList`) oraz pustej listy (pokazuje `EmptyState`).
- **Główne elementy**: Mapowanie po liście rezerwacji i renderowanie komponentów `ReservationCard`.
- **Typy**: `ReservationViewModel[]`.
- **Propsy**:
  - `reservations: ReservationViewModel[]`
  - `isLoading: boolean`
  - `userRole: 'owner' | 'borrower'`
  - `onTransition: (id, status, payload) => void`
  - `onCancel: (id) => void`

### `ReservationCard.tsx`

- **Opis**: Wyświetla szczegóły pojedynczej rezerwacji. Pokazuje kluczowe dane, wizualny wskaźnik statusu (`ReservationStepper`), dane kontaktowe (`ContactDetails`) oraz przyciski akcji (`ActionButtons`).
- **Główne elementy**: Układ karty z informacjami o narzędziu, użytkowniku i statusie.
- **Typy**: `ReservationViewModel`.
- **Propsy**:
  - `reservation: ReservationViewModel`
  - `userRole: 'owner' | 'borrower'`
  - `onTransition: (id, status, payload) => void`
  - `onCancel: (id) => void`

### `ReservationStepper.tsx`

- **Opis**: Komponent wizualny, który pokazuje aktualny status rezerwacji na osi czasu (np. jako "kroki").
- **Główne elementy**: Elementy `div` stylizowane w zależności od statusu.
- **Typy**: `ReservationStatus`.
- **Propsy**:
  - `status: ReservationStatus`

### `ActionButtons.tsx`

- **Opis**: Renderuje przyciski akcji dostępne dla danego statusu rezerwacji i roli użytkownika. Np. przycisk "Akceptuj" dla właściciela przy statusie `requested`.
- **Główne elementy**: Komponenty `Button` i `ActionConfirmationDialog`.
- **Obsługiwane interakcje**: Kliknięcie przycisku inicjuje zmianę stanu lub otwiera dialog potwierdzający.
- **Warunki walidacji**: W przypadku akceptacji przez właściciela, dialog powinien zawierać pole `input type="number"` do wpisania ceny w żetonach, walidowane jako liczba całkowita dodatnia.
- **Typy**: `ReservationViewModel`.
- **Propsy**:
  - `reservation: ReservationViewModel`
  - `userRole: 'owner' | 'borrower'`
  - `onTransition: (id, status, payload) => void`
  - `onCancel: (id) => void`

### `ContactDetails.tsx`

- **Opis**: Warunkowo wyświetla dane kontaktowe (e-mail) drugiej strony transakcji.
- **Główne elementy**: Kontener z danymi kontaktowymi.
- **Warunki**: Renderuje się tylko, gdy status rezerwacji to `borrower_confirmed` lub późniejszy. Dane pobierane są leniwie po kliknięciu przycisku "Pokaż kontakt".
- **Typy**: `ReservationContactsDto`.
- **Propsy**:
  - `reservationId: string`
  - `status: ReservationStatus`

## 5. Typy

Oprócz typów DTO z `src/types.ts`, kluczowy będzie ViewModel, który dostosowuje dane do potrzeb widoku.

```typescript
// Plik: src/components/reservations/reservations.types.ts

import type { ReservationWithToolDTO, ReservationStatus } from "@/types";

// Definiuje możliwe akcje do wykonania na rezerwacji
export type ReservationAction =
  | { type: 'accept'; requiresPrice: true }
  | { type: 'confirm' }
  | { type: 'markAsPickedUp' }
  | { type: 'markAsReturned' }
  | { type: 'cancel' }
  | { type: 'reject' };

// Rozszerza DTO o dane potrzebne do logiki UI
export interface ReservationViewModel extends ReservationWithToolDTO {
  // Rola bieżącego użytkownika w kontekście tej rezerwacji
  currentUserRole: 'owner' | 'borrower';
  
  // Dane drugiej strony transakcji
  counterparty: {
    id: string;
    username: string | null;
  };

  // Lista akcji, które bieżący użytkownik może wykonać w danym stanie
  availableActions: ReservationAction[];
}
```

## 6. Zarządzanie stanem

Cała logika stanu zostanie zamknięta w custom hooku `useReservationsManager.ts`. Takie podejście oddziela logikę od prezentacji, ułatwia testowanie i utrzymanie kodu. Hook będzie odpowiedzialny za:
- Przechowywanie stanu aktywnej zakładki.
- Pobieranie i przechowywanie listy rezerwacji dla obu ról.
- Zarządzanie stanami `isLoading` i `error`.
- Udostępnianie funkcji do modyfikacji stanu (przejścia, anulowanie), które będą wywoływać API i optymistycznie aktualizować UI, a w razie błędu cofać zmiany i pokazywać powiadomienie.

## 7. Integracja API

Hook `useReservationsManager` będzie korzystał z następujących endpointów:

1.  **`GET /api/reservations`**
    - **Cel**: Pobranie listy rezerwacji dla zalogowanego użytkownika.
    - **Parametry**: `?role=owner` lub `?role=borrower`.
    - **Odpowiedź**: `ReservationWithToolDTO[]`.

2.  **`POST /api/reservations/:id/transition`**
    - **Cel**: Zmiana stanu rezerwacji.
    - **Payload**: `ReservationTransitionCommand` (z `new_status` i opcjonalnie `price_tokens`).
    - **Odpowiedź**: `ReservationTransitionResultDTO`.

3.  **`POST /api/reservations/:id/cancel`**
    - **Cel**: Anulowanie rezerwacji.
    - **Payload**: `CancelReservationCommand` (z `cancelled_reason`).
    - **Odpowiedź**: Zaktualizowany obiekt rezerwacji.

4.  **`GET /api/reservations/:id/contacts`**
    - **Cel**: Pobranie e-maili stron transakcji.
    - **Odpowiedź**: `ReservationContactsDto`.

## 8. Interakcje użytkownika

- **Zmiana zakładki**: Kliknięcie na "Pożyczam" lub "Użyczam" zmienia `activeTab` w hooku, co powoduje pobranie danych dla danej roli (jeśli nie były jeszcze ładowane) i przefiltrowanie wyświetlanej listy.
- **Akceptacja rezerwacji (właściciel)**: Kliknięcie "Akceptuj" otwiera dialog, w którym właściciel wpisuje cenę. Po zatwierdzeniu wywoływana jest funkcja `transitionState` z `new_status: 'owner_accepted'` i podaną ceną.
- **Potwierdzenie warunków (biorca)**: Kliknięcie "Potwierdź" wywołuje `transitionState` z `new_status: 'borrower_confirmed'`.
- **Anulowanie**: Kliknięcie "Anuluj" otwiera dialog z prośbą o podanie powodu, a następnie wywołuje `cancelReservation`.
- **Pokazanie kontaktu**: Po osiągnięciu statusu `borrower_confirmed`, pojawia się przycisk "Pokaż kontakt", który po kliknięciu wywołuje `GET /api/reservations/:id/contacts` i wyświetla dane.

## 9. Warunki i walidacja

- **Dostęp do akcji**: Komponent `ActionButtons` będzie renderował przyciski tylko wtedy, gdy `reservation.availableActions` zawiera daną akcję. Logika mapowania stanu i roli na dostępne akcje zostanie zaimplementowana w hooku `useReservationsManager` podczas transformacji DTO na ViewModel.
- **Walidacja ceny**: W dialogu akceptacji rezerwacji, pole ceny będzie walidowane na poziomie frontendu, aby upewnić się, że jest to dodatnia liczba całkowita. Zapobiegnie to wysyłaniu niepoprawnych żądań do API.

## 10. Obsługa błędów

- **Błędy sieciowe/serwera (5xx)**: Hook `useReservationsManager` ustawi stan `error`. Komponent `ReservationsView` wyświetli ogólny komunikat o błędzie.
- **Błędy walidacji/konfliktu (4xx)**: W przypadku błędów takich jak nieprawidłowe przejście stanu (409) lub niewystarczająca ilość żetonów (422), odpowiedź z API zostanie przechwycona. Użytkownik zobaczy powiadomienie (toast) z konkretnym komunikatem błędu. W przypadku optymistycznego UI, stan zostanie przywrócony do poprzedniego.
- **Brak autoryzacji (401)**: Middleware na poziomie Astro powinien przechwycić brak sesji i przekierować na stronę logowania.

## 11. Kroki implementacji

1.  **Struktura plików**: Stworzenie strony `/src/pages/tools/my-reservations.astro` oraz folderu `/src/components/reservations` z plikami dla wszystkich komponentów i hooka.
2.  **Definicja typów**: Zdefiniowanie `ReservationViewModel` i `ReservationAction` w pliku `reservations.types.ts`.
3.  **Implementacja hooka `useReservationsManager`**:
    - Zdefiniowanie stanu (state).
    - Implementacja logiki pobierania danych z API (`GET /api/reservations`).
    - Stworzenie funkcji mapującej DTO na ViewModel, w tym logiki określającej `availableActions`.
4.  **Budowa komponentów statycznych**:
    - Stworzenie `ReservationsView` z komponentem `Tabs`.
    - Implementacja `ReservationList`, `SkeletonList` i `EmptyState`.
    - Stworzenie `ReservationCard` i `ReservationStepper` wyświetlających statyczne dane przekazane przez propsy.
5.  **Integracja hooka z UI**:
    - Podłączenie `useReservationsManager` do `ReservationsView`.
    - Przekazanie stanu (`reservations`, `isLoading`) do `ReservationList` w celu dynamicznego renderowania.
6.  **Implementacja akcji**:
    - Stworzenie komponentu `ActionButtons` i `ActionConfirmationDialog`.
    - Implementacja logiki warunkowego renderowania przycisków na podstawie `availableActions` z ViewModelu.
    - Podłączenie `onClick` przycisków do funkcji `transitionState` i `cancelReservation` z hooka.
7.  **Implementacja optymistycznych aktualizacji**: Rozbudowanie funkcji `transitionState` i `cancelReservation` o natychmiastową aktualizację stanu UI przed odpowiedzią z serwera, oraz logikę cofania zmian w przypadku błędu.
8.  **Obsługa błędów i powiadomień**: Integracja z `sonner` (toast) w celu wyświetlania komunikatów o sukcesie i błędach operacji.
9.  **Dane kontaktowe**: Implementacja komponentu `ContactDetails` z logiką leniwego pobierania danych.
10. **Styling i finalizacja**: Dopracowanie stylów (TailwindCSS) i responsywności widoku.


