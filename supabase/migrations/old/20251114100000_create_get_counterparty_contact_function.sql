-- This function securely retrieves contact emails for a reservation.
-- It enforces that the caller must be a party to the reservation
-- and that the reservation must be in an appropriate state.
-- It also logs the access attempt in the audit_log table.
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
