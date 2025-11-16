create extension if not exists "citext" with schema "public";

create extension if not exists "pg_trgm" with schema "public";

create extension if not exists "postgis" with schema "public";

create type "public"."award_kind" as enum ('signup_bonus', 'listing_bonus');

create type "public"."ledger_kind" as enum ('debit', 'credit', 'hold', 'release', 'transfer', 'award');

create type "public"."reservation_status" as enum ('requested', 'owner_accepted', 'borrower_confirmed', 'picked_up', 'returned', 'cancelled', 'rejected');

create type "public"."tool_status" as enum ('draft', 'inactive', 'active', 'archived');


  create table "public"."audit_log" (
    "id" uuid not null default gen_random_uuid(),
    "event_type" text not null,
    "actor_id" uuid,
    "reservation_id" uuid,
    "details" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."award_events" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "kind" public.award_kind not null,
    "tool_id" uuid,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."profiles" (
    "id" uuid not null,
    "username" public.citext not null,
    "location_text" text,
    "location_geog" public.geography(Point,4326),
    "rodo_consent" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "is_complete" boolean default false
      );



  create table "public"."ratings" (
    "id" uuid not null default gen_random_uuid(),
    "reservation_id" uuid not null,
    "rater_id" uuid not null,
    "rated_user_id" uuid not null,
    "stars" smallint not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."rescue_claims" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "claim_date_cet" date not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."reservations" (
    "id" uuid not null default gen_random_uuid(),
    "tool_id" uuid not null,
    "owner_id" uuid not null,
    "borrower_id" uuid not null,
    "status" public.reservation_status not null default 'requested'::public.reservation_status,
    "agreed_price_tokens" smallint,
    "cancelled_reason" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."token_ledger" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "reservation_id" uuid,
    "kind" public.ledger_kind not null,
    "amount" integer not null,
    "details" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."tool_images" (
    "id" uuid not null default gen_random_uuid(),
    "tool_id" uuid not null,
    "storage_key" text not null,
    "position" smallint not null default 0,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."tools" (
    "id" uuid not null default gen_random_uuid(),
    "owner_id" uuid not null,
    "name" text not null,
    "description" text,
    "suggested_price_tokens" smallint not null,
    "status" public.tool_status not null default 'draft'::public.tool_status,
    "search_name_tsv" tsvector,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "archived_at" timestamp with time zone
      );


CREATE UNIQUE INDEX audit_log_pkey ON public.audit_log USING btree (id);

CREATE UNIQUE INDEX award_events_pkey ON public.award_events USING btree (id);

CREATE INDEX idx_audit_log_actor ON public.audit_log USING btree (actor_id);

CREATE INDEX idx_audit_log_created_at ON public.audit_log USING btree (created_at);

CREATE INDEX idx_audit_log_event_type ON public.audit_log USING btree (event_type);

CREATE INDEX idx_audit_log_reservation ON public.audit_log USING btree (reservation_id);

CREATE INDEX idx_award_events_user_kind ON public.award_events USING btree (user_id, kind);

CREATE INDEX idx_profiles_location_geog ON public.profiles USING gist (location_geog);

CREATE INDEX idx_ratings_rated_user ON public.ratings USING btree (rated_user_id);

CREATE INDEX idx_reservations_borrower ON public.reservations USING btree (borrower_id);

CREATE INDEX idx_reservations_borrower_created_at_id ON public.reservations USING btree (borrower_id, created_at DESC, id DESC);

CREATE INDEX idx_reservations_owner ON public.reservations USING btree (owner_id);

CREATE INDEX idx_reservations_owner_created_at_id ON public.reservations USING btree (owner_id, created_at DESC, id DESC);

CREATE INDEX idx_reservations_status ON public.reservations USING btree (status);

CREATE INDEX idx_reservations_tool ON public.reservations USING btree (tool_id);

CREATE INDEX idx_token_ledger_kind_created ON public.token_ledger USING btree (kind, created_at);

CREATE INDEX idx_token_ledger_reservation ON public.token_ledger USING btree (reservation_id);

CREATE INDEX idx_token_ledger_user ON public.token_ledger USING btree (user_id);

CREATE INDEX idx_token_ledger_user_kind_created_at_id ON public.token_ledger USING btree (user_id, kind, created_at DESC, id DESC);

CREATE INDEX idx_tool_images_tool ON public.tool_images USING btree (tool_id);

CREATE INDEX idx_tools_owner_status ON public.tools USING btree (owner_id, status);

CREATE INDEX idx_tools_search_tsv ON public.tools USING gin (search_name_tsv);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX profiles_username_key ON public.profiles USING btree (username);

CREATE UNIQUE INDEX ratings_pkey ON public.ratings USING btree (id);

CREATE UNIQUE INDEX ratings_reservation_id_rater_id_key ON public.ratings USING btree (reservation_id, rater_id);

CREATE UNIQUE INDEX rescue_claims_pkey ON public.rescue_claims USING btree (id);

CREATE UNIQUE INDEX rescue_claims_user_id_claim_date_cet_key ON public.rescue_claims USING btree (user_id, claim_date_cet);

CREATE UNIQUE INDEX reservations_pkey ON public.reservations USING btree (id);

CREATE UNIQUE INDEX token_ledger_pkey ON public.token_ledger USING btree (id);

CREATE UNIQUE INDEX tool_images_pkey ON public.tool_images USING btree (id);

CREATE UNIQUE INDEX tool_images_tool_id_position_key ON public.tool_images USING btree (tool_id, "position");

CREATE UNIQUE INDEX tools_pkey ON public.tools USING btree (id);

CREATE UNIQUE INDEX uq_award_listing ON public.award_events USING btree (user_id, tool_id) WHERE (kind = 'listing_bonus'::public.award_kind);

CREATE UNIQUE INDEX uq_award_signup ON public.award_events USING btree (user_id) WHERE (kind = 'signup_bonus'::public.award_kind);

CREATE UNIQUE INDEX uq_reservations_active_tool ON public.reservations USING btree (tool_id) WHERE (status = ANY (ARRAY['requested'::public.reservation_status, 'owner_accepted'::public.reservation_status, 'borrower_confirmed'::public.reservation_status, 'picked_up'::public.reservation_status]));

CREATE UNIQUE INDEX uq_token_ledger_hold_once ON public.token_ledger USING btree (user_id, reservation_id) WHERE (kind = 'hold'::public.ledger_kind);

alter table "public"."audit_log" add constraint "audit_log_pkey" PRIMARY KEY using index "audit_log_pkey";

alter table "public"."award_events" add constraint "award_events_pkey" PRIMARY KEY using index "award_events_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."ratings" add constraint "ratings_pkey" PRIMARY KEY using index "ratings_pkey";

alter table "public"."rescue_claims" add constraint "rescue_claims_pkey" PRIMARY KEY using index "rescue_claims_pkey";

alter table "public"."reservations" add constraint "reservations_pkey" PRIMARY KEY using index "reservations_pkey";

alter table "public"."token_ledger" add constraint "token_ledger_pkey" PRIMARY KEY using index "token_ledger_pkey";

alter table "public"."tool_images" add constraint "tool_images_pkey" PRIMARY KEY using index "tool_images_pkey";

alter table "public"."tools" add constraint "tools_pkey" PRIMARY KEY using index "tools_pkey";

alter table "public"."audit_log" add constraint "audit_log_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."audit_log" validate constraint "audit_log_actor_id_fkey";

alter table "public"."audit_log" add constraint "audit_log_reservation_id_fkey" FOREIGN KEY (reservation_id) REFERENCES public.reservations(id) ON DELETE SET NULL not valid;

alter table "public"."audit_log" validate constraint "audit_log_reservation_id_fkey";

alter table "public"."award_events" add constraint "award_events_tool_id_fkey" FOREIGN KEY (tool_id) REFERENCES public.tools(id) ON DELETE RESTRICT not valid;

alter table "public"."award_events" validate constraint "award_events_tool_id_fkey";

alter table "public"."award_events" add constraint "award_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."award_events" validate constraint "award_events_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_username_check" CHECK ((username OPERATOR(public.<>) ''::public.citext)) not valid;

alter table "public"."profiles" validate constraint "profiles_username_check";

alter table "public"."profiles" add constraint "profiles_username_key" UNIQUE using index "profiles_username_key";

alter table "public"."ratings" add constraint "ratings_rated_user_id_fkey" FOREIGN KEY (rated_user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."ratings" validate constraint "ratings_rated_user_id_fkey";

alter table "public"."ratings" add constraint "ratings_rater_id_fkey" FOREIGN KEY (rater_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."ratings" validate constraint "ratings_rater_id_fkey";

alter table "public"."ratings" add constraint "ratings_reservation_id_fkey" FOREIGN KEY (reservation_id) REFERENCES public.reservations(id) ON DELETE RESTRICT not valid;

alter table "public"."ratings" validate constraint "ratings_reservation_id_fkey";

alter table "public"."ratings" add constraint "ratings_reservation_id_rater_id_key" UNIQUE using index "ratings_reservation_id_rater_id_key";

alter table "public"."ratings" add constraint "ratings_stars_check" CHECK (((stars >= 1) AND (stars <= 5))) not valid;

alter table "public"."ratings" validate constraint "ratings_stars_check";

alter table "public"."rescue_claims" add constraint "rescue_claims_user_id_claim_date_cet_key" UNIQUE using index "rescue_claims_user_id_claim_date_cet_key";

alter table "public"."rescue_claims" add constraint "rescue_claims_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."rescue_claims" validate constraint "rescue_claims_user_id_fkey";

alter table "public"."reservations" add constraint "reservations_agreed_price_tokens_check" CHECK (((agreed_price_tokens >= 1) AND (agreed_price_tokens <= 255))) not valid;

alter table "public"."reservations" validate constraint "reservations_agreed_price_tokens_check";

alter table "public"."reservations" add constraint "reservations_borrower_id_fkey" FOREIGN KEY (borrower_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."reservations" validate constraint "reservations_borrower_id_fkey";

alter table "public"."reservations" add constraint "reservations_check" CHECK ((owner_id <> borrower_id)) not valid;

alter table "public"."reservations" validate constraint "reservations_check";

alter table "public"."reservations" add constraint "reservations_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."reservations" validate constraint "reservations_owner_id_fkey";

alter table "public"."reservations" add constraint "reservations_tool_id_fkey" FOREIGN KEY (tool_id) REFERENCES public.tools(id) ON DELETE RESTRICT not valid;

alter table "public"."reservations" validate constraint "reservations_tool_id_fkey";

alter table "public"."token_ledger" add constraint "token_ledger_amount_check" CHECK ((amount <> 0)) not valid;

alter table "public"."token_ledger" validate constraint "token_ledger_amount_check";

alter table "public"."token_ledger" add constraint "token_ledger_reservation_id_fkey" FOREIGN KEY (reservation_id) REFERENCES public.reservations(id) ON DELETE RESTRICT not valid;

alter table "public"."token_ledger" validate constraint "token_ledger_reservation_id_fkey";

alter table "public"."token_ledger" add constraint "token_ledger_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."token_ledger" validate constraint "token_ledger_user_id_fkey";

alter table "public"."tool_images" add constraint "tool_images_tool_id_fkey" FOREIGN KEY (tool_id) REFERENCES public.tools(id) ON DELETE CASCADE not valid;

alter table "public"."tool_images" validate constraint "tool_images_tool_id_fkey";

alter table "public"."tool_images" add constraint "tool_images_tool_id_position_key" UNIQUE using index "tool_images_tool_id_position_key";

alter table "public"."tools" add constraint "tools_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."tools" validate constraint "tools_owner_id_fkey";

alter table "public"."tools" add constraint "tools_suggested_price_tokens_check" CHECK (((suggested_price_tokens >= 1) AND (suggested_price_tokens <= 5))) not valid;

alter table "public"."tools" validate constraint "tools_suggested_price_tokens_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.award_listing_bonus(p_user_id uuid, p_tool_id uuid, p_amount integer DEFAULT 2)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_count int;
begin
  -- enforce first 3 listing bonuses per user
  select count(*)
    into v_count
    from public.award_events
   where user_id = p_user_id
     and kind = 'listing_bonus';

  if v_count >= 3 then
    raise exception 'listing bonus limit reached' using errcode = 'P0001';
  end if;

  -- ensure the tool belongs to the user
  if not exists (select 1 from public.tools where id = p_tool_id and owner_id = p_user_id) then
    raise exception 'user does not own this tool' using errcode = '42501';
  end if;

  -- record award event (unique constraint prevents duplicates per tool)
  insert into public.award_events(user_id, kind, tool_id)
  values (p_user_id, 'listing_bonus', p_tool_id);

  -- insert ledger credit
  insert into public.token_ledger(user_id, kind, amount, details)
  values (
    p_user_id,
    'award',
    p_amount,
    jsonb_build_object('award', 'listing_bonus', 'tool_id', p_tool_id)
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.award_signup_bonus(p_user_id uuid, p_amount integer DEFAULT 10)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  -- prevent duplicate awards via unique constraint on (user_id, kind)
  insert into public.award_events(user_id, kind)
  values (p_user_id, 'signup_bonus');

  -- log credit in ledger so users can see the bonus in history
  insert into public.token_ledger(user_id, kind, amount, details)
  values (
    p_user_id,
    'award',
    p_amount,
    jsonb_build_object('award', 'signup_bonus')
  );
end;
$function$
;

create or replace view "public"."balances" as  WITH base AS (
         SELECT token_ledger.user_id,
            sum(token_ledger.amount) AS total
           FROM public.token_ledger
          GROUP BY token_ledger.user_id
        ), holds AS (
         SELECT token_ledger.user_id,
            COALESCE(sum(
                CASE
                    WHEN (token_ledger.kind = 'hold'::public.ledger_kind) THEN token_ledger.amount
                    ELSE 0
                END), (0)::bigint) AS sum_holds,
            COALESCE(sum(
                CASE
                    WHEN ((token_ledger.kind = ANY (ARRAY['release'::public.ledger_kind, 'transfer'::public.ledger_kind])) AND (token_ledger.details ? 'for_hold'::text)) THEN token_ledger.amount
                    ELSE 0
                END), (0)::bigint) AS sum_offsets
           FROM public.token_ledger
          GROUP BY token_ledger.user_id
        )
 SELECT p.id AS user_id,
    COALESCE(b.total, (0)::bigint) AS total,
    GREATEST((COALESCE(h.sum_holds, (0)::bigint) - COALESCE(h.sum_offsets, (0)::bigint)), (0)::bigint) AS held,
    (COALESCE(b.total, (0)::bigint) - GREATEST((COALESCE(h.sum_holds, (0)::bigint) - COALESCE(h.sum_offsets, (0)::bigint)), (0)::bigint)) AS available
   FROM ((public.profiles p
     LEFT JOIN base b ON ((b.user_id = p.id)))
     LEFT JOIN holds h ON ((h.user_id = p.id)));


CREATE OR REPLACE FUNCTION public.block_update_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  raise exception 'updates/deletes are not permitted on this table (insert-only)';
end;
$function$
;

CREATE OR REPLACE FUNCTION public.claim_rescue_token(p_user_id uuid, p_amount integer DEFAULT 1)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_reservation_owner_consistency()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.fts_polish_or_simple(input text)
 RETURNS tsvector
 LANGUAGE plpgsql
 STABLE
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_counterparty_contact(p_reservation_id uuid)
 RETURNS TABLE(owner_email text, borrower_email text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_counterparty_contact(p_reservation_id uuid, p_requester_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(counterparty_role text, counterparty_email text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_invoker_id uuid := coalesce(p_requester_id, auth.uid());
    v_reservation record;
    v_counterparty_role text;
    v_counterparty_email text;
begin
    if v_invoker_id is null then
        raise exception 'Authentication required to view contacts';
    end if;

    select * into v_reservation
    from reservations
    where id = p_reservation_id;

    if not found then
        raise exception 'Reservation not found';
    end if;

    if v_reservation.owner_id is distinct from v_invoker_id
       and v_reservation.borrower_id is distinct from v_invoker_id then
        raise exception 'User is not a party to the reservation';
    end if;

    if v_reservation.status not in ('borrower_confirmed', 'picked_up', 'returned') then
        raise exception 'Reservation is not in a state to reveal contacts';
    end if;

    if v_reservation.owner_id = v_invoker_id then
        v_counterparty_role := 'borrower';
        select email into v_counterparty_email from auth.users where id = v_reservation.borrower_id;
    else
        v_counterparty_role := 'owner';
        select email into v_counterparty_email from auth.users where id = v_reservation.owner_id;
    end if;

    if v_counterparty_email is null or length(trim(v_counterparty_email)) = 0 then
        raise exception 'Counterparty email unavailable';
    end if;

    insert into audit_log (actor_id, reservation_id, event_type, details)
    values (
        v_invoker_id,
        p_reservation_id,
        'contact_reveal',
        jsonb_build_object('reservation_id', p_reservation_id, 'counterparty_role', v_counterparty_role)
    );

    return query select v_counterparty_role, v_counterparty_email;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.guard_ratings_after_return()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_status reservation_status;
begin
  select status into v_status from public.reservations where id = new.reservation_id;
  if v_status <> 'returned' then
    raise exception 'ratings allowed only after reservation is returned';
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.guard_reservations_parties_immutable()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.owner_id is distinct from old.owner_id then
    raise exception 'owner_id cannot be changed';
  end if;
  if new.borrower_id is distinct from old.borrower_id then
    raise exception 'borrower_id cannot be changed';
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (id, username, is_complete)
  VALUES (new.id, new.email, TRUE);
  RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.nearby_tools(p_user_id uuid, p_limit integer, p_after jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id uuid, name text, distance_m real, main_image_url text, cursor_key jsonb)
 LANGUAGE plpgsql
AS $function$
declare
  v_user_location geography;
  v_last_distance real;
  v_last_id uuid;
  v_radius_m int := 50000; -- 50 km
begin
  -- 1) Get user's location
  select location_geog into v_user_location from public.profiles where profiles.id = p_user_id;
  if v_user_location is null then
    return;
  end if;

  -- 2) Decode cursor
  if p_after is not null then
    v_last_distance := (p_after->>'lastDistance')::real;
    v_last_id := (p_after->>'lastId')::uuid;
  end if;

  -- 3) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_user_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_user_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    left join
      public.tool_images ti on t.id = ti.tool_id and ti.position = 0
    where
      t.status = 'active'
      and t.owner_id <> p_user_id
      and st_dwithin(p.location_geog, v_user_location, v_radius_m)
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_user_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.nearby_tools(p_user_id uuid, p_limit integer, p_max_distance_m integer DEFAULT 50000, p_after jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id uuid, name text, distance_m real, main_image_url text, owner_name text, cursor_key jsonb)
 LANGUAGE plpgsql
AS $function$
declare
  v_user_location geography;
  v_last_distance real;
  v_last_id uuid;
  v_radius_m int := 50000; -- 50 km
begin
  -- 1) Get user's location
  select location_geog into v_user_location from public.profiles where profiles.id = p_user_id;
  if v_user_location is null then
    return;
  end if;

  -- 2) Decode cursor
  if p_after is not null then
    v_last_distance := (p_after->>'lastDistance')::real;
    v_last_id := (p_after->>'lastId')::uuid;
  end if;

  -- 3) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_user_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      p.username::text as owner_name,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_user_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    left join
      public.tool_images ti on t.id = ti.tool_id and ti.position = 0
    where
      t.status = 'active'
      and t.owner_id <> p_user_id
      and p.location_geog is not null
      and st_distance(p.location_geog, v_user_location) <= p_max_distance_m
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_user_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.public_nearby_tools(p_lon double precision, p_lat double precision, p_limit integer, p_max_distance_m integer DEFAULT 50000, p_after jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id uuid, name text, distance_m real, main_image_url text, owner_name text, cursor_key jsonb)
 LANGUAGE plpgsql
AS $function$
declare
  v_location geography;
  v_last_distance real;
  v_last_id uuid;
begin
  -- 1) Create a geography point from lon/lat
  v_location := st_makepoint(p_lon, p_lat)::geography;

  -- 2) Decode cursor
  if p_after is not null then
    v_last_distance := (p_after->>'lastDistance')::real;
    v_last_id := (p_after->>'lastId')::uuid;
  end if;

  -- 3) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      p.username::text as owner_name,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    where
      t.status = 'active'
      and p.location_geog is not null
      and st_distance(p.location_geog, v_location) <= p_max_distance_m
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.publish_tool(tool_id_to_publish uuid)
 RETURNS TABLE(id uuid, owner_id uuid, name text, description text, suggested_price_tokens integer, status public.tool_status, created_at timestamp with time zone, updated_at timestamp with time zone, archived_at timestamp with time zone, images jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

    -- Logowanie do audit_log
    INSERT INTO audit_log (user_id, action, details)
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
$function$
;

CREATE OR REPLACE FUNCTION public.raise_if_reservation_status_changed()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if tg_op = 'update' and new.status is distinct from old.status then
    if current_setting('app.allow_reservation_status_update', true) is distinct from 'true' then
      raise exception 'direct updates to reservations.status are not allowed; use reservation_transition()';
    end if;
  end if;
  return new;
end;
$function$
;

create materialized view "public"."rating_stats" as  SELECT rated_user_id,
    round(avg(stars), 2) AS avg_stars,
    (count(*))::integer AS ratings_count,
    now() AS refreshed_at
   FROM public.ratings
  GROUP BY rated_user_id;


CREATE OR REPLACE FUNCTION public.refresh_rating_stats()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    refresh materialized view concurrently public.rating_stats;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.reservation_transition(p_reservation_id uuid, p_new_status public.reservation_status, p_price_tokens smallint DEFAULT NULL::smallint, p_cancelled_reason text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_res reservations%rowtype;
  v_hold_id uuid;
  v_available integer;
begin
  -- guard: serialize on reservation id
  perform pg_advisory_xact_lock( ('x'||substr(replace(p_reservation_id::text, '-', ''),1,16))::bit(64)::bigint );

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
    values (v_res.borrower_id, v_res.id, 'hold', -1 * coalesce(v_res.agreed_price_tokens, 0), jsonb_build_object('reason','reservation_hold'))
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
    values (v_res.borrower_id, v_res.id, 'release', coalesce(v_res.agreed_price_tokens, 0), jsonb_build_object('for_hold', v_hold_id));
    -- transfer pair: debit borrower (negative), credit owner (positive)
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.borrower_id, v_res.id, 'transfer', -1 * coalesce(v_res.agreed_price_tokens, 0), jsonb_build_object('to', v_res.owner_id));
    insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
    values (v_res.owner_id, v_res.id, 'transfer', coalesce(v_res.agreed_price_tokens, 0), jsonb_build_object('from', v_res.borrower_id));
    update public.reservations set status = 'returned' where id = p_reservation_id;

  elsif p_new_status in ('cancelled','rejected') then
    -- if cancel from any pre-returned state, release any holds
    if v_res.status in ('requested', 'owner_accepted','borrower_confirmed','picked_up') then
      select id into v_hold_id from public.token_ledger where reservation_id = v_res.id and kind = 'hold' and user_id = v_res.borrower_id;
      if v_hold_id is not null then
        insert into public.token_ledger(user_id, reservation_id, kind, amount, details)
        values (v_res.borrower_id, v_res.id, 'release', coalesce(v_res.agreed_price_tokens,0), jsonb_build_object('for_hold', v_hold_id));
      end if;
    end if;
    update public.reservations set status = p_new_status, cancelled_reason = p_cancelled_reason where id = p_reservation_id;

  else
    raise exception 'invalid state transition from % to %', v_res.status, p_new_status;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.search_public_tools(p_search_query text DEFAULT NULL::text, p_category_slug text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, name text, description text, brand text, model text, "ownerId" uuid, "categoryId" uuid, "imageUrl" text, "imageUrls" text[], "isAvailable" boolean, location public.geography, "dailyPrice" numeric, "hourlyPrice" numeric, city text, category_name text, category_slug text, "ownerName" text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.name,
        t.description,
        t.brand,
        t.model,
        t."ownerId",
        t."categoryId",
        t."imageUrl",
        t."imageUrls",
        t."isAvailable",
        t.location,
        t."dailyPrice",
        t."hourlyPrice",
        p.city,
        null::text as category_name,
        null::text as category_slug,
        p.name as "ownerName"
    FROM
        tools t
    JOIN
        profiles p ON t."ownerId" = p.id
    WHERE
        t.archived = false AND
        p."isPublic" = true AND
        t."isAvailable" = true AND
        (p_search_query IS NULL OR t.name ILIKE '%' || p_search_query || '%' OR t.description ILIKE '%' || p_search_query || '%');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.search_tools(p_user_id uuid, p_q text, p_limit integer, p_after jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id uuid, name text, distance_m real, main_image_url text, owner_name text, cursor_key jsonb)
 LANGUAGE plpgsql
AS $function$
declare
  v_user_location geography;
  v_last_distance real;
  v_last_id uuid;
  v_text_query text;
begin
  -- 1) Get user's location
  select location_geog into v_user_location from public.profiles where profiles.id = p_user_id;
  if v_user_location is null then
    return;
  end if;

  -- 2) Decode cursor
  if p_after is not null then
    v_last_distance := (p_after->>'lastDistance')::real;
    v_last_id := (p_after->>'lastId')::uuid;
  end if;

  -- 3) Prepare queries
  v_text_query := '%' || p_q || '%';

  -- 4) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_user_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      p.username::text as owner_name,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_user_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    where
      t.status = 'active'
      and t.owner_id <> p_user_id
      and p.location_geog is not null
      and t.name ilike v_text_query
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_user_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.search_tools_with_images(p_user_id uuid, p_q text, p_limit integer, p_after jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id uuid, name text, distance_m real, main_image_storage_key text, cursor_key jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  v_geog public.geography;
  v_last_distance real := (p_after->>'lastDistance')::real;
  v_last_id uuid := (p_after->>'lastId')::uuid;
  v_ts_config regconfig;
begin
  if exists (select 1 from pg_ts_config where cfgname = 'polish') then
    v_ts_config := 'polish'::regconfig;
  else
    v_ts_config := 'simple'::regconfig;
  end if;

  select location_geog into v_geog from public.profiles where profiles.id = p_user_id;

  if v_geog is null then
    return;
  end if;

  return query
  with tools_with_distance as (
    select
      t.id,
      t.name,
      st_distance(t_owner.location_geog, v_geog)::real as distance_m
    from public.tools t
    join public.profiles t_owner on t.owner_id = t_owner.id
    where
      t.status = 'active'
      and t.owner_id <> p_user_id
      and t_owner.location_geog is not null
      and (p_q is null or p_q = '' or t.search_name_tsv @@ plainto_tsquery(v_ts_config, p_q))
  ),
  tools_with_images as (
    select
      twd.id,
      twd.name,
      twd.distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = twd.id and ti.position = 0 limit 1) as main_image_storage_key
    from tools_with_distance twd
  )
  select
    twi.id,
    twi.name,
    twi.distance_m,
    twi.main_image_storage_key,
    jsonb_build_object('lastDistance', twi.distance_m, 'lastId', twi.id) as cursor_key
  from tools_with_images twi
  where (v_last_distance is null or (twi.distance_m, twi.id) > (v_last_distance, v_last_id))
  order by twi.distance_m, twi.id
  limit p_limit;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at := now();
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tools_search_tsv_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.search_name_tsv := public.fts_polish_or_simple(new.name);
  return new;
