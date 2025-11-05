# Dokument wymagań produktu (PRD) - MaszPan

## 1. Przegląd produktu

MaszPan to webowa aplikacja MVP ułatwiająca sąsiedzką wymianę narzędzi (warsztatowych, ogrodowych itp.) w oparciu o lokalne zaufanie i prosty, zrozumiały przepływ transakcyjny. MVP ma zweryfikować kluczową pętlę użycia: wystawienie narzędzia → wyszukanie w pobliżu → rezerwacja → transfer wirtualnych żetonów po zakończeniu wypożyczenia.

Zakres MVP obejmuje:
- Uwierzytelnianie i profile użytkowników (Supabase Auth)
- Zarządzanie narzędziami (CRUD + zdjęcia w Supabase Storage)
- Wyszukiwanie po nazwie z obowiązkowym filtrem lokalizacji (PostGIS, stały promień 10 km)
- Prosty system rezerwacji i stanu transakcji (zapytanie → akceptacja z kwotą → potwierdzenie → odebrane → zwrócone)
- Wirtualną walutę Sąsiedzkie Żetony (saldo startowe, bonusy, transfery, ratunkowy +1/dzień)
- Wsparcie AI (OpenRouter) do generowania opisu narzędzia na podstawie nazwy

Technologie (plan):
- Frontend: Astro 5, React 19, TypeScript 5, Tailwind 4, shadcn/ui
- Backend: Supabase (Postgres + PostGIS, Auth, Storage)
- AI: OpenRouter.ai (tekst → propozycja opisu)
- Geokodowanie lokalizacji: serwis geokodujący (np. Nominatim OSM lub inny dostępny w środowisku) wykonywany w backendzie

Cel wdrożenia MVP: funkcjonalny produkt dla zamkniętej grupy 10–20 testerów w ciągu 6 tygodni.


## 2. Problem użytkownika

Problem: posiadanie narzędzi na własność jest kosztowne, nieefektywne i nieekologiczne, zwłaszcza gdy wykorzystuje się je sporadycznie. Brakuje ustrukturyzowanej, lokalnej i prostej w użyciu platformy do pożyczania narzędzi między sąsiadami.

Propozycja wartości:
- Łatwe wystawianie i znajdowanie narzędzi „blisko mnie” dzięki filtrowaniu po lokalizacji
- Jasny, prosty przepływ rezerwacji bez zbędnych formalności
- Brak płatności pieniężnych; prosta wirtualna waluta rozliczeniowa (Żetony)
- Minimum funkcji społecznościowych potrzebnych do zaufania (oceny w gwiazdkach), bez rozbudowanych czatów i komentarzy
- Wsparcie AI do szybszego wypełniania opisów narzędzi

Grupa docelowa MVP: mieszkańcy jednej miejscowości/dzielnicy (10–20 testerów), chcący pożyczać proste narzędzia w oparciu o lokalne zaufanie.


## 3. Wymagania funkcjonalne

3.1. Uwierzytelnianie i profil użytkownika
- Rejestracja przez e-mail/hasło (Supabase), z potwierdzeniem adresu e-mail
- Logowanie i bezpieczny dostęp do części aplikacji wymagających identyfikacji
- Wymuszone uzupełnienie profilu po rejestracji: nazwa użytkownika, lokalizacja (tekstowo), zgoda RODO na udostępnienie e-maila drugiej stronie transakcji
- Publiczny profil zawiera: nazwę użytkownika, średnią ocenę (1–5), listę aktualnie wystawionych narzędzi

3.2. Zarządzanie narzędziami (CRUD)
- Dodawanie: nazwa, opis, sugerowana cena (1–5 Żetonów/dzień), minimum jedno zdjęcie
- Zdjęcia: kompresja/skalowanie po stronie klienta przed uploadem do Supabase Storage
- Edycja i usuwanie własnych narzędzi; usunięcie zablokowane, jeśli istnieją aktywne rezerwacje
- Edycja nie wpływa na ustaloną już kwotę w istniejących rezerwacjach

