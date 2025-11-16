-- -----------------------------------------------------------------------------
-- Rozszerzenia
-- -----------------------------------------------------------------------------
create extension if not exists postgis with schema public;
create extension if not exists pgcrypto with schema public;
create extension if not exists citext with schema public;
create extension if not exists pg_trgm with schema public;

-- -----------------------------------------------------------------------------
-- Zasobniki (Storage Buckets)
-- -----------------------------------------------------------------------------
-- Zasobnik tool_images (publicznie dostępny)
insert into storage.buckets (id, name, public)
values ('tool_images', 'tool_images', true)
on conflict (id) do nothing;

-- TODO: Ogranicz tę politykę, gdy zaimplementowane zostanie uwierzytelnianie.
-- Na razie zezwól wszystkim publicznym użytkownikom na przesyłanie do zasobnika tool_images
-- aby ułatwić rozwój bez pełnego przepływu uwierzytelniania.
create policy "Allow public uploads to tool_images"
on storage.objects for insert to public with check (
  bucket_id = 'tool_images'
);

-- -----------------------------------------------------------------------------
-- Typy wyliczeniowe (ENUM)
-- -----------------------------------------------------------------------------
do $$ begin
  if not exists (select 1 from pg_type where typname = 'reservation_status') then
    create type reservation_status as enum (
      'requested',
      'owner_accepted',
      'borrower_confirmed',
      'picked_up',
      'returned',
      'cancelled',
      'rejected'
    );
  end if;
  if not exists (select 1 from pg_type where typname = 'tool_status') then
    create type tool_status as enum (
      'draft',
      'inactive',
      'active',
      'archived'
    );
  end if;
  if not exists (select 1 from pg_type where typname = 'ledger_kind') then
    create type ledger_kind as enum (
      'debit',
      'credit',
      'hold',
      'release',
      'transfer',
      'award'
    );
  end if;
  if not exists (select 1 from pg_type where typname = 'award_kind') then
    create type award_kind as enum (
      'signup_bonus',
      'listing_bonus'
    );
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Funkcje pomocnicze (współdzielone)
-- -----------------------------------------------------------------------------
-- Zapewnia ustawienie updated_at na now() przy aktualizacji wiersza
create or replace function public.set_current_timestamp_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Pomocnik FTS: użyj 'polish', jeśli dostępne, w przeciwnym razie 'simple'
create or replace function public.fts_polish_or_simple(input text)
returns tsvector
language plpgsql
stable
as $$
declare
  cfg regconfig;
begin
  if exists (select 1 from pg_ts_config where cfgname = 'polish') then
    cfg := 'polish'::regconfig;
  else
    cfg := 'simple'::regconfig;
  end if;
  return to_tsvector(cfg, coalesce(input, ''));
end;
$$;

-- Zabezpieczenie pozwalające na kontrolowane aktualizacje statusu tylko przez reservation_transition
create or replace function public.raise_if_reservation_status_changed()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'update' and new.status is distinct from old.status then
    if current_setting('app.allow_reservation_status_update', true) is distinct from 'true' then
      raise exception 'direct updates to reservations.status are not allowed; use reservation_transition()';
    end if;
  end if;
  return new;
end;
$$;

-- Blokuje wszelkie aktualizacje/usunięcia w tabelach tylko do wstawiania
create or replace function public.block_update_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'updates/deletes are not permitted on this table (insert-only)';
end;
$$;

-- Zapewnia zgodność reservations.owner_id z tools.owner_id
create or replace function public.ensure_reservation_owner_consistency()
returns trigger
language plpgsql
as $$
declare
  tool_owner uuid;
begin
  select t.owner_id into tool_owner from public.tools t where t.id = new.tool_id;
  if tool_owner is null then
    raise exception 'tool % not found', new.tool_id;
  end if;
  if new.owner_id is distinct from tool_owner then
    raise exception 'reservation owner_id must match tools.owner_id';
  end if;
  return new;
end;
$$;

-- Zabezpieczenie niezmienności stron rezerwacji (owner_id i borrower_id)
create or replace function public.guard_reservations_parties_immutable()
returns trigger
language plpgsql
as $$
begin
  if new.owner_id is distinct from old.owner_id then
    raise exception 'owner_id cannot be changed';
  end if;
  if new.borrower_id is distinct from old.borrower_id then
    raise exception 'borrower_id cannot be changed';
  end if;
  return new;