end;
$function$
;

create or replace view "public"."public_profiles" as  SELECT p.id,
    p.username,
    p.location_text,
    rs.avg_stars,
    rs.ratings_count
   FROM (public.profiles p
     LEFT JOIN public.rating_stats rs ON ((rs.rated_user_id = p.id)));


CREATE INDEX idx_rating_stats_user ON public.rating_stats USING btree (rated_user_id);

grant delete on table "public"."audit_log" to "anon";

grant insert on table "public"."audit_log" to "anon";

grant references on table "public"."audit_log" to "anon";

grant select on table "public"."audit_log" to "anon";

grant trigger on table "public"."audit_log" to "anon";

grant truncate on table "public"."audit_log" to "anon";

grant update on table "public"."audit_log" to "anon";

grant delete on table "public"."audit_log" to "authenticated";

grant insert on table "public"."audit_log" to "authenticated";

grant references on table "public"."audit_log" to "authenticated";

grant select on table "public"."audit_log" to "authenticated";

grant trigger on table "public"."audit_log" to "authenticated";

grant truncate on table "public"."audit_log" to "authenticated";

grant update on table "public"."audit_log" to "authenticated";

grant delete on table "public"."audit_log" to "service_role";

grant insert on table "public"."audit_log" to "service_role";

grant references on table "public"."audit_log" to "service_role";