3.3. Integracja AI (OpenRouter)
- Przycisk w formularzu: „Zaproponuj opis na podstawie nazwy”
- W przypadku błędu AI użytkownik otrzymuje dyskretny komunikat; proces dodawania narzędzia nie jest blokowany

3.4. Lokalizacja i wyszukiwanie (PostGIS)
- Wyszukiwanie tekstowe po nazwie, obowiązkowo filtrowane lokalizacją użytkownika
- Promień wyszukiwania: 10 km od współrzędnych wyliczonych z lokalizacji tekstowej profilu
- Geokodowanie lokalizacji wykonywane w backendzie; w razie błędu użytkownik proszony o korektę lokalizacji

3.5. Rezerwacje i przebieg transakcji
- Strona „Moje Rezerwacje” z zakładkami: „Pożyczam” i „Użyczam”
- Przebieg: zapytanie → akceptacja z ręcznie wpisaną kwotą → potwierdzenie przez pożyczającego → „Odebrałem narzędzie” (blokada żetonów) → „Narzędzie wróciło” (transfer żetonów)
- Anulowanie możliwe przez dowolną stronę aż do finalnego transferu żetonów; w razie blokady żetonów – odblokowanie przy anulowaniu
- Po obustronnym potwierdzeniu (po akceptacji kwoty) system ujawnia adresy e-mail obu stron

3.6. Wirtualna waluta – Sąsiedzkie Żetony
- Saldo startowe: 10 Żetonów po uzupełnieniu profilu
- Bonus: +2 Żetony za każde z pierwszych 3 wystawionych narzędzi użytkownika
- System ratunkowy: gdy saldo = 0, przycisk „+1 Żeton” raz dziennie (reset o północy CET)
- Transfer żetonów na koniec transakcji; rejestrowanie historii ruchów (ledger minimalny)

3.7. Zaufanie (oceny)
- Po zakończeniu transakcji obie strony wystawiają ocenę 1–5 gwiazdek (bez komentarzy)
- Średnia ocena widoczna publicznie na profilu i na stronie szczegółów narzędzia obok nazwy właściciela

3.8. Komunikacja minimalna
- Brak czatu
- Udostępnienie adresów e-mail obu stron po obustronnym potwierdzeniu warunków

3.9. Obsługa wyjątków i wsparcie
- Link „Zgłoś problem” (mailto:admin@maszpan.pl)
- Onboarding testerów przez e-mail, scenariusze i ankieta (po testach)


## 4. Granice produktu

4.1. W zakresie MVP
- Uwierzytelnianie i profile (Supabase Auth)
- CRUD narzędzi z jednym wymaganym zdjęciem (Supabase Storage)
- Wyszukiwanie po nazwie z filtrem geolokalnym (PostGIS, 10 km)
- Rezerwacje i rozliczenia w żetonach
- Minimalne wsparcie AI dla opisu narzędzia
- Oceny w gwiazdkach bez komentarzy

4.2. Poza zakresem MVP
- Płatności realnymi pieniędzmi i integracje bramek płatniczych
- Zaawansowany kalendarz dostępności; multi-dniowe planowanie szczegółowe
- Rozbudowane funkcje społecznościowe (komentarze, czat, fora)
- Zaawansowane funkcje AI (np. rekomendacje wg pogody, profilu)
- Systemy ubezpieczeń i formalnego rozwiązywania sporów
- Aplikacje mobilne natywne (tylko web)
- Panel administratora (monitoring i operacje bezpośrednio w bazie)

4.3. Założenia i ograniczenia
- Zaufanie lokalne i grupa 10–20 testerów (jedna miejscowość/dzielnica)
- Stały promień 10 km w MVP
- Wymagana weryfikacja e-mail i zgoda RODO na udostępnienie adresów e-mail stron transakcji
- Dzienny reset limitu ratunkowego o północy CET
- Geokoder dostępny i zgodny z polityką użycia (limity zapytań)
- Brak SLA i wsparcia 24/7; spory rozwiązywane manualnie

