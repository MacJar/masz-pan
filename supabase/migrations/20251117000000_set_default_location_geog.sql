-- Funkcja RPC do ustawienia location_geog używając PostGIS
-- Używana do ustawienia domyślnej geolokalizacji dla użytkowników
CREATE OR REPLACE FUNCTION public.set_profile_location_geog(
  p_user_id uuid,
  p_lon double precision,
  p_lat double precision
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.profiles
  SET location_geog = ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326)::geography
  WHERE id = p_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_profile_location_geog(uuid, double precision, double precision) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_profile_location_geog(uuid, double precision, double precision) TO service_role;

-- Aktualizacja funkcji handle_new_user() aby ustawiała domyślne wartości geolokalizacji
-- Domyślny kod pocztowy: 00-950 (Warszawa)
-- Domyślne współrzędne: lon: 21.012229, lat: 52.229676
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  default_postal_code text := '00-950';
  default_lon double precision := 21.012229;
  default_lat double precision := 52.229676;
BEGIN
  INSERT INTO public.profiles (id, username, is_complete, location_text, location_geog)
  VALUES (
    new.id, 
    new.email, 
    TRUE,
    default_postal_code,
    ST_SetSRID(ST_MakePoint(default_lon, default_lat), 4326)::geography
  );
  RETURN new;
END;
$$;

-- Ustawienie domyślnych wartości dla istniejących użytkowników bez geolokalizacji
-- Domyślny kod pocztowy: 00-950 (Warszawa)
-- Domyślne współrzędne: lon: 21.012229, lat: 52.229676
UPDATE public.profiles
SET 
  location_text = COALESCE(location_text, '00-950'),
  location_geog = COALESCE(
    location_geog,
    ST_SetSRID(ST_MakePoint(21.012229, 52.229676), 4326)::geography
  )
WHERE location_geog IS NULL;

