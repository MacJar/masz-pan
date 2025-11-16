drop function if exists public.reservation_transition(uuid, public.reservation_status, smallint);

create or replace function public.reservation_transition(p_reservation_id uuid, p_new_status reservation_status, p_price_tokens smallint default null, p_cancelled_reason text default null)
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
$$;
