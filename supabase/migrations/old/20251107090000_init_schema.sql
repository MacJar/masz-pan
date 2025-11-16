-- migration: initial schema for masz-pan per .ai/db-plan.md
-- purpose: create extensions, enum types, tables, constraints, indexes, views, materialized views,
--          security definer functions, triggers, and rls policies implementing the specified data model
-- affected: profiles, tools, tool_images, reservations, token_ledger, award_events,
--           rescue_claims, ratings, audit_log, balances view, public_profiles view,
--           rating_stats materialized view, helper functions and triggers
-- notes:
-- - all identifiers and sql are lowercase by convention
-- - rls is enabled for all user tables by default
-- - destructive commands are not used; if added in the future, they must be commented extensively

-- -----------------------------------------------------------------------------
-- extensions
-- -----------------------------------------------------------------------------
create extension if not exists postgis with schema public;
create extension if not exists pgcrypto with schema public;
create extension if not exists citext with schema public;
create extension if not exists pg_trgm with schema public;

-- -----------------------------------------------------------------------------
-- storage buckets
-- -----------------------------------------------------------------------------
-- tool_images bucket (publicly accessible)
insert into storage.buckets (id, name, public)
values ('tool_images', 'tool_images', true)
on conflict (id) do nothing;

-- TODO: Restrict this policy when authentication is implemented.
-- For now, allow all public users to upload to the tool_images bucket
-- to facilitate development without a full auth flow.
create policy "Allow public uploads to tool_images"
on storage.objects for insert to public with check (
  bucket_id = 'tool_images'
);

-- -----------------------------------------------------------------------------
-- enum types
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
-- helper functions (shared)
-- -----------------------------------------------------------------------------
-- ensure updated_at is set to now() on row updates
create or replace function public.set_current_timestamp_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- fts helper: use 'polish' if available otherwise fallback to 'simple'
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

-- guard to allow controlled status updates via reservation_transition only
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

-- block any update/delete on insert-only tables
create or replace function public.block_update_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'updates/deletes are not permitted on this table (insert-only)';
end;
$$;

-- ensure reservations.owner_id matches tools.owner_id
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

-- guard immutability of reservation parties (owner_id and borrower_id)
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

-- maintain tools.search_name_tsv
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
-- tables
-- -----------------------------------------------------------------------------

-- profiles: 1-1 with auth.users
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext not null unique check (username <> ''),
  location_text text,
  location_geog public.geography(point, 4326),
  rodo_consent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- tools: listed tools owned by profiles
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

-- tool_images: images for tools, stored in supabase storage; position unique per tool
create table if not exists public.tool_images (
  id uuid primary key default gen_random_uuid(),
  tool_id uuid not null references public.tools(id) on delete cascade,
  storage_key text not null,
  position smallint not null default 0,
  created_at timestamptz not null default now(),
  unique (tool_id, position)
);

-- reservations: lifecycle state machine for lending
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

-- token_ledger: insert-only double-entry like ledger for tokens
create table if not exists public.token_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  reservation_id uuid null references public.reservations(id) on delete restrict,
  kind ledger_kind not null,
  amount integer not null check (amount <> 0),
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- award_events: sources of truth for bonuses
create table if not exists public.award_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  kind award_kind not null,
  tool_id uuid null references public.tools(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint award_signup_unique unique (user_id) deferrable initially immediate
    -- uniqueness for signup_bonus enforced via partial unique index below
);

-- rescue_claims: +1 token per day when available balance is zero
create table if not exists public.rescue_claims (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  claim_date_cet date not null,
  created_at timestamptz not null default now(),
  unique (user_id, claim_date_cet)
);

-- ratings: post-transaction feedback
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null references public.reservations(id) on delete restrict,
  rater_id uuid not null references public.profiles(id) on delete restrict,
  rated_user_id uuid not null references public.profiles(id) on delete restrict,
  stars smallint not null check (stars between 1 and 5),
  created_at timestamptz not null default now(),
  unique (reservation_id, rater_id)
);

-- audit_log: append-only audit events
create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  actor_id uuid null references public.profiles(id) on delete set null,
  reservation_id uuid null references public.reservations(id) on delete set null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- indexes
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

-- token_ledger
create index if not exists idx_token_ledger_user on public.token_ledger (user_id);
create index if not exists idx_token_ledger_reservation on public.token_ledger (reservation_id);
create index if not exists idx_token_ledger_kind_created on public.token_ledger (kind, created_at);
create unique index if not exists uq_token_ledger_hold_once on public.token_ledger (user_id, reservation_id)
  where kind = 'hold';

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
create index if not exists idx_audit_log_actor on public.audit_log (actor_id);