4.4. Wymagania niefunkcjonalne (MVP – minimum)
- Bezpieczeństwo dostępu do danych (autoryzacja działa poprawnie; każdy użytkownik edytuje tylko własne dane)
- Walidacja plików (rozsądne limity rozmiaru i wymiarów zdjęć)
- Czytelny interfejs web (desktop i mobile web w najnowszych przeglądarkach)
- Prosta telemetria operacyjna (zapytania do bazy na potrzeby KPI wykonywane manualnie przez zespół)


## 5. Historyjki użytkowników

US-001
Tytuł: Rejestracja konta e-mail
Opis: Jako nowy użytkownik chcę założyć konto przez e-mail/hasło, aby móc korzystać z aplikacji.
Kryteria akceptacji:
- Formularz przyjmuje e-mail i hasło; wysyłane jest potwierdzenie e-mail
- Bez potwierdzenia e-mail użytkownik nie ma dostępu do funkcji wymagających profilu

US-002
Tytuł: Logowanie
Opis: Jako użytkownik chcę zalogować się do aplikacji, aby zarządzać swoim kontem i narzędziami.
Kryteria akceptacji:
- Poprawne dane logują, błędne dane zwracają bezpieczny komunikat
- Sesja użytkownika utrzymywana zgodnie z polityką bezpieczeństwa

US-003
Tytuł: Wymuszone uzupełnienie profilu
Opis: Jako nowy użytkownik po rejestracji muszę uzupełnić nazwę, lokalizację i wyrazić zgodę RODO, aby korzystać z aplikacji.
Kryteria akceptacji:
- Brak możliwości pominęcia uzupełnienia
- Zapis nazwy użytkownika, lokalizacji (tekst), znacznik zgody RODO

US-004
Tytuł: Edycja profilu i lokalizacji
Opis: Jako użytkownik chcę zaktualizować nazwę i lokalizację, aby wyniki były aktualne.
Kryteria akceptacji:
- Zmiana lokalizacji inicjuje geokodowanie; w razie błędu komunikat z prośbą o korektę
- Zmiana nazwy odświeża widoki publiczne

US-005
Tytuł: Ochrona tras wymagających logowania
Opis: Jako system chcę blokować dostęp do stron wymagających logowania, aby chronić dane użytkowników.
Kryteria akceptacji:
- Niezalogowani są przekierowywani do logowania lub widzą ekran informacji
- Autoryzacja weryfikowana dla operacji na danych (tylko właściciel może edytować swoje zasoby)

US-006
Tytuł: Widok profilu publicznego
Opis: Jako użytkownik chcę zobaczyć publiczny profil innego użytkownika z oceną i listą narzędzi.
Kryteria akceptacji:
- Widoczne: nazwa, średnia ocena, lista aktywnych narzędzi
- Brak wrażliwych danych (e-mail ukryty do momentu warunków ujawnienia)

US-010
Tytuł: Dodanie narzędzia
Opis: Jako właściciel chcę dodać narzędzie z nazwą, opisem, sugerowaną ceną i zdjęciem.
Kryteria akceptacji:
- Wymagane minimum jedno zdjęcie; walidacja rozmiaru/formatu
- Zapis danych narzędzia w bazie i obrazu w Storage

US-011
Tytuł: Kompresja zdjęcia po stronie klienta
Opis: Jako użytkownik chcę, aby zdjęcie było automatycznie kompresowane przed wysłaniem, aby upload był szybki.
Kryteria akceptacji:
- Przed uploadem obraz jest skalowany/kompresowany do rozsądnych wymiarów/rozmiaru

US-012
Tytuł: Edycja narzędzia
Opis: Jako właściciel chcę edytować szczegóły mojego narzędzia.
Kryteria akceptacji:
- Edycja dostępna dla właściciela; zmiany nie wpływają na ceny już ustalonych rezerwacji

US-013
Tytuł: Usunięcie narzędzia z blokadą aktywnych rezerwacji
Opis: Jako właściciel chcę usunąć narzędzie, chyba że ma aktywne rezerwacje.
Kryteria akceptacji:
- Próba usunięcia przy aktywnych rezerwacjach zwraca jasny komunikat i blokuje operację

