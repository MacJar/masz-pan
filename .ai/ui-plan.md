# Architektura UI dla MaszPan

## 1. Przegląd struktury UI

- **Stos i paradygmat**: Astro 5 (SSR/SSG dla publicznych stron) + wyspy React 19 dla części dynamicznych (formularze, listy z kursorem, steppery, uploadery). TypeScript 5, Tailwind 4, shadcn/ui.
- **Podział tras**:
  - Publiczne: `/tools/:id`, `/tools/search`, `/u/:id` (+ zasoby statyczne).
  - Chronione (guard w `src/middleware/index.ts`): brak sesji → `/auth`; niekompletny profil → `/profile/edit`. Chronione m.in.: `/profile`, `/tools/new`, `/tools/:id/edit`, `/tools?owner=me`, `/reservations`, `/tokens`.
- **Nawigacja**: stały pasek top‑nav (logo → `/tools/search`), sekcje: Tools, Reservations, Tokens, Profile. Na mobile skrócona nawigacja i priorytety CTA.
- **Zarządzanie danymi**: TanStack Query (SWR/stale‑while‑revalidate, infinite scroll na kursorach, prefetch). Różnicowane `staleTime`: tools 2m, reservations 10s, ratings 30m.
- **Obsługa błędów i UX**: centralny `apiClient` z mapowaniem kodów 401/403/404/409/422/429 do toastów/inline-errors, retry/backoff, Idempotency‑Key dla mutacji krytycznych.
- **Dostępność i wydajność**: mobile‑first, WCAG AA, focus management, obsługa klawiatury, lazy‑load obrazów, skeletony i sensowne puste stany.
- **Bezpieczeństwo**: ukrywanie akcji wg ról/stanu; brak ujawniania e‑maili przed warunkami (kontakty tylko z `/api/reservations/:id/contacts` po potwierdzeniu); walidacje po stronie UI spójne z API; brak bezpośrednich zapisów do Storage (tylko signed URLs).

## 2. Lista widoków

- **Wyszukiwanie narzędzi**
  - **Ścieżka widoku**: `/tools/search`
  - **Główny cel**: Znalezienie aktywnych narzędzi w promieniu 10 km od lokalizacji profilu, filtrowane po tekście.
  - **Kluczowe informacje do wyświetlenia**:
    - Pasek wyszukiwania (q), lista wyników posortowana po odległości, dystans w metrach/km, nazwa, miniatura, sugerowana cena, właściciel + średnia ocena (jeśli dostępna), informacja o braku wyników.
  - **Kluczowe komponenty widoku**:
    - SearchBar, ResultsList (infinite scroll na kursorze), ToolCard (z dystansem), EmptyState, ErrorState, SkeletonList.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Wymaga ustawionej lokalizacji profilu; jeśli brak → baner/CTA do `/profile/edit`.
    - Przy długich ładowaniach skeletony; obsługa klawiatury i fokusów w wynikach.
    - Ograniczenie liczby zapytań (debounce), poprawne komunikaty przy 401/400/429.
    - Powiązane user stories: US‑020, US‑021, US‑022, US‑023.

- **Szczegóły narzędzia**
  - **Ścieżka widoku**: `/tools/:id`
  - **Główny cel**: Prezentacja pełnych informacji o narzędziu oraz CTA rezerwacji.
  - **Kluczowe informacje do wyświetlenia**:
    - Nazwa, opis, galeria zdjęć, sugerowana cena (1–5 Ż), status, właściciel (link do `/u/:id`), średnia ocena właściciela i liczba ocen, CTA „Zgłoś zapytanie”.
    - Dla właściciela: linki do edycji/publikacji, stan publikacji.
  - **Kluczowe komponenty widoku**:
    - ImageGallery (lazy), OwnerBadge z ratingiem, PriceBadge, ActionBar (CTA zależne od roli), SeoMeta (OG/Twitter).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Brak CTA rezerwacji dla właściciela własnego narzędzia.
    - Obsługa braków danych (brak zdjęć → placeholder).
    - Publiczna strona z SSR/SSG i prefetch danych właściciela/ocen.
    - Powiązane user stories: US‑030, US‑051.

