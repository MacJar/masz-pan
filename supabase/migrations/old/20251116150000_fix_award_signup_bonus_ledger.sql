-- fix: ensure awarding signup bonus creates a proper ledger entry
-- drops legacy overload and recreates the canonical function with ledger insert

drop function if exists public.award_signup_bonus(p_user_id uuid);

create or replace function public.award_signup_bonus(
  p_user_id uuid,
  p_amount integer default 10
)
returns void
language plpgsql
security definer
set search_path = public
as $$
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
$$;

