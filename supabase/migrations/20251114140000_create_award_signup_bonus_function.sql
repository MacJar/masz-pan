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
  insert into token_ledger (user_id, credit, description)
  values (p_user_id, bonus_amount, 'Signup bonus award');

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

