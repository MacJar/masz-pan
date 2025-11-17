-- Upewnij się, że PostGIS jest zainstalowane
-- W Supabase Cloud rozszerzenia mogą być już zainstalowane przez administratora
-- Próbujemy zainstalować w schemacie public, ale jeśli nie mamy uprawnień,
-- zakładamy że PostGIS jest już zainstalowane przez Supabase
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
    BEGIN
      CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    EXCEPTION WHEN OTHERS THEN
      -- Jeśli nie mamy uprawnień do instalacji, zakładamy że PostGIS jest już zainstalowane
      -- przez Supabase w schemacie extensions lub public
      RAISE NOTICE 'PostGIS extension installation failed, assuming it is already installed by Supabase';
    END;
  END IF;
END $$;

-- Funkcja RPC do ustawienia location_geog używając PostGIS
-- Używana do ustawienia domyślnej geolokalizacji dla użytkowników
-- Używa dynamicznego SQL, aby uniknąć błędów kompilacji, gdy PostGIS nie jest dostępne
CREATE OR REPLACE FUNCTION public.set_profile_location_geog(
  p_user_id uuid,
  p_lon double precision,
  p_lat double precision
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_sql text;
BEGIN
  -- Sprawdź czy PostGIS jest dostępne
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
    -- Użyj dynamicznego SQL, aby uniknąć błędów kompilacji
    v_sql := format(
      'UPDATE public.profiles SET location_geog = ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography WHERE id = %L',
      p_lon, p_lat, p_user_id
    );
    EXECUTE v_sql;
  ELSE
    -- Jeśli PostGIS nie jest dostępne, po prostu nie ustawiamy location_geog
    -- Aplikacja powinna obsłużyć ten przypadek
    RAISE NOTICE 'PostGIS extension is not available, skipping location_geog update';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_profile_location_geog(uuid, double precision, double precision) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_profile_location_geog(uuid, double precision, double precision) TO service_role;

-- Aktualizacja funkcji handle_new_user() aby ustawiała domyślne wartości
-- Uwaga: location_geog nie jest ustawiane tutaj, ponieważ wymaga PostGIS
-- location_geog zostanie ustawione później przez funkcję RPC set_profile_location_geog
-- wywoływaną z aplikacji (np. w profile.service.ts)
-- Domyślny kod pocztowy: 00-950 (Warszawa)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  default_postal_code text := '00-950';
BEGIN
  INSERT INTO public.profiles (id, username, is_complete, location_text)
  VALUES (
    new.id, 
    new.email, 
    TRUE,
    default_postal_code
  );
  RETURN new;
END;
$$;

-- Ustawienie domyślnych wartości dla istniejących użytkowników bez location_text
-- Uwaga: location_geog nie jest ustawiane tutaj, ponieważ wymaga PostGIS
-- location_geog zostanie ustawione później przez funkcję RPC set_profile_location_geog
-- Domyślny kod pocztowy: 00-950 (Warszawa)
UPDATE public.profiles
SET location_text = COALESCE(location_text, '00-950')
WHERE location_text IS NULL;

