create or replace function nearby_tools(
  p_user_id uuid,
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
  v_user_location geography;
  v_last_distance real;
  v_last_id uuid;
  v_radius_m int := 50000; -- 50 km
begin
  -- 1) Get user's location
  select location_geog into v_user_location from public.profiles where profiles.id = p_user_id;
  if v_user_location is null then
    return;
  end if;

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
      st_distance(p.location_geog, v_user_location)::real as distance_m,
      (select ti.storage_key from public.tool_images ti where ti.tool_id = t.id order by ti.position asc limit 1) as main_image_url,
      jsonb_build_object('lastDistance', st_distance(p.location_geog, v_user_location), 'lastId', t.id) as cursor_key
    from
      public.tools t
    join
      public.profiles p on t.owner_id = p.id
    left join
      public.tool_images ti on t.id = ti.tool_id and ti.position = 0
    where
      t.status = 'active'
      and t.owner_id <> p_user_id
      and p.location_geog is not null
      and st_distance(p.location_geog, v_user_location) <= p_max_distance_m
      and (
        v_last_distance is null or
        (st_distance(p.location_geog, v_user_location), t.id) > (v_last_distance, v_last_id)
      )
    order by
      distance_m,
      t.id
    limit
      p_limit;
end;
$$;