- **Dodawanie narzędzia**
  - **Ścieżka widoku**: `/tools/new` (chronione)
  - **Główny cel**: Utworzenie szkicu narzędzia (draft) i przygotowanie do publikacji.
  - **Kluczowe informacje do wyświetlenia**:
    - Formularz: nazwa (wymagana), opis (opcjonalny), sugerowana cena (1–5), uploader minimum 1 zdjęcie, przycisk AI „Zaproponuj opis”.
  - **Kluczowe komponenty widoku**:
    - ToolForm (React), AIDescribeButton (POST `/api/ai/describe-tool`), ImageUploader (drag‑and‑drop, podpisywane URL, progres, kolejność), PublishCallout z warunkami publikacji.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Walidacje po stronie klienta (1–5), obsługa 413/415 przy uploadzie, dyskretny błąd AI bez blokowania zapisu.
    - Po pomyślnym zapisie wyraźny CTA do „Publikuj” (oddzielny krok).
    - Powiązane user stories: US‑010, US‑011, US‑041, US‑061.

- **Edycja narzędzia**
  - **Ścieżka widoku**: `/tools/:id/edit` (chronione, tylko właściciel)
  - **Główny cel**: Aktualizacja danych narzędzia i zarządzanie zdjęciami.
  - **Kluczowe informacje do wyświetlenia**:
    - Ten sam formularz co „Dodaj”, kolejność zdjęć, usuwanie, dodawanie.
    - Widoczne ograniczenia (edycja nie zmienia cen w już istniejących rezerwacjach).
  - **Kluczowe komponenty widoku**:
    - ToolForm, ImageManager (sort/drag), DangerZone (archiwizacja).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Spójne walidacje i błędy jak przy tworzeniu.
    - Ukrycie akcji niezgodnych z RLS i aktualnym stanem.
    - Powiązane user stories: US‑012, US‑013.

- **Moje narzędzia (lista właściciela)**
  - **Ścieżka widoku**: `/tools?owner=me` (chronione)
  - **Główny cel**: Przegląd własnych narzędzi, stanów i szybkie akcje.
  - **Kluczowe informacje do wyświetlenia**:
    - Lista narzędzi z metadanymi: status (draft/active/archived), daty, skróty do edycji/publikacji.
  - **Kluczowe komponenty widoku**:
    - OwnerToolsList, ToolRow z akcjami (Edit/Publish/Archive), EmptyState (CTA „Dodaj narzędzie”).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Filtry po statusie, paginacja kursorowa.
    - Potwierdzenia akcji destrukcyjnych (dialog).
    - Powiązane user stories: US‑014.

- **Rezerwacje (Pożyczam/Użyczam)**
  - **Ścieżka widoku**: `/reservations` (chronione)
  - **Główny cel**: Zarządzanie rezerwacjami w dwóch rolach, podgląd stanu i akcje przejść.
  - **Kluczowe informacje do wyświetlenia**:
    - Tabs: „Pożyczam” (borrower) i „Użyczam” (owner).
    - Karty rezerwacji ze stepperem stanów: requested → owner_accepted (z ceną) → borrower_confirmed → picked_up → returned; wsparcie cancel/reject.
    - Po obustronnym potwierdzeniu: sekcja z e‑mailami stron (pobierane warunkowo).
  - **Kluczowe komponenty widoku**:
    - ReservationsTabs, ReservationCard, ReservationStepper, TransitionActions (Idempotency‑Key, optimistic updates), ContactsReveal.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Jasne komunikaty przy 409/422 (np. błędna sekwencja), rollback optymistycznych zmian, wyraźne stany nieaktywne przy braku uprawnień.
    - Powiązane user stories: US‑031, US‑032, US‑033, US‑034, US‑035, US‑036, US‑037, US‑038, US‑092, US‑070, US‑043.

- **Żetony (saldo i ledger)**
  - **Ścieżka widoku**: `/tokens` (chronione)
  - **Główny cel**: Podgląd salda (total/held/available), przegląd historii oraz szybkie akcje bonusowe.
  - **Kluczowe informacje do wyświetlenia**:
    - Karty salda, lista ledger (paginacja kursorowa, filtrowanie po kind).
    - Akcje: signup bonus (jednorazowy), listing bonus (dla narzędzia), rescue (+1/dzień gdy available==0) z prezentacją daty/dostępności.
  - **Kluczowe komponenty widoku**:
    - TokenBalanceCard, LedgerList, BonusActions (z warunkowym włączeniem), RescueInfo (CET).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Jasne wyjaśnienia reguł i ograniczeń, kontrola stanów nieaktywnych, toast po sukcesie, ostrzeżenia przy 409/422.
    - Powiązane user stories: US‑040, US‑041, US‑042, US‑043.

