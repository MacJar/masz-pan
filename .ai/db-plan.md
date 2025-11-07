 1. Lista tabel z kolumnami, typami danych i ograniczeniami

 - Rozszerzenia (wymagane):
   - postgis (geography)
   - pgcrypto (gen_random_uuid)
   - citext
   - pg_trgm (opcjonalnie do fuzzy search)

 - Typy ENUM:
   - reservation_status: 'requested', 'owner_accepted', 'borrower_confirmed', 'picked_up', 'returned', 'cancelled', 'rejected'
   - tool_status: 'draft', 'inactive', 'active', 'archived'
   - ledger_kind: 'debit', 'credit', 'hold', 'release', 'transfer', 'award'
   - award_kind: 'signup_bonus', 'listing_bonus'

 - Tabela: profiles
   - id uuid PK, FK -> auth.users.id, NOT NULL
   - username citext UNIQUE, NOT NULL
   - location_text text
   - location_geog geography(Point, 4326)
   - rodo_consent boolean DEFAULT false, NOT NULL
   - created_at timestamptz DEFAULT now(), NOT NULL
   - updated_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - CHECK (username <> '')
     - Indeks GIST na location_geog

 - Tabela: tools
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - owner_id uuid FK -> profiles.id, NOT NULL
   - name text NOT NULL
   - description text
   - suggested_price_tokens smallint NOT NULL CHECK (suggested_price_tokens BETWEEN 1 AND 5)
   - status tool_status NOT NULL DEFAULT 'draft'
   - search_name_tsv tsvector (utrzymywane triggerem)
   - created_at timestamptz DEFAULT now(), NOT NULL
   - updated_at timestamptz DEFAULT now(), NOT NULL
   - archived_at timestamptz NULL
   - Ograniczenia/uwagi:
     - Indeks GIN na search_name_tsv
     - Indeks na (owner_id, status)

 - Tabela: tool_images
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - tool_id uuid FK -> tools.id ON DELETE CASCADE, NOT NULL
   - storage_key text NOT NULL -- klucz w Supabase Storage
   - position smallint NOT NULL DEFAULT 0
   - created_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - UNIQUE(tool_id, position)

 - Tabela: reservations
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - tool_id uuid FK -> tools.id, NOT NULL
   - owner_id uuid FK -> profiles.id, NOT NULL
   - borrower_id uuid FK -> profiles.id, NOT NULL
   - status reservation_status NOT NULL DEFAULT 'requested'
   - agreed_price_tokens smallint CHECK (agreed_price_tokens BETWEEN 1 AND 255)
   - cancelled_reason text
   - created_at timestamptz DEFAULT now(), NOT NULL
   - updated_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - CHECK (owner_id <> borrower_id)
     - TRIGGER zapewniający zgodność owner_id = tools.owner_id przy INSERT/UPDATE
     - Częściowy UNIQUE(tool_id) WHERE status IN ('requested','owner_accepted','borrower_confirmed','picked_up')

 - Tabela: token_ledger (INSERT-only, podwójne księgowanie)
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - user_id uuid FK -> profiles.id, NOT NULL
   - reservation_id uuid FK -> reservations.id NULL
   - kind ledger_kind NOT NULL
   - amount integer NOT NULL -- dodatnie dla credit/award/release, ujemne dla debit/hold/transfer-out
   - details jsonb DEFAULT '{}'::jsonb NOT NULL
   - created_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - CHECK (amount <> 0)
     - Częściowy UNIQUE(user_id, reservation_id) WHERE kind = 'hold'
     - TRIGGER blokujący UPDATE/DELETE (insert-only)

 - Widok: balances (agregaty sald żetonów)
   - Kolumny: user_id uuid, total integer, held integer, available integer
   - Definicja: 
     - total = SUM(amount)
     - held = SUM(amount WHERE kind='hold') - SUM(amount WHERE kind IN ('release','transfer') AND details->>'for_hold' IS NOT NULL)
     - available = total - max(held, 0)

 - Tabela: award_events
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - user_id uuid FK -> profiles.id, NOT NULL
   - kind award_kind NOT NULL
   - tool_id uuid FK -> tools.id NULL -- dla listing_bonus
   - created_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - UNIQUE(user_id) WHERE kind = 'signup_bonus'
     - UNIQUE(user_id, tool_id) WHERE kind = 'listing_bonus'
     - Dodatkowo egzekwować limit pierwszych 3 listing_bonus logicznie w funkcji

 - Tabela: rescue_claims
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - user_id uuid FK -> profiles.id, NOT NULL
   - claim_date_cet date NOT NULL -- data w strefie CET (wyliczana w DB)
   - created_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - UNIQUE(user_id, claim_date_cet)

 - Tabela: ratings
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - reservation_id uuid FK -> reservations.id, NOT NULL
   - rater_id uuid FK -> profiles.id, NOT NULL
   - rated_user_id uuid FK -> profiles.id, NOT NULL
   - stars smallint NOT NULL CHECK (stars BETWEEN 1 AND 5)
   - created_at timestamptz DEFAULT now(), NOT NULL
   - Ograniczenia/uwagi:
     - UNIQUE(reservation_id, rater_id)
     - TRIGGER: pozwól INSERT wyłącznie, gdy reservations.status = 'returned'

 - Materialized View: rating_stats (opcjonalne, do agregacji ocen)
   - Kolumny: rated_user_id uuid, avg_stars numeric(3,2), ratings_count integer, refreshed_at timestamptz

 - Tabela: audit_log
   - id uuid PK DEFAULT gen_random_uuid(), NOT NULL
   - event_type text NOT NULL -- np. 'contact_reveal', 'state_transition', 'security'
   - actor_id uuid FK -> profiles.id NULL
   - reservation_id uuid FK -> reservations.id NULL
   - details jsonb NOT NULL DEFAULT '{}'::jsonb
   - created_at timestamptz DEFAULT now(), NOT NULL

 - Widok: public_profiles (ograniczone pola publiczne)
   - Kolumny: id, username, location_text (opcjonalnie), avg_rating, ratings_count

 - Funkcje (interfejsy, SECURITY DEFINER):
   - publish_tool(tool_id uuid) RETURNS void
     - Weryfikuje co najmniej jedno zdjęcie, zgodność właściciela, ustawia status = 'active'
   - get_counterparty_contact(reservation_id uuid) RETURNS TABLE(owner_email text, borrower_email text)
     - Zwraca e-maile wyłącznie po obustronnym potwierdzeniu (status >= 'borrower_confirmed'); loguje w audit_log
   - reservation_transition(reservation_id uuid, new_status reservation_status, price_tokens smallint DEFAULT NULL) RETURNS void
     - Egzekwuje maszynę stanów i spójność, zakłada/zwalnia blokady hold oraz transfer
   - award_signup_bonus(user_id uuid) RETURNS void
   - award_listing_bonus(user_id uuid, tool_id uuid) RETURNS void
   - claim_rescue_token(user_id uuid) RETURNS void -- 1/dzień przy available=0


 2. Relacje między tabelami

 - auth.users 1 — 1 profiles (FK profiles.id -> auth.users.id)
 - profiles 1 — N tools (tools.owner_id)
 - tools 1 — N tool_images (tool_images.tool_id)
 - tools 1 — N reservations (reservations.tool_id)
 - profiles 1 — N reservations jako owner (reservations.owner_id)
 - profiles 1 — N reservations jako borrower (reservations.borrower_id)
 - reservations 1 — N ratings (ratings.reservation_id)
 - profiles 1 — N ratings jako rater (ratings.rater_id)
 - profiles 1 — N ratings jako rated (ratings.rated_user_id)
 - profiles 1 — N token_ledger (token_ledger.user_id)
 - reservations 1 — N token_ledger (token_ledger.reservation_id, opcjonalnie)
 - profiles 1 — N award_events (award_events.user_id)
 - profiles 1 — N rescue_claims (rescue_claims.user_id)
 - reservations N — 1 audit_log (opcjonalnie), profiles N — 1 audit_log (opcjonalnie)

 Kardynalności:
 - profiles:tools = 1:N
 - tools:tool_images = 1:N
 - tools:reservations = 1:N
 - reservations:ratings = 1:N (maks. 2 wpisy per rezerwacja — po jednym od każdej strony)
 - profiles:token_ledger = 1:N (INSERT-only)


 3. Indeksy

 - profiles
   - GIST (location_geog)
   - UNIQUE (username)
   - PK (id)

 - tools
   - PK (id)
   - INDEX (owner_id, status)
   - GIN (search_name_tsv)
   - (opcjonalnie) GIN/GIN_trgm na name dla TRGM

 - tool_images
   - PK (id)
   - INDEX (tool_id)
   - UNIQUE (tool_id, position)

 - reservations
   - PK (id)
   - INDEX (tool_id)
   - INDEX (owner_id)
   - INDEX (borrower_id)
   - INDEX (status)
   - Częściowy UNIQUE (tool_id) WHERE status IN ('requested','owner_accepted','borrower_confirmed','picked_up')

 - token_ledger
   - PK (id)
   - INDEX (user_id)
   - INDEX (reservation_id)
   - INDEX (kind, created_at)
   - Częściowy UNIQUE (user_id, reservation_id) WHERE kind = 'hold'
   - (skalowanie) Partycjonowanie po created_at (miesięczne) przy >1M wpisów/mies.

 - award_events
   - PK (id)
   - INDEX (user_id, kind)
   - Częściowe UNIQUE jak w ograniczeniach

 - rescue_claims
   - PK (id)
   - UNIQUE (user_id, claim_date_cet)

 - ratings
   - PK (id)
   - UNIQUE (reservation_id, rater_id)
   - INDEX (rated_user_id)

 - audit_log
   - PK (id)
   - INDEX (created_at)
   - INDEX (event_type)
   - INDEX (reservation_id)
   - INDEX (actor_id)


 4. Zasady PostgreSQL (RLS)

 - Globalnie: RLS włączone dla wszystkich tabel użytkownika (profiles, tools, tool_images, reservations, token_ledger, award_events, rescue_claims, ratings, audit_log). Domyślnie DENY ALL.

 - profiles
   - ENABLE RLS
   - SELECT: własny wiersz: USING (id = auth.uid())
   - INSERT/UPDATE: WITH CHECK (id = auth.uid())
   - Publiczne odczyty ograniczonych pól przez widok public_profiles (bez RLS na widoku)

 - tools
   - ENABLE RLS
   - SELECT: każdy może czytać wyłącznie aktywne/niearchiwalne: USING (status IN ('active')) OR (owner_id = auth.uid())
   - INSERT: WITH CHECK (owner_id = auth.uid())
   - UPDATE/DELETE: USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid())

 - tool_images
   - ENABLE RLS
   - SELECT: USING (EXISTS(SELECT 1 FROM tools t WHERE t.id = tool_id AND (t.status IN ('active') OR t.owner_id = auth.uid())))
   - INSERT/UPDATE/DELETE: USING (EXISTS(SELECT 1 FROM tools t WHERE t.id = tool_id AND t.owner_id = auth.uid())) WITH CHECK (EXISTS(SELECT 1 FROM tools t WHERE t.id = tool_id AND t.owner_id = auth.uid()))

 - reservations
   - ENABLE RLS
   - SELECT: USING (owner_id = auth.uid() OR borrower_id = auth.uid())
   - INSERT: WITH CHECK (borrower_id = auth.uid())
   - UPDATE: USING (owner_id = auth.uid() OR borrower_id = auth.uid()) WITH CHECK (owner_id = OLD.owner_id AND borrower_id = OLD.borrower_id)
   - UWAGA: Zmiany stanów wyłącznie poprzez reservation_transition() (SECURITY DEFINER); bezpośrednie UPDATE status zabronione triggerem

 - token_ledger
   - ENABLE RLS
   - SELECT: USING (user_id = auth.uid())
   - INSERT: wyłącznie przez funkcje SECURITY DEFINER (reservation_transition, award_*, claim_rescue_token)
   - UPDATE/DELETE: całkowicie zabronione (trigger podnoszący wyjątek)

 - award_events
   - ENABLE RLS
   - SELECT: USING (user_id = auth.uid())
   - INSERT: tylko przez funkcje award_* (SECURITY DEFINER)

 - rescue_claims
   - ENABLE RLS
   - SELECT: USING (user_id = auth.uid())
   - INSERT: tylko przez funkcję claim_rescue_token (SECURITY DEFINER)

 - ratings
   - ENABLE RLS
   - SELECT: USING (rater_id = auth.uid() OR rated_user_id = auth.uid())
   - INSERT: WITH CHECK (rater_id = auth.uid())
   - UPDATE/DELETE: niedozwolone (trigger)

 - audit_log
   - ENABLE RLS
   - SELECT: USING (actor_id = auth.uid()) -- lub ograniczyć do administratorów; rozważ odczyt tylko serwisowy
   - INSERT: dozwolone funkcjom SECURITY DEFINER (np. get_counterparty_contact, reservation_transition)

 - Widoki/funkcje SECURITY DEFINER
   - get_counterparty_contact: sprawdza status rezerwacji (>= borrower_confirmed), RODO, oraz, że wywołujący jest stroną transakcji; loguje zdarzenie do audit_log
   - public_profiles: zapewnia publiczny wgląd w ograniczony zestaw pól i statystyki ocen (JOIN do rating_stats)


 5. Dodatkowe uwagi i wyjaśnienia

 - Maszyna stanów rezerwacji (ograniczenia sekwencji):
   - requested -> owner_accepted (ustawia agreed_price_tokens)
   - owner_accepted -> borrower_confirmed (akceptacja/odrzucenie; odrzucenie = rejected)
   - borrower_confirmed -> picked_up (po stronie borrower: zakłada hold w token_ledger; weryfikuj available >= agreed_price_tokens)
   - picked_up -> returned (po stronie owner: transfer zablokowanych żetonów do ownera; hold zwalniany odpowiednimi wpisami ledger)
   - Anulowanie: dozwolone przed 'returned'; przy anulowaniu zwalniaj wszelkie hold

 - FTS: search_name_tsv utrzymywane triggerem z to_tsvector('polish', coalesce(name,'')); fallback na 'simple' jeśli 'polish' niedostępny.

 - Geolokalizacja: profiles.location_geog z GIST; zapytania ST_DWithin(location_geog, user_point, 10000) i sortowanie ST_Distance.

 - publish_tool(tool_id): egzekwuje co najmniej jedno zdjęcie i sensowny status; zmiana statusu narzędzia poza tą funkcją powinna być zablokowana triggerem.

 - Spójność właściciela: trigger na reservations potwierdza owner_id = (SELECT owner_id FROM tools WHERE id = tool_id).

 - Token ledger: podwójne księgowanie oznacza, że transfer pomiędzy użytkownikami zapisujemy jako dwa wpisy (debit u pożyczającego, credit u właściciela) w tej samej transakcji; hold/release/transfer powiązane reservation_id i details (np. {"for_hold": "<uuid>"}).

 - Bonusy: award_signup_bonus (jednorazowo po kompletnym profilu), award_listing_bonus (pierwsze 3 narzędzia; unikalność per tool_id). Wpisy w award_events są źródłem prawdy; odpowiednie wpisy w token_ledger typu 'award'.

 - Rescue +1/dzień: claim_rescue_token wymusza available=0 i unikalność (user_id, claim_date_cet). Data CET wyliczana w DB (np. (now() AT TIME ZONE 'CET')::date).

 - Audyt: get_counterparty_contact loguje każdy odczyt danych kontaktowych (z identyfikatorem użytkownika i rezerwacji) do audit_log.

 - Archiwizacja: narzędzia nie są fizycznie kasowane; status 'archived' + archived_at; tool_images ON DELETE CASCADE; reservations i ledger bez DELETE (insert-only) egzekwowane triggerami.

 - Konkurencja/wyścigi: krytyczne funkcje (reservation_transition, claim_rescue_token) powinny używać pg_advisory_xact_lock na reservation_id / user_id oraz działać w transakcjach SERIALIZABLE.

 - Skalowanie: w razie wzrostu ruchu partycjonować token_ledger po created_at (np. miesięcznie); rating_stats jako MV odświeżane cyklicznie lub po zdarzeniach.

 - Zgodność z RODO: rozważyć osobną ścieżkę anonimizacji profilu (maskowanie username lub pseudonimizacja) z zachowaniem spójności referencji (np. przez flagę i zamianę pól tekstowych w widokach publicznych).