end;
$$;

-- Utrzymuje tools.search_name_tsv
create or replace function public.tools_search_tsv_trigger()
returns trigger
language plpgsql
as $$
begin
  new.search_name_tsv := public.fts_polish_or_simple(new.name);
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Tabele
-- -----------------------------------------------------------------------------

-- profiles: 1-1 z auth.users
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext not null unique check (username <> ''),
  location_text text,
  location_geog public.geography(point, 4326),
  rodo_consent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  is_complete boolean default false -- Dodane z migracji 20251114170000
);

-- tools: narzędzia wystawione przez profile
create table if not exists public.tools (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  description text,
  suggested_price_tokens smallint not null check (suggested_price_tokens between 1 and 5),
  status tool_status not null default 'draft',
  search_name_tsv tsvector,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz null
);

-- tool_images: zdjęcia narzędzi, przechowywane w supabase storage; pozycja unikalna dla narzędzia
create table if not exists public.tool_images (
  id uuid primary key default gen_random_uuid(),
  tool_id uuid not null references public.tools(id) on delete cascade,
  storage_key text not null,
  position smallint not null default 0,
  created_at timestamptz not null default now(),
  unique (tool_id, position)
);

-- reservations: maszyna stanów cyklu życia wypożyczenia
create table if not exists public.reservations (
  id uuid primary key default gen_random_uuid(),
  tool_id uuid not null references public.tools(id) on delete restrict,
  owner_id uuid not null references public.profiles(id) on delete restrict,
  borrower_id uuid not null references public.profiles(id) on delete restrict,
  status reservation_status not null default 'requested',
  agreed_price_tokens smallint check (agreed_price_tokens between 1 and 255),
  cancelled_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (owner_id <> borrower_id)
);

-- token_ledger: księga tokenów (tylko do wstawiania)
create table if not exists public.token_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  reservation_id uuid null references public.reservations(id) on delete restrict,
  kind ledger_kind not null,
  amount integer not null check (amount <> 0),
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- award_events: źródło prawdy o bonusach
create table if not exists public.award_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  kind award_kind not null,
  tool_id uuid null references public.tools(id) on delete restrict,
  amount int, -- Dodane z migracji 20251114140000 (award_signup_bonus)
  created_at timestamptz not null default now(),
  constraint award_signup_unique unique (user_id) deferrable initially immediate
    -- unikalność dla signup_bonus wymuszona przez częściowy indeks unikalny poniżej
);

-- rescue_claims: +1 token dziennie, gdy dostępne saldo wynosi zero
create table if not exists public.rescue_claims (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  claim_date_cet date not null,
  created_at timestamptz not null default now(),
  unique (user_id, claim_date_cet)
);

-- ratings: opinie po transakcji
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null references public.reservations(id) on delete restrict,
  rater_id uuid not null references public.profiles(id) on delete restrict,
  rated_user_id uuid not null references public.profiles(id) on delete restrict,
  stars smallint not null check (stars between 1 and 5),
  created_at timestamptz not null default now(),
  unique (reservation_id, rater_id)
);

-- audit_log: log audytowy (tylko do dopisywania)
create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  user_id uuid null references public.profiles(id) on delete set null, -- Zmieniono z actor_id na user_id
  reservation_id uuid null references public.reservations(id) on delete set null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Indeksy
-- -----------------------------------------------------------------------------
-- profiles
create index if not exists idx_profiles_location_geog on public.profiles using gist (location_geog);

-- tools
create index if not exists idx_tools_owner_status on public.tools (owner_id, status);
create index if not exists idx_tools_search_tsv on public.tools using gin (search_name_tsv);

-- tool_images
create index if not exists idx_tool_images_tool on public.tool_images (tool_id);

-- reservations
create index if not exists idx_reservations_tool on public.reservations (tool_id);
create index if not exists idx_reservations_owner on public.reservations (owner_id);
create index if not exists idx_reservations_borrower on public.reservations (borrower_id);
create index if not exists idx_reservations_status on public.reservations (status);
create unique index if not exists uq_reservations_active_tool on public.reservations (tool_id)
  where status in ('requested','owner_accepted','borrower_confirmed','picked_up');