US-014
Tytuł: Lista moich narzędzi
Opis: Jako właściciel chcę widzieć listę swoich narzędzi i ich status rezerwacji.
Kryteria akceptacji:
- Widok zawiera podstawowe metadane i linki do edycji/usunięcia

US-020
Tytuł: Wyszukiwanie po nazwie z filtrem geolokalnym
Opis: Jako użytkownik chcę wyszukiwać narzędzia po nazwie w promieniu 10 km od mojej lokalizacji.
Kryteria akceptacji:
- Wyniki ograniczone do 10 km; użytkownik widzi informację o odległości
- Brak ustawionej lokalizacji wymusza uzupełnienie profilu

US-021
Tytuł: Geokodowanie lokalizacji profilu
Opis: Jako system chcę przeliczyć lokalizację tekstową użytkownika na współrzędne.
Kryteria akceptacji:
- Pomyślne geokodowanie zapisuje współrzędne; w razie niepowodzenia komunikat o korekcie

US-022
Tytuł: Puste wyniki wyszukiwania
Opis: Jako użytkownik chcę jasny komunikat, gdy w promieniu 10 km nie ma ofert.
Kryteria akceptacji:
- Wyświetlany jest komunikat i podpowiedź, by spróbować później lub dodać narzędzie

US-023
Tytuł: Sortowanie wyników po odległości
Opis: Jako użytkownik chcę widzieć bliższe narzędzia wyżej na liście.
Kryteria akceptacji:
- Wyniki domyślnie sortowane rosnąco po odległości

US-030
Tytuł: Strona szczegółów narzędzia
Opis: Jako użytkownik chcę zobaczyć szczegóły narzędzia i właściciela.
Kryteria akceptacji:
- Widoczne: nazwa, opis, zdjęcie, sugerowana cena, średnia ocena właściciela, przycisk zapytania o wypożyczenie

US-031
Tytuł: Zapytanie o wypożyczenie
Opis: Jako pożyczający chcę wysłać zapytanie do właściciela narzędzia.
Kryteria akceptacji:
- Po wysłaniu zapytanie widoczne w „Pożyczam”, u właściciela w „Użyczam”

US-032
Tytuł: Akceptacja z kwotą przez właściciela
Opis: Jako właściciel chcę zaakceptować zapytanie i wpisać finalną kwotę w Żetonach.
Kryteria akceptacji:
- Wpisanie liczby żetonów; zapis zmiany stanu; pożyczający widzi propozycję

US-033
Tytuł: Potwierdzenie kwoty przez pożyczającego
Opis: Jako pożyczający chcę potwierdzić lub odrzucić zaproponowaną kwotę.
Kryteria akceptacji:
- Potwierdzenie przechodzi do etapu ustaleń logistycznych; odrzucenie zamyka rezerwację

US-034
Tytuł: Ujawnienie e-maili po obustronnym potwierdzeniu
Opis: Jako system chcę ujawnić adresy e-mail obu stron po zaakceptowaniu kwoty przez obie strony.
Kryteria akceptacji:
- E-maile widoczne dla obu stron wyłącznie po tym kroku

US-035
Tytuł: Oznaczenie „Odebrałem narzędzie” i blokada żetonów
Opis: Jako pożyczający chcę oznaczyć odbiór narzędzia, aby zablokować żetony.
Kryteria akceptacji:
- Po kliknięciu żetony w wysokości uzgodnionej kwoty są blokowane na koncie pożyczającego

US-036
Tytuł: Oznaczenie „Narzędzie wróciło” i transfer żetonów
Opis: Jako właściciel chcę oznaczyć zwrot narzędzia, aby otrzymać żetony.
Kryteria akceptacji:
- Po kliknięciu następuje transfer zablokowanych żetonów do właściciela, rezerwacja zamknięta

US-037
Tytuł: Anulowanie rezerwacji przed transferem
Opis: Jako dowolna strona chcę móc anulować rezerwację do czasu finalnego transferu żetonów.
Kryteria akceptacji:
- Anulowanie odblokowuje ewentualnie zablokowane żetony i kończy rezerwację jako anulowaną

