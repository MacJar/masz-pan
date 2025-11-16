-- Ensure get_counterparty_contact writes to the correct audit_log columns.
-- Previous version attempted to insert into user_id, but the table uses actor_id.
create or replace function public.get_counterparty_contact (
  p_reservation_id uuid,
  p_requester_id uuid default null
)
returns table (
  counterparty_role text,
  counterparty_email text
)
language plpgsql
security definer
set search_path = public
as $$
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
$$;