- **Mój profil**
  - **Ścieżka widoku**: `/profile` (chronione)
  - **Główny cel**: Podgląd własnego profilu (nazwa, lokalizacja, status RODO), skróty do akcji.
  - **Kluczowe informacje do wyświetlenia**:
    - Nazwa użytkownika, lokalizacja tekstowa, status geokodowania, znacznik zgody RODO, skróty do „Moje narzędzia”, „Żetony”, „Rezerwacje”.
  - **Kluczowe komponenty widoku**:
    - ProfileSummary, QuickActions, LocationStatus (geokodowanie).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Jasny status kompletności profilu; jeśli niekompletny → callout do edycji.
    - Powiązane user stories: US‑003, US‑004, US‑005.

- **Edycja profilu / Onboarding**
  - **Ścieżka widoku**: `/profile/edit` (chronione; redirect z guardu przy niekompletnym profilu)
  - **Główny cel**: Uzupełnienie/aktualizacja nazwy, lokalizacji i zgody RODO; wywołanie geokodowania.
  - **Kluczowe informacje do wyświetlenia**:
    - Formularz: username, location_text, rodo_consent; przycisk „Geokoduj teraz”.
    - Feedback sukces/błąd geokodera; instrukcje korekty przy 422.
  - **Kluczowe komponenty widoku**:
    - ProfileForm, GeocodeAction, FormErrors, SuccessBanner.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Blokada przejścia do chronionych sekcji do czasu kompletności.
    - Komunikaty kontekstowe; focus na polu z błędem.
    - Powiązane user stories: US‑003, US‑004, US‑021, US‑005.

- **Profil publiczny**
  - **Ścieżka widoku**: `/u/:id`
  - **Główny cel**: Publiczny widok profilu: nazwa, średnia ocena, liczba ocen, lista aktywnych narzędzi użytkownika.
  - **Kluczowe informacje do wyświetlenia**:
    - Username, rating avg + count, linki do narzędzi (aktywne).
  - **Kluczowe komponenty widoku**:
    - PublicProfileHeader, RatingSummary, PublicToolsGrid, SeoMeta.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Brak wrażliwych danych; SSR/SSG; puste stany gdy brak narzędzi/ocen.
    - Powiązane user stories: US‑006, US‑051.

- **Auth**
  - **Ścieżka widoku**: `/auth` (publiczna)
  - **Główny cel**: Logowanie/Rejestracja poprzez `@supabase/auth-ui` (etap późniejszy).
  - **Kluczowe informacje do wyświetlenia**:
    - Ekrany logowania/rejestracji, linki pomocnicze.
  - **Kluczowe komponenty widoku**:
    - AuthUIWrapper, AuthGuardNotice (modal informacyjny przy akcjach wymagających logowania).
  - **UX, dostępność i względy bezpieczeństwa**:
    - Czytelne komunikaty błędów logowania; focus management; bezpieczne redirecty po zalogowaniu.
    - Powiązane user stories: US‑001, US‑002, US‑005.

- **Błędy i strony systemowe**
  - **Ścieżki widoku**: 401/403 (komponent), 404 (`/*` fallback), 500 (error boundary)
  - **Główny cel**: Spójna prezentacja błędów, propozycje następnych kroków (CTA powrotu, retry).
  - **Kluczowe informacje do wyświetlenia**:
    - Przyjazne treści, krótkie wyjaśnienie, link powrotny do `/tools/search`.
  - **Kluczowe komponenty widoku**:
    - ErrorBoundary, NotFoundPage, ForbiddenPage, UnauthorizedPage.
  - **UX, dostępność i względy bezpieczeństwa**:
    - Czytelny kontrast, opcje kontaktu (mailto:admin@maszpan.pl), bez ujawniania szczegółów wewnętrznych.
    - Powiązane user stories: US‑080, US‑090 (realizowane gł. przez RLS i guardy).

## 3. Mapa podróży użytkownika

- **Onboarding i przygotowanie**:
  - Rejestracja/logowanie → guard → `/profile/edit` → uzupełnienie profilu (username, RODO, lokalizacja) → „Geokoduj teraz” → sukces 200 i powrót do `/tools/search`.
  - Po kompletności profilu: jednorazowy signup bonus dostępny na `/tokens`.
- **Publikacja narzędzia (właściciel)**:
  - `/tools/new` → wypełnienie danych → upload min. 1 zdjęcia (progres, kompresja) → zapis (draft) → CTA „Publikuj” → publikacja → narzędzie widoczne publicznie na `/tools/:id` oraz w `/u/:id`.