US-038
Tytuł: Widok „Moje Rezerwacje” z zakładkami
Opis: Jako użytkownik chcę mieć widok moich rezerwacji w dwóch zakładkach: „Pożyczam” i „Użyczam”.
Kryteria akceptacji:
- Widoczna lista rezerwacji z aktualnym stanem i dostępnymi akcjami

US-040
Tytuł: Saldo startowe żetonów
Opis: Jako użytkownik po uzupełnieniu profilu chcę otrzymać 10 Żetonów startowych.
Kryteria akceptacji:
- Jednorazowe naliczenie po pierwszym kompletnym profilu

US-041
Tytuł: Bonus za pierwsze wystawienia
Opis: Jako użytkownik chcę otrzymać +2 Żetony za każde z pierwszych trzech wystawionych narzędzi.
Kryteria akceptacji:
- Bonus nalicza się maksymalnie 3 razy, jeden raz na nowe narzędzie

US-042
Tytuł: System ratunkowy +1 Żeton dziennie
Opis: Jako użytkownik z saldem 0 chcę móc dodać +1 Żeton raz dziennie.
Kryteria akceptacji:
- Przycisk aktywny wyłącznie przy saldzie 0; limit resetuje się o północy CET

US-043
Tytuł: Transfer żetonów po zakończeniu
Opis: Jako system chcę przelać żetony właścicielowi po oznaczeniu zwrotu.
Kryteria akceptacji:
- Kwota zgodna z uzgodnioną; zapis transakcji w historii ruchów

US-050
Tytuł: Wystawienie oceny
Opis: Jako każda ze stron chcę wystawić rating 1–5 po zakończeniu transakcji.
Kryteria akceptacji:
- Jedna ocena per strona per transakcja; zapis i agregacja do średniej

US-051
Tytuł: Wyświetlanie średniej oceny
Opis: Jako użytkownik chcę widzieć średnią ocenę właściciela na profilu i stronie narzędzia.
Kryteria akceptacji:
- Średnia wyliczana z ostatnich ocen; zaokrąglenie i liczba ocen widoczne

US-060
Tytuł: Generowanie opisu narzędzia przez AI
Opis: Jako wystawiający chcę kliknąć „Zaproponuj opis” i uzyskać podpowiedź na podstawie nazwy.
Kryteria akceptacji:
- Po sukcesie treść trafia do pola opisu z możliwością ręcznej edycji przed zapisaniem

US-061
Tytuł: Odporność na błędy AI
Opis: Jako użytkownik chcę dodać narzędzie mimo błędu AI.
Kryteria akceptacji:
- W razie timeout/5xx wyświetla się dyskretny komunikat; formularz działa dalej

US-070
Tytuł: Ujawnienie e-maili po potwierdzeniu (komunikacja minimalna)
Opis: Jako użytkownik chcę otrzymać e-mail drugiej strony po obustronnym potwierdzeniu rezerwacji.
Kryteria akceptacji:
- E-maile stają się widoczne i kopiowalne; nie są ujawniane wcześniej

US-080
Tytuł: Zgłoszenie problemu
Opis: Jako użytkownik chcę szybko zgłosić problem do administratora.
Kryteria akceptacji:
- Widoczny link mailto:admin@maszpan.pl dostępny z głównych widoków

US-090
Tytuł: Autoryzacja operacji na zasobach
Opis: Jako system chcę gwarantować, że użytkownik może edytować/usuwać tylko własne narzędzia i zarządzać tylko własnymi rezerwacjami.
Kryteria akceptacji:
- Próba dostępu do cudzych zasobów jest blokowana i logowana; UI nie pokazuje nieuprawnionych akcji

US-091
Tytuł: Walidacja i bezpieczeństwo uploadu zdjęć
Opis: Jako system chcę ograniczyć formaty i rozmiary plików.
Kryteria akceptacji:
- Akceptowane jedynie bezpieczne formaty; limity rozmiaru/wymiarów; obsługa błędów z czytelnym komunikatem