grant select on table "public"."audit_log" to "service_role";

grant trigger on table "public"."audit_log" to "service_role";

grant truncate on table "public"."audit_log" to "service_role";

grant update on table "public"."audit_log" to "service_role";

grant delete on table "public"."award_events" to "anon";

grant insert on table "public"."award_events" to "anon";

grant references on table "public"."award_events" to "anon";

grant select on table "public"."award_events" to "anon";

grant trigger on table "public"."award_events" to "anon";

grant truncate on table "public"."award_events" to "anon";

grant update on table "public"."award_events" to "anon";

grant delete on table "public"."award_events" to "authenticated";

grant insert on table "public"."award_events" to "authenticated";

grant references on table "public"."award_events" to "authenticated";

grant select on table "public"."award_events" to "authenticated";

grant trigger on table "public"."award_events" to "authenticated";

grant truncate on table "public"."award_events" to "authenticated";

grant update on table "public"."award_events" to "authenticated";

grant delete on table "public"."award_events" to "service_role";

grant insert on table "public"."award_events" to "service_role";

grant references on table "public"."award_events" to "service_role";

grant select on table "public"."award_events" to "service_role";

grant trigger on table "public"."award_events" to "service_role";

grant truncate on table "public"."award_events" to "service_role";

grant update on table "public"."award_events" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."ratings" to "anon";

