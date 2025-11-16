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

  -- 5. Wstaw nowy rekord `credit` do token_ledger
  insert into token_ledger(user_id, amount, kind, description) values (p_user_id, bonus_amount, 'credit', 'Bonus for listing a new tool: ' || p_tool_id);
  
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

