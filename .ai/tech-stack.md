# Stos technologiczny – MaszPan (MVP)

## Frontend – Astro z React dla komponentów interaktywnych
- Astro 5: szybkie SSR/SSG i minimalny JS w przeglądarce; wyspy interaktywności tylko tam, gdzie potrzebne.
- React 19: używany oszczędnie do formularzy, wyszukiwania i widoku rezerwacji; reszta w czystym Astro.
- TypeScript 5: spójne typowanie, lepsze DX i mniejsza liczba błędów w runtime.
- Tailwind 4: szybkie stylowanie, predefiniowany design system i utility-first.
- shadcn/ui: zestaw dostępnych komponentów React – instalujemy wyłącznie potrzebne komponenty, dopasowane do Tailwind 4.
- Kompresja obrazów na kliencie: np. `browser-image-compression` przed uploadem do Storage (zgodnie z PRD 3.2, 3.3, 3.9).

## Backend – Supabase jako kompleksowe BaaS
- PostgreSQL + PostGIS: zapytania przestrzenne (promień 10 km) z indeksami GIST i `ST_DWithin` (PRD 3.4, 4.1).
- Auth: Supabase Auth z weryfikacją e-mail; startowo UI przez `@supabase/auth-ui` dla szybkiego MVP.
- Storage: przechowywanie zdjęć; tylko podpisane URL-e; egzekwowane `content-type` i limity rozmiaru.
- RLS: polityki dla użytkowników, narzędzi, rezerwacji i ledgeru; testy polityk w krytycznych scenariuszach.
- Logika domenowa w DB: przejścia stanów rezerwacji i operacje na Żetonach w funkcjach transakcyjnych + constraints (zapobiega "przeskakiwaniu" stanów; PRD 3.5, 3.6, 4.4, 5/US-092).
- Edge Functions: backendowe geokodowanie z rate-limit, timeout i cache; zapisujemy współrzędne + lokalizację tekstową (PRD 3.4, 4.3).
- Audyt i telemetria: logowanie prób niedozwolonych akcji i błędów RLS; proste raporty operacyjne dla KPI (PRD 6).

## AI – OpenRouter.ai
- Dostęp do wielu modeli (OpenAI, Anthropic, Google, itd.), możliwość wyboru pod jakość/koszt.
- Limity budżetu i rate-limity na kluczach API; wywołania z timeoutem i czytelną obsługą błędów.
- Funkcja „Zaproponuj opis” nie blokuje zapisu formularza w razie błędu (PRD 3.3, 5/US-061).

## CI/CD i Hosting
- CI: GitHub Actions – lint, build, testy i predeploy.
- Hosting frontendu: Vercel (Astro SSR/edge) lub Netlify – szybkie preview i rollout.
- Backend: Supabase zarządza DB/Auth/Storage/Edge Functions; brak konieczności własnej orkiestracji.
- Alternatywnie (opcjonalnie): DigitalOcean z Dockerem, gdy wymagany pełny kontrolowany runtime.

## Bezpieczeństwo i zgodność (konsekwencje PRD)
- RLS wszędzie: twarde ograniczenie dostępu do cudzych zasobów; testy polityk.
- Maszyna stanów w DB: przejścia tylko przez funkcje transakcyjne; API nie pozwala pominąć kroków.
- Ujawnienie e-maili dopiero po obustronnym potwierdzeniu – egzekwowane po stronie DB/widoków.
- Storage: podpisane URL-e, walidacja `content-type` i rozmiaru; kompresja/skalowanie na kliencie.
- Geokodowanie w backendzie: rate-limit, timeout, cache; przechowujemy tylko współrzędne i tekst lokalizacji.
- Telemetria operacyjna: rejestrowanie nieudanych prób przejść stanów i błędów RLS; proste zapytania KPI.

## Zasady implementacyjne (dla szybkiego MVP)
- Uwierzytelnianie: `@supabase/auth-ui` na start; migracja do custom UI w miarę potrzeb.
- React tylko tam, gdzie potrzebna interakcja; preferuj komponenty Astro dla sekcji statycznych/SSR.
- Indeksy przestrzenne i prefiltr BBOX dla zapytań w promieniu 10 km; sortowanie po odległości.
- Operacje na Żetonach i blokadach w tej samej transakcji co zmiana stanu rezerwacji.