grant insert on table "public"."ratings" to "anon";

grant references on table "public"."ratings" to "anon";

grant select on table "public"."ratings" to "anon";

grant trigger on table "public"."ratings" to "anon";

grant truncate on table "public"."ratings" to "anon";

grant update on table "public"."ratings" to "anon";

grant delete on table "public"."ratings" to "authenticated";

grant insert on table "public"."ratings" to "authenticated";

grant references on table "public"."ratings" to "authenticated";

grant select on table "public"."ratings" to "authenticated";

grant trigger on table "public"."ratings" to "authenticated";

grant truncate on table "public"."ratings" to "authenticated";

grant update on table "public"."ratings" to "authenticated";

grant delete on table "public"."ratings" to "service_role";

grant insert on table "public"."ratings" to "service_role";

grant references on table "public"."ratings" to "service_role";

grant select on table "public"."ratings" to "service_role";

grant trigger on table "public"."ratings" to "service_role";

grant truncate on table "public"."ratings" to "service_role";

grant update on table "public"."ratings" to "service_role";

grant delete on table "public"."rescue_claims" to "anon";

grant insert on table "public"."rescue_claims" to "anon";

grant references on table "public"."rescue_claims" to "anon";

grant select on table "public"."rescue_claims" to "anon";

grant trigger on table "public"."rescue_claims" to "anon";

