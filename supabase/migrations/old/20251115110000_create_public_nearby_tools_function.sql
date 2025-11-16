create or replace function public_nearby_tools(
  p_lon float,
  p_lat float,
  p_limit int,
  p_max_distance_m int default 50000,
  p_after jsonb default null
)
returns table (
  id uuid,
  name text,
  distance_m real,
  main_image_url text,
  cursor_key jsonb
)
language plpgsql
as $$
declare
  v_location geography;
  v_last_distance real;
  v_last_id uuid;
begin
  -- 1) Create a geography point from lon/lat
  v_location := st_makepoint(p_lon, p_lat)::geography;

  -- 2) Decode cursor
  if p_after is not null then
    v_last_distance := (p_after->>'lastDistance')::real;
    v_last_id := (p_after->>'lastId')::uuid;
  end if;

  -- 3) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    where
      t.status = 'active'
      and p.location_geog is not null
      and st_distance(p.location_geog, v_location) <= p_max_distance_m
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$$;