-- Nowe indeksy z 20251114120000
create index if not exists idx_reservations_owner_created_at_id on public.reservations (owner_id, created_at DESC, id DESC);
create index if not exists idx_reservations_borrower_created_at_id on public.reservations (borrower_id, created_at DESC, id DESC);


-- token_ledger
create index if not exists idx_token_ledger_user on public.token_ledger (user_id);
create index if not exists idx_token_ledger_reservation on public.token_ledger (reservation_id);
create index if not exists idx_token_ledger_kind_created on public.token_ledger (kind, created_at);
create unique index if not exists uq_token_ledger_hold_once on public.token_ledger (user_id, reservation_id)
  where kind = 'hold';
-- Nowy indeks z 20251114130000
create index if not exists idx_token_ledger_user_kind_created_at_id on public.token_ledger (user_id, kind, created_at DESC, id DESC);

-- award_events
create index if not exists idx_award_events_user_kind on public.award_events (user_id, kind);
create unique index if not exists uq_award_signup on public.award_events (user_id) where kind = 'signup_bonus';
create unique index if not exists uq_award_listing on public.award_events (user_id, tool_id) where kind = 'listing_bonus';

-- ratings
create index if not exists idx_ratings_rated_user on public.ratings (rated_user_id);

-- audit_log
create index if not exists idx_audit_log_created_at on public.audit_log (created_at);
create index if not exists idx_audit_log_event_type on public.audit_log (event_type);
create index if not exists idx_audit_log_reservation on public.audit_log (reservation_id);
create index if not exists idx_audit_log_user on public.audit_log (user_id); -- Zmieniono z idx_audit_log_actor

-- -----------------------------------------------------------------------------
-- Widoki i widoki zmaterializowane
-- -----------------------------------------------------------------------------
-- balances: zagregowane salda tokenów na użytkownika
create or replace view public.balances as
with base as (
  select user_id,
         sum(amount) as total
  from public.token_ledger
  group by user_id
),
holds as (
  select user_id,
         coalesce(sum(case when kind = 'hold' then amount else 0 end), 0) as sum_holds,
         coalesce(sum(case when kind in ('release','transfer') and (details ? 'for_hold') then amount else 0 end), 0) as sum_offsets
  from public.token_ledger
  group by user_id
)
select p.id as user_id,
       coalesce(b.total, 0) as total,
       greatest(coalesce(h.sum_holds, 0) - coalesce(h.sum_offsets, 0), 0) as held,
       coalesce(b.total, 0) - greatest(coalesce(h.sum_holds, 0) - coalesce(h.sum_offsets, 0), 0) as available
from public.profiles p
left join base b on b.user_id = p.id
left join holds h on h.user_id = p.id;

-- Widok zmaterializowany: rating_stats
drop materialized view if exists public.rating_stats;
create materialized view public.rating_stats as
select
  rated_user_id,
  round(avg(stars)::numeric, 2) as avg_stars,
  count(*)::integer as ratings_count,
  now() as refreshed_at
from public.ratings
group by rated_user_id;
create index if not exists idx_rating_stats_user on public.rating_stats (rated_user_id);

-- public_profiles: ograniczone pola publiczne + statystyki ocen
create or replace view public.public_profiles as
select
  p.id,
  p.username,
  p.location_text,
  rs.avg_stars,
  rs.ratings_count
from public.profiles p
left join public.rating_stats rs on rs.rated_user_id = p.id;

-- -----------------------------------------------------------------------------
-- Wyzwalacze (Triggers)
-- -----------------------------------------------------------------------------
-- Wyzwalacze updated_at
drop trigger if exists set_timestamp_profiles on public.profiles;
create trigger set_timestamp_profiles
before update on public.profiles
for each row execute function public.set_current_timestamp_updated_at();

drop trigger if exists set_timestamp_tools on public.tools;
create trigger set_timestamp_tools
before update on public.tools
for each row execute function public.set_current_timestamp_updated_at();

drop trigger if exists set_timestamp_reservations on public.reservations;
create trigger set_timestamp_reservations
before update on public.reservations
for each row execute function public.set_current_timestamp_updated_at();

-- Wyzwalacz tsvector dla tools
drop trigger if exists tools_search_tsv on public.tools;
create trigger tools_search_tsv
before insert or update of name on public.tools
for each row execute function public.tools_search_tsv_trigger();