-- -----------------------------------------------------------------------------
-- views and materialized views
-- -----------------------------------------------------------------------------
-- balances: aggregated token balances per user
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

-- materialized view: rating_stats
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

-- public_profiles: restricted public fields + rating stats
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
-- triggers
-- -----------------------------------------------------------------------------
-- updated_at triggers
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

-- tsvector trigger for tools
drop trigger if exists tools_search_tsv on public.tools;
create trigger tools_search_tsv
before insert or update of name on public.tools
for each row execute function public.tools_search_tsv_trigger();

-- block updates/deletes on token_ledger (insert-only)
drop trigger if exists token_ledger_block_update on public.token_ledger;
create trigger token_ledger_block_update
before update on public.token_ledger
for each row execute function public.block_update_delete();

drop trigger if exists token_ledger_block_delete on public.token_ledger;
create trigger token_ledger_block_delete
before delete on public.token_ledger
for each row execute function public.block_update_delete();

-- enforce reservation owner consistency
drop trigger if exists reservations_owner_consistency on public.reservations;
create trigger reservations_owner_consistency
before insert or update of tool_id, owner_id on public.reservations
for each row execute function public.ensure_reservation_owner_consistency();

-- prevent changing reservation parties
drop trigger if exists reservations_parties_immutable on public.reservations;
create trigger reservations_parties_immutable
before update of owner_id, borrower_id on public.reservations
for each row execute function public.guard_reservations_parties_immutable();

-- prevent direct status updates
drop trigger if exists reservations_prevent_direct_status on public.reservations;
create trigger reservations_prevent_direct_status
before update of status on public.reservations
for each row execute function public.raise_if_reservation_status_changed();

