-- migration: fix ledger kind in claim_rescue_token
-- purpose: change the ledger entry kind from 'credit' to 'award' to align with the design
--          for rescue token claims. this ensures consistency with other award types.
-- affected: function public.claim_rescue_token

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