US-092
Tytuł: Spójność stanów rezerwacji
Opis: Jako system chcę egzekwować poprawną kolejność stanów (zapytanie → akceptacja → potwierdzenie → odebrane → zwrócone) i zasady anulowania.
Kryteria akceptacji:
- Niemożliwe jest pominięcie kroku; przy anulowaniu stany i żetony wracają do poprawnych wartości


## 6. Metryki sukcesu

6.1. Kryteria MVP
- Wdrożenie: funkcjonalne MVP dla 10–20 testerów w 6 tygodni
- Podaż: każdy tester wystawił co najmniej 2–3 narzędzia
- Popyt: min. 5 zakończonych transakcji z transferem Żetonów w 2 tygodnie testów
- Jakość: zebrane opinie w ankiecie (łatwość użycia, zaufanie, blokery)

6.2. Dodatkowe wskaźniki operacyjne (mierzone prostymi zapytaniami do bazy)
- Czas do pierwszego wystawienia narzędzia po rejestracji (mediana)
- Odsetek użytkowników z uzupełnionym profilem (nazwa, lokalizacja, zgoda RODO)
- Skuteczność wyszukiwań (odsetek wyszukiwań zwracających ≥1 wynik)
- Współczynnik konwersji: szczegóły narzędzia → wysłanie zapytania → akceptacja → finalizacja
- Średnia ocena użytkowników i rozkład ocen po transakcjach

6.3. Definicja ukończenia MVP
- Wszystkie historyjki z sekcji 5 są testowalne i przechodzą testy akceptacyjne
- Aplikacja działa stabilnie w grupie testerów, a zespół potwierdził spełnienie KPI z 6.1

## 7. Rekomendacje wdrożeniowe

### 7.1. Minimalne uproszczenia bez zmiany stosu
- Uwierzytelnianie: na start użyć `@supabase/auth-ui` dla ekranów logowania/rejestracji zamiast budować je od zera. Pozwala szybciej dostarczyć MVP; w późniejszym etapie można zastąpić własnymi widokami.
- Logika stanów i Żetonów w bazie: przejścia stanów rezerwacji oraz ledger Żetonów realizować w Postgresie (funkcje/wyzwalacze, check constraints, transakcje) z RLS, zamiast przenosić tę logikę do osobnego backendu. Zwiększa spójność danych i upraszcza warstwę serwerową.
- Obrazy: kompresja/skalowanie po stronie klienta (np. `browser-image-compression`), upload przez podpisane URL-e Supabase Storage; po stronie Storage egzekwować `content-type` i limity rozmiaru.

### 7.2. Bezpieczeństwo – zalecenia
- RLS: włączone i przetestowane dla wszystkich tabel użytkownika, narzędzi, rezerwacji i ledgeru. Testy polityk obejmują scenariusze dostępu do cudzych zasobów.
- Egzekwowanie stanów w DB: wszystkie przejścia stanów wykonywane poprzez funkcje transakcyjne w DB; brak możliwości „przeskoczenia” stanu przez bezpośrednie wywołanie API.
- Ujawnienie e-maili: adresy e-mail stron udostępniane dopiero po obustronnym potwierdzeniu, egzekwowane po stronie DB (widok/funkcja zwracająca pola warunkowo).
- Storage: wyłącznie podpisane URL-e do odczytu/zapisu, walidacja `content-type` i limitów rozmiaru; na kliencie kompresja i sanityzacja metadanych. (Opcjonalnie: skan antywirusowy/heurystyczny po stronie backendu w późniejszym etapie.)
- Geokodowanie: wykonywane w backendzie (np. Supabase Edge Function) z rate limitingiem, timeoutami i cache; przechowywać jedynie współrzędne i tekst lokalizacji, bez surowych odpowiedzi serwisu geokodującego.
- Audyt i telemetria: logowanie prób niedozwolonych przejść stanów i błędów RLS; proste zapytania/raporty operacyjne na potrzeby KPI z rozdz. 6.


