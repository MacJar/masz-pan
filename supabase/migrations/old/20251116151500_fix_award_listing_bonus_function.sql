-- fix broken award_listing_bonus function that referenced non-existent "description" column
-- recreate canonical version with jsonb details and deterministic bonus amount

drop function if exists public.award_listing_bonus(p_user_id uuid, p_tool_id uuid);

create or replace function public.award_listing_bonus(
  p_user_id uuid,
  p_tool_id uuid,
  p_amount integer default 2
)
returns void
language plpgsql
security definer
set search_path = public
as $$
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
$$;