-- Blokuj aktualizacje/usunięcia w token_ledger (tylko do wstawiania)
drop trigger if exists token_ledger_block_update on public.token_ledger;
create trigger token_ledger_block_update
before update on public.token_ledger
for each row execute function public.block_update_delete();

drop trigger if exists token_ledger_block_delete on public.token_ledger;
create trigger token_ledger_block_delete
before delete on public.token_ledger
for each row execute function public.block_update_delete();

-- Wymuś spójność właściciela rezerwacji
drop trigger if exists reservations_owner_consistency on public.reservations;
create trigger reservations_owner_consistency
before insert or update of tool_id, owner_id on public.reservations
for each row execute function public.ensure_reservation_owner_consistency();

-- Zapobiegaj zmianie stron rezerwacji
drop trigger if exists reservations_parties_immutable on public.reservations;
create trigger reservations_parties_immutable
before update of owner_id, borrower_id on public.reservations
for each row execute function public.guard_reservations_parties_immutable();

-- Zapobiegaj bezpośrednim aktualizacjom statusu
drop trigger if exists reservations_prevent_direct_status on public.reservations;
create trigger reservations_prevent_direct_status
before update of status on public.reservations
for each row execute function public.raise_if_reservation_status_changed();

-- Zabezpieczenie wstawiania ocen: zezwalaj tylko, gdy status rezerwacji = 'returned'
create or replace function public.guard_ratings_after_return()
returns trigger
language plpgsql
as $$
declare
  v_status reservation_status;
begin
  select status into v_status from public.reservations where id = new.reservation_id;
  if v_status <> 'returned' then
    raise exception 'ratings allowed only after reservation is returned';
  end if;
  return new;
end;
$$;

drop trigger if exists ratings_after_return_guard on public.ratings;
create trigger ratings_after_return_guard
before insert on public.ratings
for each row execute function public.guard_ratings_after_return();

-- -----------------------------------------------------------------------------
-- Funkcje (Security Definer) (Logika biznesowa)
-- -----------------------------------------------------------------------------