grant truncate on table "public"."rescue_claims" to "anon";

grant update on table "public"."rescue_claims" to "anon";

grant delete on table "public"."rescue_claims" to "authenticated";

grant insert on table "public"."rescue_claims" to "authenticated";

grant references on table "public"."rescue_claims" to "authenticated";

grant select on table "public"."rescue_claims" to "authenticated";

grant trigger on table "public"."rescue_claims" to "authenticated";

grant truncate on table "public"."rescue_claims" to "authenticated";

grant update on table "public"."rescue_claims" to "authenticated";

grant delete on table "public"."rescue_claims" to "service_role";

grant insert on table "public"."rescue_claims" to "service_role";

grant references on table "public"."rescue_claims" to "service_role";

grant select on table "public"."rescue_claims" to "service_role";

grant trigger on table "public"."rescue_claims" to "service_role";

grant truncate on table "public"."rescue_claims" to "service_role";

grant update on table "public"."rescue_claims" to "service_role";

grant delete on table "public"."reservations" to "anon";

grant insert on table "public"."reservations" to "anon";

grant references on table "public"."reservations" to "anon";

grant select on table "public"."reservations" to "anon";

grant trigger on table "public"."reservations" to "anon";

grant truncate on table "public"."reservations" to "anon";

grant update on table "public"."reservations" to "anon";

