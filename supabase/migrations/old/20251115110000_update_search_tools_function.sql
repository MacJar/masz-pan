create or replace function search_tools(
  p_user_id uuid,
  p_q text,
  p_limit int,
  p_after jsonb default null
)
returns table (
  id uuid,
  name text,
  distance_m real,
  main_image_storage_key text,
  cursor_key jsonb
)
language plpgsql
as $$
declare
  v_user_location geography;
  v_last_distance real;
  v_last_id uuid;
  v_query_embedding extensions.vector;
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

  -- 3) Get embedding for the query
  select extensions.openai_embedding_create(
    api_key := secrets.get_secret('openai_api_key'),
    input := p_q
  ) into v_query_embedding;

  -- 4) Query for tools
  return query
    select
      t.id,
      t.name,
      st_distance(p.location_geog, v_user_location)::real as distance_m,
      ti.storage_key as main_image_storage_key,
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
      and t.embedding <=> v_query_embedding < 0.8 -- Similarity threshold
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
