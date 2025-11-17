-- Naprawa odświeżania widoku materializowanego rating_stats
-- Problem: widok nie był automatycznie odświeżany po dodaniu ocen

-- 1. Utworzenie unikalnego indeksu na rated_user_id (wymagane dla CONCURRENTLY)
--    Ponieważ widok jest grupowany po rated_user_id, każdy rated_user_id jest unikalny
DROP INDEX IF EXISTS public.idx_rating_stats_user_unique;
CREATE UNIQUE INDEX idx_rating_stats_user_unique 
    ON public.rating_stats (rated_user_id);

-- 2. Zmiana funkcji refresh_rating_stats na SECURITY DEFINER
--    aby miała uprawnienia do odświeżenia widoku materializowanego
CREATE OR REPLACE FUNCTION public.refresh_rating_stats()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
    refresh materialized view concurrently public.rating_stats;
end;
$function$;

-- 3. Nadanie uprawnień do wywołania funkcji dla authenticated users
GRANT EXECUTE ON FUNCTION public.refresh_rating_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.refresh_rating_stats() TO service_role;

-- 4. Utworzenie funkcji triggerowej która odświeża widok po zmianie ocen
CREATE OR REPLACE FUNCTION public.trigger_refresh_rating_stats()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
    -- Odświeżamy widok materializowany po każdej zmianie w tabeli ratings
    -- Używamy zwykłego REFRESH (bez CONCURRENTLY) ponieważ:
    -- 1. CONCURRENTLY nie może być użyte w triggerze (wymaga braku transakcji modyfikujących)
    -- 2. Odświeżenie jest szybkie (to tylko agregacja)
    -- 3. Blokada będzie krótka i nie powinna wpłynąć na wydajność
    refresh materialized view public.rating_stats;
    
    return coalesce(new, old);
end;
$function$;

-- 5. Dodanie triggerów które automatycznie odświeżają widok po zmianie ocen
DROP TRIGGER IF EXISTS ratings_refresh_stats_after_insert ON public.ratings;
CREATE TRIGGER ratings_refresh_stats_after_insert
    AFTER INSERT ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_refresh_rating_stats();

DROP TRIGGER IF EXISTS ratings_refresh_stats_after_update ON public.ratings;
CREATE TRIGGER ratings_refresh_stats_after_update
    AFTER UPDATE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_refresh_rating_stats();

DROP TRIGGER IF EXISTS ratings_refresh_stats_after_delete ON public.ratings;
CREATE TRIGGER ratings_refresh_stats_after_delete
    AFTER DELETE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_refresh_rating_stats();

-- 6. Początkowe odświeżenie widoku aby upewnić się, że dane są aktualne
REFRESH MATERIALIZED VIEW CONCURRENTLY public.rating_stats;

