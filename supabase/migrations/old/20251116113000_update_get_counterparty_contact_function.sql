-- Update get_counterparty_contact to support explicit requester context
-- while still defaulting to auth.uid() when available.
-- This allows privileged server routes (with middleware-authenticated users)
-- to pass the requester ID directly, ensuring consistent authorization checks.
create or replace function public.get_counterparty_contact (
  p_reservation_id uuid,
  p_requester_id uuid default null
)
returns table (
  owner_email text,
  borrower_email text
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_invoker_id uuid := coalesce(p_requester_id, auth.uid());
    v_reservation record;
    v_owner_email text;
    v_borrower_email text;
begin
    if v_invoker_id is null then
        raise exception 'Authentication required to view contacts';
    end if;

    -- Fetch reservation
    select * into v_reservation
    from reservations
    where id = p_reservation_id;

    if not found then
        raise exception 'Reservation not found';
    end if;

    -- Ensure requester is part of reservation
    if v_reservation.owner_id is distinct from v_invoker_id
       and v_reservation.borrower_id is distinct from v_invoker_id then
        raise exception 'User is not a party to the reservation';
    end if;

    -- Ensure reservation state allows contact sharing
    if v_reservation.status not in ('borrower_confirmed', 'picked_up', 'returned') then
        raise exception 'Reservation is not in a state to reveal contacts';
    end if;

    -- Log audit event
    insert into audit_log (user_id, event_type, details)
    values (v_invoker_id, 'contact_reveal', jsonb_build_object('reservation_id', p_reservation_id));

    -- Fetch emails from auth.users metadata
    select
        (select raw_user_meta_data->>'email' from auth.users where id = v_reservation.owner_id),
        (select raw_user_meta_data->>'email' from auth.users where id = v_reservation.borrower_id)
    into v_owner_email, v_borrower_email;

    return query select v_owner_email, v_borrower_email;
end;
$$;