-- -----------------------------------------------------------------------------
-- security definer functions (business logic)
-- -----------------------------------------------------------------------------
-- publish_tool(tool_id): ensures at least one image and sets status active
create or replace function public.publish_tool(p_tool_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner uuid;
  v_img_count int;
begin
  select owner_id into v_owner from public.tools where id = p_tool_id for update;
  if v_owner is null then
    raise exception 'tool % not found', p_tool_id;
  end if;
  -- ensure caller is the owner
  if v_owner <> auth.uid() then
    raise exception 'only owner can publish the tool';
  end if;
  select count(*) into v_img_count from public.tool_images where tool_id = p_tool_id;
  if v_img_count < 1 then
    raise exception 'cannot publish without at least one image';
  end if;
  update public.tools
    set status = 'active', archived_at = null, updated_at = now()
  where id = p_tool_id;
end;
$$;

-- get_counterparty_contact: emails only after both sides confirmed (>= borrower_confirmed)
create or replace function public.get_counterparty_contact(p_reservation_id uuid)
returns table(owner_email text, borrower_email text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner uuid;
  v_borrower uuid;
  v_status reservation_status;
  v_actor uuid := auth.uid();
begin
  select owner_id, borrower_id, status
    into v_owner, v_borrower, v_status
  from public.reservations
  where id = p_reservation_id;

  if v_owner is null then
    raise exception 'reservation % not found', p_reservation_id;
  end if;

  if v_actor <> v_owner and v_actor <> v_borrower then
    raise exception 'only counterparty can access contacts';
  end if;

  if v_status not in ('borrower_confirmed','picked_up','returned') then
    raise exception 'contacts available only after mutual confirmation';
  end if;

  -- fetch emails from auth.users
  return query
  select (select email from auth.users where id = v_owner) as owner_email,
         (select email from auth.users where id = v_borrower) as borrower_email;

  -- audit
  insert into public.audit_log(event_type, actor_id, reservation_id, details)
  values ('contact_reveal', v_actor, p_reservation_id, jsonb_build_object('reason','counterparty_contact'));
end;
$$;

-- award signup bonus (+N tokens) once per user
create or replace function public.award_signup_bonus(p_user_id uuid, p_amount integer default 5)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- ensure single award via unique index; insert will fail if already exists
  insert into public.award_events(user_id, kind)
  values (p_user_id, 'signup_bonus');

  insert into public.token_ledger(user_id, kind, amount, details)
  values (p_user_id, 'award', p_amount, jsonb_build_object('award','signup_bonus'));
end;
$$;

-- award listing bonus for first 3 tools per user
create or replace function public.award_listing_bonus(p_user_id uuid, p_tool_id uuid, p_amount integer default 2)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  -- enforce first 3 bonuses per user
  select count(*) into v_count from public.award_events where user_id = p_user_id and kind = 'listing_bonus';
  if v_count >= 3 then
    raise exception 'listing bonus limit reached';
  end if;

  insert into public.award_events(user_id, kind, tool_id)
  values (p_user_id, 'listing_bonus', p_tool_id);

  insert into public.token_ledger(user_id, kind, amount, details)
  values (p_user_id, 'award', p_amount, jsonb_build_object('award','listing_bonus','tool_id',p_tool_id));
end;
$$;

-- claim_rescue_token: once per CET day when available = 0
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
  values (p_user_id, 'credit', p_amount, jsonb_build_object('source','rescue_claim','claim_date_cet',v_date::text));
end;
$$;

-- reservation_transition: enforce state machine and token flows
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

-- ratings insert guard: allow only when reservation status = 'returned'
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
-- row level security (enable and policies)
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

-- profiles policies
drop policy if exists profiles_select_anon on public.profiles;
create policy profiles_select_anon on public.profiles for select to anon using (false);

drop policy if exists profiles_select_auth on public.profiles;
create policy profiles_select_auth on public.profiles for select to authenticated using (id = auth.uid());

drop policy if exists profiles_ins_auth on public.profiles;
create policy profiles_ins_auth on public.profiles for insert to authenticated with check (id = auth.uid());

drop policy if exists profiles_upd_auth on public.profiles;
create policy profiles_upd_auth on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- tools policies
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

-- tool_images policies
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

-- reservations policies
drop policy if exists reservations_select_anon on public.reservations;
create policy reservations_select_anon on public.reservations for select to anon using (false);

drop policy if exists reservations_select_auth on public.reservations;
create policy reservations_select_auth on public.reservations for select to authenticated using (owner_id = auth.uid() or borrower_id = auth.uid());

drop policy if exists reservations_insert_auth on public.reservations;
create policy reservations_insert_auth on public.reservations for insert to authenticated with check (borrower_id = auth.uid());

drop policy if exists reservations_update_auth on public.reservations;
create policy reservations_update_auth on public.reservations for update to authenticated using (owner_id = auth.uid() or borrower_id = auth.uid()) with check (true);

-- token_ledger policies
drop policy if exists token_ledger_select_anon on public.token_ledger;
create policy token_ledger_select_anon on public.token_ledger for select to anon using (false);

drop policy if exists token_ledger_select_auth on public.token_ledger;
create policy token_ledger_select_auth on public.token_ledger for select to authenticated using (user_id = auth.uid());

-- no insert/update/delete policies for token_ledger (managed by security definer functions)

-- award_events policies
drop policy if exists award_events_select_anon on public.award_events;
create policy award_events_select_anon on public.award_events for select to anon using (false);

drop policy if exists award_events_select_auth on public.award_events;
create policy award_events_select_auth on public.award_events for select to authenticated using (user_id = auth.uid());

-- rescue_claims policies
drop policy if exists rescue_claims_select_anon on public.rescue_claims;
create policy rescue_claims_select_anon on public.rescue_claims for select to anon using (false);

drop policy if exists rescue_claims_select_auth on public.rescue_claims;
create policy rescue_claims_select_auth on public.rescue_claims for select to authenticated using (user_id = auth.uid());

-- ratings policies
drop policy if exists ratings_select_anon on public.ratings;
create policy ratings_select_anon on public.ratings for select to anon using (false);

drop policy if exists ratings_select_auth on public.ratings;
create policy ratings_select_auth on public.ratings for select to authenticated using (rater_id = auth.uid() or rated_user_id = auth.uid());

drop policy if exists ratings_insert_auth on public.ratings;
create policy ratings_insert_auth on public.ratings for insert to authenticated with check (rater_id = auth.uid());

-- audit_log policies (restrictive)
drop policy if exists audit_log_select_anon on public.audit_log;
create policy audit_log_select_anon on public.audit_log for select to anon using (false);

drop policy if exists audit_log_select_auth on public.audit_log;
create policy audit_log_select_auth on public.audit_log for select to authenticated using (actor_id = auth.uid());

-- -----------------------------------------------------------------------------
-- end of migration
-- -----------------------------------------------------------------------------