- **Wyszukiwanie i rezerwacja (pożyczający)**:
  - `/tools/search` (q + lokalizacja profilu) → wybór narzędzia → `/tools/:id` → CTA „Zgłoś zapytanie” → utworzenie rezerwacji (status requested) → w `/reservations` (Pożyczam) śledzenie stanu.
- **Akceptacja i potwierdzenie (właściciel → pożyczający)**:
  - Właściciel (Użyczam) wpisuje kwotę → status `owner_accepted` → pożyczający potwierdza → status `borrower_confirmed` → system ujawnia e‑maile (`/reservations/:id/contacts`).
- **Odbiór i zwrot**:
  - Pożyczający oznacza „Odebrałem” (blokada żetonów) → po zwrocie właściciel oznacza „Narzędzie wróciło” (transfer).
  - Po zakończeniu każda strona wystawia ocenę 1–5.
- **Alternatywne ścieżki i wyjątki**:
  - Anulowanie możliwe przed finalnym transferem; zwalnia blokady.
  - Rescue token +1/dzień gdy available==0 na `/tokens`.
  - Błędy sekwencji przejść → 409 i rollback optymistyczny + informacja w stepperze.

## 4. Układ i struktura nawigacji

- **Top‑level nawigacja** (stała):
  - Logo (link do `/tools/search`)
  - Tools (podmenu: Search `/tools/search`, My tools `/tools?owner=me`, New `/tools/new`)
  - Reservations `/reservations`
  - Tokens `/tokens`
  - Profile (podmenu: My profile `/profile`, Edit `/profile/edit`, Public `/u/:id`)
  - Auth (gdy wylogowany): przyciski „Zaloguj”/„Zarejestruj”
- **Wewnątrz widoków**:
  - Breadcrumby dla edycji narzędzi i rezerwacji; powrót do listy; prefetch sąsiednich danych.
  - Na mobile: skrócona nawigacja, CTA priorytetowe (np. „Dodaj narzędzie”, „Nowe zapytanie”).
- **Guardy i przekierowania**:
  - Brak sesji → `/auth`
  - Niekompletny profil → `/profile/edit` (z bannerem wyjaśniającym)
  - Publiczne wyjątki: `/tools/:id`, `/tools/search`, `/u/:id`

## 5. Kluczowe komponenty

- **SearchBar**: pole q z debounce, dostępna etykieta, wskaźnik busy, submit/Enter.
- **ToolCard / ToolRow**: miniatura, nazwa, cena, dystans, właściciel z ratingiem (tooltip liczby ocen), CTA „Szczegóły”.
- **ImageUploader / ImageManager**: drag‑and‑drop, kompresja klienta, walidacje typów/rozmiaru, progres, kolejność, retry, usuwanie; integracja z signed upload URL i rejestrem obrazu.
- **ImageGallery**: lazy‑load, klawiatura, zoom/ARIA poprawna dla galerii.
- **ToolForm**: walidacje 1–5, inline errors, AIDescribeButton z bezpiecznym fallbackiem.
- **ReservationsTabs + ReservationCard**: widoki rolowe (borrow/owner), metadane narzędzia, aktualny status, akcje dopuszczalne dla roli.
- **ReservationStepper**: wizualizacja stanów; akcje przejść (POST transition/cancel) z Idempotency‑Key; optymistyczne aktualizacje i rollback.
- **ContactsReveal**: ujawnienie e‑maili po spełnieniu warunków (GET contacts), kopiuj do schowka.
- **TokenBalanceCard**: total/held/available; wizualna różnica; tooltip z definicjami.
- **LedgerList**: kursorowa lista wpisów; filtr po `kind`; ikony dla award/hold/transfer.
- **BonusActions**: Signup/Listing/Rescue; warunkowe włączenie; jasne komunikaty 409/422.
- **RatingStars / RatingSummary**: wystawianie oceny 1–5 po zakończeniu, agregat dla profilu publicznego i właściciela narzędzia.
- **EmptyState / ErrorState / Skeletons**: spójne dla list i detali, linki nawrotu i CTA.
- **Toast/Dialog/Form (shadcn/ui)**: spójne wzorce, focus management, a11y.
- **apiClient**: interceptory błędów, mapowanie statusów, retry/backoff, Idempotency‑Key.
- **RouteGuards**: integracja z middleware i stanem profilu; banery informacyjne.