grant delete on table "public"."reservations" to "authenticated";

grant insert on table "public"."reservations" to "authenticated";

grant references on table "public"."reservations" to "authenticated";

grant select on table "public"."reservations" to "authenticated";

grant trigger on table "public"."reservations" to "authenticated";

grant truncate on table "public"."reservations" to "authenticated";

grant update on table "public"."reservations" to "authenticated";

grant delete on table "public"."reservations" to "service_role";

grant insert on table "public"."reservations" to "service_role";

grant references on table "public"."reservations" to "service_role";

grant select on table "public"."reservations" to "service_role";

grant trigger on table "public"."reservations" to "service_role";

grant truncate on table "public"."reservations" to "service_role";

grant update on table "public"."reservations" to "service_role";

grant delete on table "public"."spatial_ref_sys" to "anon";

grant insert on table "public"."spatial_ref_sys" to "anon";

grant references on table "public"."spatial_ref_sys" to "anon";

grant select on table "public"."spatial_ref_sys" to "anon";

grant trigger on table "public"."spatial_ref_sys" to "anon";

grant truncate on table "public"."spatial_ref_sys" to "anon";

grant update on table "public"."spatial_ref_sys" to "anon";

grant delete on table "public"."spatial_ref_sys" to "authenticated";

grant insert on table "public"."spatial_ref_sys" to "authenticated";