-- FINALNA WERSJA: archive_tool (z 20251112100000)
CREATE OR REPLACE FUNCTION archive_tool(p_tool_id UUID, p_user_id UUID)
RETURNS TABLE (
  success BOOLEAN,
  code TEXT,
  message TEXT,
  http_status INT,
  archived_at TIMESTAMT_Z
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tool_owner_id UUID;
  v_has_active_reservations BOOLEAN;
  v_current_timestamp TIMESTAMPTZ := now();
BEGIN
  -- Authorization check should be done in RLS policies or application layer before calling this.
  -- We just fetch the owner_id to be sure.
  SELECT owner_id INTO v_tool_owner_id FROM public.tools WHERE id = p_tool_id;

  IF v_tool_owner_id != p_user_id THEN
    RETURN QUERY SELECT false, 'FORBIDDEN', 'User is not the owner of the tool.', 403, null::timestamptz;
    RETURN;
  END IF;

  -- Check for active reservations
  SELECT EXISTS (
    SELECT 1
    FROM public.reservations
    WHERE tool_id = p_tool_id
      AND status IN ('requested', 'owner_accepted', 'borrower_confirmed', 'picked_up')
  ) INTO v_has_active_reservations;

  IF v_has_active_reservations THEN
    RETURN QUERY SELECT false, 'TOOL_HAS_ACTIVE_RESERVATIONS', 'Tool has active reservations and cannot be archived.', 409, null::timestamptz;
    RETURN;
  END IF;

  -- Update the tool
  UPDATE public.tools
  SET
    status = 'archived',
    archived_at = v_current_timestamp
  WHERE id = p_tool_id;

  -- Insert into audit log
  INSERT INTO public.audit_log (user_id, event_type, details)
  VALUES (p_user_id, 'tool_archived', jsonb_build_object('tool_id', p_tool_id));

  -- Return success
  RETURN QUERY SELECT true, 'OK', 'Tool archived successfully.', 200, v_current_timestamp;

END;
$$;

-- Uprawnienia dla nowej funkcji
GRANT EXECUTE ON FUNCTION public.archive_tool(UUID, UUID) TO authenticated;


-- FINALNA WERSJA: publish_tool (z 20251112110000, poprawiona)
CREATE OR REPLACE FUNCTION publish_tool(tool_id_to_publish UUID)
RETURNS TABLE (
  id UUID,
  owner_id UUID,
  name TEXT,
  description TEXT,
  suggested_price_tokens INT,
  status tool_status,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  images jsonb
)
SECURITY DEFINER
AS $$
DECLARE
    tool_owner_id UUID;
    current_tool_status tool_status;
    image_count INT;
    updated_tool RECORD;
BEGIN
    -- Sprawdzenie, czy narzędzie istnieje i pobranie jego właściciela oraz statusu
    SELECT tools.owner_id, tools.status INTO tool_owner_id, current_tool_status
    FROM tools
    WHERE tools.id = tool_id_to_publish;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tool not found' USING ERRCODE = 'PGRST001'; -- Not Found
    END IF;

    -- Sprawdzenie, czy bieżący użytkownik jest właścicielem narzędzia
    IF tool_owner_id != auth.uid() THEN
        RAISE EXCEPTION 'Forbidden' USING ERRCODE = 'PGRST002'; -- Forbidden
    END IF;

    -- Sprawdzenie, czy status narzędzia to 'draft'
    IF current_tool_status != 'draft' THEN
        RAISE EXCEPTION 'Tool is not a draft' USING ERRCODE = 'PGRST003'; -- Unprocessable Entity
    END IF;

    -- Sprawdzenie, czy narzędzie ma co najmniej jedno zdjęcie
    SELECT count(*) INTO image_count
    FROM tool_images
    WHERE tool_images.tool_id = tool_id_to_publish;

    IF image_count = 0 THEN
        RAISE EXCEPTION 'Tool has no images' USING ERRCODE = 'PGRST004'; -- Conflict
    END IF;

    -- Aktualizacja statusu narzędzia
    UPDATE tools
    SET status = 'active', updated_at = now()
    WHERE tools.id = tool_id_to_publish;

    -- Logowanie do audit_log (Poprawiono 'action' na 'event_type')
    INSERT INTO audit_log (user_id, event_type, details)
    VALUES (auth.uid(), 'publish_tool', jsonb_build_object('tool_id', tool_id_to_publish));
    
    -- Zwrócenie zaktualizowanego narzędzia z obrazkami
    RETURN QUERY
    SELECT
        t.id,
        t.owner_id,
        t.name,
        t.description,
        t.suggested_price_tokens,
        t.status,
        t.created_at,
        t.updated_at,
        t.archived_at,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', ti.id,
                    'path', ti.path,
                    'bucket', ti.bucket,
                    'created_at', ti.created_at
                )
            )
            FROM tool_images ti
            WHERE ti.tool_id = t.id
        ) as images
    FROM
        tools t
    WHERE
        t.id = tool_id_to_publish;

END;
$$ LANGUAGE plpgsql;


-- FINALNA WERSJA: get_counterparty_contact (z 20251114100000)
create or replace function get_counterparty_contact (p_reservation_id uuid) returns table (owner_email text, borrower_email text) language plpgsql security definer set search_path = public as $$
declare
    v_invoker_id uuid := auth.uid();
    v_reservation record;
    v_owner_email text;
    v_borrower_email text;
begin
    -- 1. Fetch the reservation and verify invoker's participation
    select * into v_reservation
    from reservations
    where id = p_reservation_id;

    if not found then
        raise exception 'Reservation not found';
    end if;

    if v_reservation.owner_id <> v_invoker_id and v_reservation.borrower_id <> v_invoker_id then
        raise exception 'User is not a party to the reservation';
    end if;

    -- 2. Check reservation status
    if v_reservation.status not in ('borrower_confirmed', 'picked_up', 'returned') then
        raise exception 'Reservation is not in a state to reveal contacts';
    end if;

    -- 3. Log the audit event
    insert into audit_log (user_id, event_type, details)
    values (v_invoker_id, 'contact_reveal', jsonb_build_object('reservation_id', p_reservation_id));

    -- 4. Retrieve emails and return them
    select
        (select raw_user_meta_data->>'email' from auth.users where id = v_reservation.owner_id),
        (select raw_user_meta_data->>'email' from auth.users where id = v_reservation.borrower_id)
    into
        v_owner_email,
        v_borrower_email;

    return query select v_owner_email, v_borrower_email;
end;
$$;

-- FINALNA WERSJA: award_signup_bonus (z 20251114140000, poprawiona)
create or replace function award_signup_bonus(p_user_id uuid)
returns json as $$
declare
  bonus_amount int := 10;
  award_kind award_kind := 'signup_bonus';
  result json;
