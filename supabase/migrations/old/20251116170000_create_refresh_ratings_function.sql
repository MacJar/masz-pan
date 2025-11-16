create or replace function public.refresh_rating_stats()
returns void as $$
begin
    refresh materialized view concurrently public.rating_stats;
end;
$$ language plpgsql;