grant references on table "public"."spatial_ref_sys" to "authenticated";

grant select on table "public"."spatial_ref_sys" to "authenticated";

grant trigger on table "public"."spatial_ref_sys" to "authenticated";

grant truncate on table "public"."spatial_ref_sys" to "authenticated";

grant update on table "public"."spatial_ref_sys" to "authenticated";

grant delete on table "public"."spatial_ref_sys" to "postgres";

grant insert on table "public"."spatial_ref_sys" to "postgres";

grant references on table "public"."spatial_ref_sys" to "postgres";

grant select on table "public"."spatial_ref_sys" to "postgres";

grant trigger on table "public"."spatial_ref_sys" to "postgres";

grant truncate on table "public"."spatial_ref_sys" to "postgres";

grant update on table "public"."spatial_ref_sys" to "postgres";

grant delete on table "public"."spatial_ref_sys" to "service_role";

grant insert on table "public"."spatial_ref_sys" to "service_role";

grant references on table "public"."spatial_ref_sys" to "service_role";

grant select on table "public"."spatial_ref_sys" to "service_role";

grant trigger on table "public"."spatial_ref_sys" to "service_role";

grant truncate on table "public"."spatial_ref_sys" to "service_role";

grant update on table "public"."spatial_ref_sys" to "service_role";

grant delete on table "public"."token_ledger" to "anon";

grant insert on table "public"."token_ledger" to "anon";

grant references on table "public"."token_ledger" to "anon";

grant select on table "public"."token_ledger" to "anon";

grant trigger on table "public"."token_ledger" to "anon";

grant truncate on table "public"."token_ledger" to "anon";

grant update on table "public"."token_ledger" to "anon";

grant delete on table "public"."token_ledger" to "authenticated";

grant insert on table "public"."token_ledger" to "authenticated";

grant references on table "public"."token_ledger" to "authenticated";

grant select on table "public"."token_ledger" to "authenticated";

grant trigger on table "public"."token_ledger" to "authenticated";

grant truncate on table "public"."token_ledger" to "authenticated";

grant update on table "public"."token_ledger" to "authenticated";

grant delete on table "public"."token_ledger" to "service_role";

grant insert on table "public"."token_ledger" to "service_role";

grant references on table "public"."token_ledger" to "service_role";

grant select on table "public"."token_ledger" to "service_role";

grant trigger on table "public"."token_ledger" to "service_role";

grant truncate on table "public"."token_ledger" to "service_role";

grant update on table "public"."token_ledger" to "service_role";

grant delete on table "public"."tool_images" to "anon";

grant insert on table "public"."tool_images" to "anon";

grant references on table "public"."tool_images" to "anon";

grant select on table "public"."tool_images" to "anon";

grant trigger on table "public"."tool_images" to "anon";

grant truncate on table "public"."tool_images" to "anon";

grant update on table "public"."tool_images" to "anon";

grant delete on table "public"."tool_images" to "authenticated";

grant insert on table "public"."tool_images" to "authenticated";

grant references on table "public"."tool_images" to "authenticated";

grant select on table "public"."tool_images" to "authenticated";

grant trigger on table "public"."tool_images" to "authenticated";

grant truncate on table "public"."tool_images" to "authenticated";

grant update on table "public"."tool_images" to "authenticated";

grant delete on table "public"."tool_images" to "service_role";

grant insert on table "public"."tool_images" to "service_role";

grant references on table "public"."tool_images" to "service_role";

grant select on table "public"."tool_images" to "service_role";

grant trigger on table "public"."tool_images" to "service_role";

grant truncate on table "public"."tool_images" to "service_role";

grant update on table "public"."tool_images" to "service_role";

grant delete on table "public"."tools" to "anon";

grant insert on table "public"."tools" to "anon";

grant references on table "public"."tools" to "anon";

grant select on table "public"."tools" to "anon";

grant trigger on table "public"."tools" to "anon";

grant truncate on table "public"."tools" to "anon";

grant update on table "public"."tools" to "anon";

grant delete on table "public"."tools" to "authenticated";

grant insert on table "public"."tools" to "authenticated";

grant references on table "public"."tools" to "authenticated";

grant select on table "public"."tools" to "authenticated";

grant trigger on table "public"."tools" to "authenticated";

grant truncate on table "public"."tools" to "authenticated";

grant update on table "public"."tools" to "authenticated";

grant delete on table "public"."tools" to "service_role";

grant insert on table "public"."tools" to "service_role";

grant references on table "public"."tools" to "service_role";

grant select on table "public"."tools" to "service_role";

grant trigger on table "public"."tools" to "service_role";