begin
  -- Attempt to record the award event.
  -- This will fail if the user has already received this type of award
  -- due to the unique constraint on (user_id, kind).
  insert into award_events (user_id, kind, amount)
  values (p_user_id, award_kind, bonus_amount);

  -- If the award event was inserted successfully, add tokens to the ledger.
  -- (Poprawiono INSERT, aby pasował do schematu token_ledger)
  insert into token_ledger (user_id, amount, kind, details)
  values (p_user_id, bonus_amount, 'award', jsonb_build_object('description', 'Signup bonus award'));

  -- Return success status
  result := json_build_object('status', 'success', 'amount', bonus_amount);
  return result;

exception
  when unique_violation then
    -- This exception is caught when the unique constraint (user_id, kind) is violated,
    -- meaning the user has already been awarded this bonus.
    result := json_build_object('status', 'conflict', 'message', 'Bonus already awarded.');
    return result;
  when others then
    -- Catch any other unexpected errors during the transaction.
    result := json_build_object('status', 'error', 'message', SQLERRM);
    return result;
end;
$$ language plpgsql security definer;


-- FINALNA WERSJA: award_listing_bonus (z 20251114150000, poprawiona)
create or replace function award_listing_bonus(p_user_id uuid, p_tool_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  is_owner boolean;
  bonus_previously_awarded boolean;
  user_bonus_count int;
  bonus_amount int := 2; -- Stała wartość bonusu
  new_count_used int;
begin
  -- 1. Sprawdź, czy użytkownik jest właścicielem narzędzia
  select exists(select 1 from tools where id = p_tool_id and owner_id = p_user_id) into is_owner;
  if not is_owner then
    raise exception 'User is not the owner of the tool or tool does not exist' using errcode = '42501'; -- insufficient_privilege
  end if;

  -- 2. Sprawdź, czy bonus za to narzędzie nie został już przyznany
  select exists(select 1 from award_events where user_id = p_user_id and tool_id = p_tool_id and kind = 'listing_bonus') into bonus_previously_awarded;
  if bonus_previously_awarded then
    raise exception 'Bonus for this tool has already been awarded' using errcode = '23505'; -- unique_violation
  end if;

  -- 3. Sprawdź, czy użytkownik nie przekroczył limitu bonusów za wystawienie
  select count(*) into user_bonus_count from award_events where user_id = p_user_id and kind = 'listing_bonus';
  if user_bonus_count >= 3 then
    raise exception 'User has reached the limit of listing bonuses' using errcode = 'P0001'; -- custom error for limit reached
  end if;
  
  -- 4. Wstaw nowy rekord do award_events
  insert into award_events(user_id, tool_id, kind) values (p_user_id, p_tool_id, 'listing_bonus');

  -- 5. Wstaw nowy rekord do token_ledger (Poprawiono kind='credit' na 'award' i 'description' na 'details')
  insert into token_ledger(user_id, amount, kind, details) 
  values (p_user_id, bonus_amount, 'award', jsonb_build_object('description', 'Bonus for listing a new tool: ' || p_tool_id));
  
  -- 6. Oblicz nowy stan wykorzystanych bonusów
  new_count_used := user_bonus_count + 1;

  -- 7. Zwróć odpowiedź sukcesu
  return json_build_object(
    'awarded', true,
    'amount', bonus_amount,
    'countUsed', new_count_used
  );
end;
$$;


-- FINALNA WERSJA: claim_rescue_token (z 20251114160000)
create or replace function public.claim_rescue_token(p_user_id uuid, p_amount integer default 1)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_date date := (now() at time zone 'cet')::date;
  v_available integer;
begin
  -- compute available from balances view
  select available into v_available from public.balances where user_id = p_user_id;
  if coalesce(v_available, 0) <> 0 then
    raise exception 'rescue token only when available = 0';
  end if;

  insert into public.rescue_claims(user_id, claim_date_cet)
  values (p_user_id, v_date);

  insert into public.token_ledger(user_id, kind, amount, details)
  values (p_user_id, 'award', p_amount, jsonb_build_object('source','rescue_claim','claim_date_cet',v_date::text));
end;
$$;

-- FINALNA WERSJA: reservation_transition (z 20251107090000)
create or replace function public.reservation_transition(p_reservation_id uuid, p_new_status reservation_status, p_price_tokens smallint default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_res reservations%rowtype;
  v_hold_id uuid;
  v_available integer;
begin
  -- guard: serialize on reservation id
  perform pg_advisory_xact_lock( ('x'||substr(p_reservation_id::text,1,16))::bit(64)::bigint );

  select * into v_res from public.reservations where id = p_reservation_id for update;
  if not found then
    raise exception 'reservation % not found', p_reservation_id;
  end if;

  -- allow status update inside this function only
  perform set_config('app.allow_reservation_status_update','true', true);

  if v_res.status = 'requested' and p_new_status = 'owner_accepted' then
    if p_price_tokens is null then
      raise exception 'agreed price must be provided on owner_accepted';
    end if;
    update public.reservations set status = 'owner_accepted', agreed_price_tokens = p_price_tokens where id = p_reservation_id;

  elsif v_res.status = 'owner_accepted' and p_new_status = 'borrower_confirmed' then
    update public.reservations set status = 'borrower_confirmed' where id = p_reservation_id;

  elsif v_res.status = 'borrower_confirmed' and p_new_status = 'picked_up' then
    -- ensure borrower has available >= agreed price
    select available into v_available from public.balances where user_id = v_res.borrower_id;
    if coalesce(v_available, 0) < coalesce(v_res.agreed_price_tokens, 0) then
      raise exception 'insufficient available balance to place hold';
    end if;
    -- place hold (negative amount)
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.borrower_id, v_res.id, 'hold', -1 * v_res.agreed_price_tokens, jsonb_build_object('reason','reservation_hold'))
    returning id into v_hold_id;
    update public.reservations set status = 'picked_up' where id = p_reservation_id;

  elsif v_res.status = 'picked_up' and p_new_status = 'returned' then
    -- release the hold and transfer to owner
    -- release (positive) referencing for_hold
    select id into v_hold_id from public.token_ledger where reservation_id = v_res.id and kind = 'hold' and user_id = v_res.borrower_id;
    if v_hold_id is null then
      raise exception 'missing hold to release';
    end if;
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.borrower_id, v_res.id, 'release', v_res.agreed_price_tokens, jsonb_build_object('for_hold', v_hold_id));
    -- transfer pair: debit borrower (negative), credit owner (positive)
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.borrower_id, v_res.id, 'transfer', -1 * v_res.agreed_price_tokens, jsonb_build_object('to', v_res.owner_id));
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.owner_id, v_res.id, 'transfer', v_res.agreed_price_tokens, jsonb_build_object('from', v_res.borrower_id));
    update public.reservations set status = 'returned' where id = p_reservation_id;

  elsif p_new_status in ('cancelled','rejected') then
    -- if cancel from any pre-returned state, release any holds
    if v_res.status in ('owner_accepted','borrower_confirmed','picked_up') then
      select id into v_hold_id from public.token_ledger where reservation_id = v_res.id and kind = 'hold' and user_id = v_res.borrower_id;
      if v_hold_id is not null then
        insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
        values (v_res.borrower_id, v_res.id, 'release', coalesce(v_res.agreed_price_tokens,0), jsonb_build_object('for_hold', v_hold_id));
      end if;
    end if;
    update public.reservations set status = p_new_status where id = p_reservation_id;

  else
    raise exception 'invalid state transition from % to %', v_res.status, p_new_status;
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- Row Level Security (Włączanie i polityki)
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.tools enable row level security;
alter table public.tool_images enable row level security;
alter table public.reservations enable row level security;
alter table public.token_ledger enable row level security;
alter table public.award_events enable row level security;
alter table public.rescue_claims enable row level security;
alter table public.ratings enable row level security;
alter table public.audit_log enable row level security;