grant truncate on table "public"."tools" to "service_role";

grant update on table "public"."tools" to "service_role";


  create policy "audit_log_select_anon"
  on "public"."audit_log"
  as permissive
  for select
  to anon
using (false);



  create policy "audit_log_select_auth"
  on "public"."audit_log"
  as permissive
  for select
  to authenticated
using ((actor_id = auth.uid()));



  create policy "award_events_select_anon"
  on "public"."award_events"
  as permissive
  for select
  to anon
using (false);



  create policy "award_events_select_auth"
  on "public"."award_events"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "profiles_ins_auth"
  on "public"."profiles"
  as permissive
  for insert
  to authenticated
with check ((id = auth.uid()));



  create policy "profiles_select_anon"
  on "public"."profiles"
  as permissive
  for select
  to anon
using (false);



  create policy "profiles_select_auth"
  on "public"."profiles"
  as permissive
  for select
  to authenticated
using ((id = auth.uid()));



  create policy "profiles_upd_auth"
  on "public"."profiles"
  as permissive
  for update
  to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));



  create policy "ratings_insert_auth"
  on "public"."ratings"
  as permissive
  for insert
  to authenticated
with check ((rater_id = auth.uid()));



  create policy "ratings_select_anon"
  on "public"."ratings"
  as permissive
  for select
  to anon
using (false);



  create policy "ratings_select_auth"
  on "public"."ratings"
  as permissive
  for select
  to authenticated
using (((rater_id = auth.uid()) OR (rated_user_id = auth.uid())));



  create policy "rescue_claims_select_anon"
  on "public"."rescue_claims"
  as permissive
  for select
  to anon
using (false);



  create policy "rescue_claims_select_auth"
  on "public"."rescue_claims"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "reservations_insert_auth"
  on "public"."reservations"
  as permissive
  for insert
  to authenticated
with check ((borrower_id = auth.uid()));



  create policy "reservations_select_anon"
  on "public"."reservations"
  as permissive
  for select
  to anon
using (false);



  create policy "reservations_select_auth"
  on "public"."reservations"
  as permissive
  for select
  to authenticated
using (((owner_id = auth.uid()) OR (borrower_id = auth.uid())));



  create policy "reservations_update_auth"
  on "public"."reservations"
  as permissive
  for update
  to authenticated
using (((owner_id = auth.uid()) OR (borrower_id = auth.uid())))
with check (true);



  create policy "token_ledger_select_anon"
  on "public"."token_ledger"
  as permissive
  for select
  to anon
using (false);



  create policy "token_ledger_select_auth"
  on "public"."token_ledger"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "tool_images_cud_auth"
  on "public"."tool_images"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.tools t
  WHERE ((t.id = tool_images.tool_id) AND (t.owner_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.tools t
  WHERE ((t.id = tool_images.tool_id) AND (t.owner_id = auth.uid())))));



  create policy "tool_images_select_anon"
  on "public"."tool_images"
  as permissive
  for select
  to anon
using ((EXISTS ( SELECT 1
   FROM public.tools t
  WHERE ((t.id = tool_images.tool_id) AND (t.status = 'active'::public.tool_status)))));



  create policy "tool_images_select_auth"
  on "public"."tool_images"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.tools t
  WHERE ((t.id = tool_images.tool_id) AND ((t.status = 'active'::public.tool_status) OR (t.owner_id = auth.uid()))))));



  create policy "tools_del_auth"
  on "public"."tools"
  as permissive
  for delete
  to authenticated
using ((owner_id = auth.uid()));



  create policy "tools_ins_auth"
  on "public"."tools"
  as permissive
  for insert
  to authenticated
with check ((owner_id = auth.uid()));



  create policy "tools_select_anon"
  on "public"."tools"
  as permissive
  for select
  to anon
using ((status = 'active'::public.tool_status));



  create policy "tools_select_auth"
  on "public"."tools"
  as permissive
  for select
  to authenticated
using (((status = 'active'::public.tool_status) OR (owner_id = auth.uid())));



  create policy "tools_upd_auth"
  on "public"."tools"
  as permissive
  for update
  to authenticated
using ((owner_id = auth.uid()))
with check ((owner_id = auth.uid()));


CREATE TRIGGER set_timestamp_profiles BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE TRIGGER ratings_after_return_guard BEFORE INSERT ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.guard_ratings_after_return();

CREATE TRIGGER reservations_owner_consistency BEFORE INSERT OR UPDATE OF tool_id, owner_id ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.ensure_reservation_owner_consistency();

CREATE TRIGGER reservations_parties_immutable BEFORE UPDATE OF owner_id, borrower_id ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.guard_reservations_parties_immutable();

CREATE TRIGGER reservations_prevent_direct_status BEFORE UPDATE OF status ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.raise_if_reservation_status_changed();

CREATE TRIGGER set_timestamp_reservations BEFORE UPDATE ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE TRIGGER token_ledger_block_delete BEFORE DELETE ON public.token_ledger FOR EACH ROW EXECUTE FUNCTION public.block_update_delete();

CREATE TRIGGER token_ledger_block_update BEFORE UPDATE ON public.token_ledger FOR EACH ROW EXECUTE FUNCTION public.block_update_delete();

CREATE TRIGGER set_timestamp_tools BEFORE UPDATE ON public.tools FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE TRIGGER tools_search_tsv BEFORE INSERT OR UPDATE OF name ON public.tools FOR EACH ROW EXECUTE FUNCTION public.tools_search_tsv_trigger();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


  create policy "Allow authenticated uploads to tool_images"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'tool_images'::text));



  create policy "Allow public uploads to tool_images"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'tool_images'::text));