-- Polityki profiles
drop policy if exists profiles_select_anon on public.profiles;
create policy profiles_select_anon on public.profiles for select to anon using (false);

drop policy if exists profiles_select_auth on public.profiles;
create policy profiles_select_auth on public.profiles for select to authenticated using (id = auth.uid());

drop policy if exists profiles_ins_auth on public.profiles;
create policy profiles_ins_auth on public.profiles for insert to authenticated with check (id = auth.uid());

drop policy if exists profiles_upd_auth on public.profiles;
create policy profiles_upd_auth on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Polityki tools
drop policy if exists tools_select_anon on public.tools;
create policy tools_select_anon on public.tools for select to anon using (status in ('active'));

drop policy if exists tools_select_auth on public.tools;
create policy tools_select_auth on public.tools for select to authenticated using (status in ('active') or owner_id = auth.uid());

drop policy if exists tools_ins_auth on public.tools;
create policy tools_ins_auth on public.tools for insert to authenticated with check (owner_id = auth.uid());

drop policy if exists tools_upd_auth on public.tools;
create policy tools_upd_auth on public.tools for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists tools_del_auth on public.tools;
create policy tools_del_auth on public.tools for delete to authenticated using (owner_id = auth.uid());

-- Polityki tool_images
drop policy if exists tool_images_select_anon on public.tool_images;
create policy tool_images_select_anon on public.tool_images for select to anon using (
  exists(select 1 from public.tools t where t.id = tool_id and t.status in ('active'))
);

drop policy if exists tool_images_select_auth on public.tool_images;
create policy tool_images_select_auth on public.tool_images for select to authenticated using (
  exists(select 1 from public.tools t where t.id = tool_id and (t.status in ('active') or t.owner_id = auth.uid()))
);

drop policy if exists tool_images_cud_auth on public.tool_images;
create policy tool_images_cud_auth on public.tool_images for all to authenticated using (
  exists(select 1 from public.tools t where t.id = tool_id and t.owner_id = auth.uid())
) with check (
  exists(select 1 from public.tools t where t.id = tool_id and t.owner_id = auth.uid())
);

-- Polityki reservations
drop policy if exists reservations_select_anon on public.reservations;
create policy reservations_select_anon on public.reservations for select to anon using (false);

drop policy if exists reservations_select_auth on public.reservations;
create policy reservations_select_auth on public.reservations for select to authenticated using (owner_id = auth.uid() or borrower_id = auth.uid());

drop policy if exists reservations_insert_auth on public.reservations;
create policy reservations_insert_auth on public.reservations for insert to authenticated with check (borrower_id = auth.uid());

drop policy if exists reservations_update_auth on public.reservations;
create policy reservations_update_auth on public.reservations for update to authenticated using (owner_id = auth.uid() or borrower_id = auth.uid()) with check (true);

-- Polityki token_ledger
drop policy if exists token_ledger_select_anon on public.token_ledger;
create policy token_ledger_select_anon on public.token_ledger for select to anon using (false);

drop policy if exists token_ledger_select_auth on public.token_ledger;
create policy token_ledger_select_auth on public.token_ledger for select to authenticated using (user_id = auth.uid());

-- brak polityk insert/update/delete dla token_ledger (zarządzane przez funkcje security definer)

-- Polityki award_events
drop policy if exists award_events_select_anon on public.award_events;
create policy award_events_select_anon on public.award_events for select to anon using (false);

drop policy if exists award_events_select_auth on public.award_events;
create policy award_events_select_auth on public.award_events for select to authenticated using (user_id = auth.uid());

-- Polityki rescue_claims
drop policy if exists rescue_claims_select_anon on public.rescue_claims;
create policy rescue_claims_select_anon on public.rescue_claims for select to anon using (false);

drop policy if exists rescue_claims_select_auth on public.rescue_claims;
create policy rescue_claims_select_auth on public.rescue_claims for select to authenticated using (user_id = auth.uid());

-- Polityki ratings
drop policy if exists ratings_select_anon on public.ratings;
create policy ratings_select_anon on public.ratings for select to anon using (false);

drop policy if exists ratings_select_auth on public.ratings;
create policy ratings_select_auth on public.ratings for select to authenticated using (rater_id = auth.uid() or rated_user_id = auth.uid());

drop policy if exists ratings_insert_auth on public.ratings;
create policy ratings_insert_auth on public.ratings for insert to authenticated with check (rater_id = auth.uid());

-- Polityki audit_log (restrykcyjne)
drop policy if exists audit_log_select_anon on public.audit_log;
create policy audit_log_select_anon on public.audit_log for select to anon using (false);

drop policy if exists audit_log_select_auth on public.audit_log;
create policy audit_log_select_auth on public.audit_log for select to authenticated using (user_id = auth.uid()); -- Zmieniono z actor_id

-- -----------------------------------------------------------------------------
-- Koniec skonsolidowanej migracji
-- -----------------------------------------------------------------------------