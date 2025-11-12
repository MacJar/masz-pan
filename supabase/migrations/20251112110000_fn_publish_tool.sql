CREATE OR REPLACE FUNCTION publish_tool(tool_id_to_publish UUID)
RETURNS TABLE (
  id UUID,
  owner_id UUID,
  name TEXT,
  description TEXT,
  suggested_price_tokens INT,
  status tool_status,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  images jsonb
)
SECURITY DEFINER
AS $$
DECLARE
    tool_owner_id UUID;
    current_tool_status tool_status;
    image_count INT;
    updated_tool RECORD;
BEGIN
    -- Sprawdzenie, czy narzędzie istnieje i pobranie jego właściciela oraz statusu
    SELECT tools.owner_id, tools.status INTO tool_owner_id, current_tool_status
    FROM tools
    WHERE tools.id = tool_id_to_publish;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tool not found' USING ERRCODE = 'PGRST001'; -- Not Found
    END IF;

    -- Sprawdzenie, czy bieżący użytkownik jest właścicielem narzędzia
    IF tool_owner_id != auth.uid() THEN
        RAISE EXCEPTION 'Forbidden' USING ERRCODE = 'PGRST002'; -- Forbidden
    END IF;

    -- Sprawdzenie, czy status narzędzia to 'draft'
    IF current_tool_status != 'draft' THEN
        RAISE EXCEPTION 'Tool is not a draft' USING ERRCODE = 'PGRST003'; -- Unprocessable Entity
    END IF;

    -- Sprawdzenie, czy narzędzie ma co najmniej jedno zdjęcie
    SELECT count(*) INTO image_count
    FROM tool_images
    WHERE tool_images.tool_id = tool_id_to_publish;

    IF image_count = 0 THEN
        RAISE EXCEPTION 'Tool has no images' USING ERRCODE = 'PGRST004'; -- Conflict
    END IF;

    -- Aktualizacja statusu narzędzia
    UPDATE tools
    SET status = 'active', updated_at = now()
    WHERE tools.id = tool_id_to_publish;

    -- Logowanie do audit_log
    INSERT INTO audit_log (user_id, action, details)
    VALUES (auth.uid(), 'publish_tool', jsonb_build_object('tool_id', tool_id_to_publish));
    
    -- Zwrócenie zaktualizowanego narzędzia z obrazkami
    RETURN QUERY
    SELECT
        t.id,
        t.owner_id,
        t.name,
        t.description,
        t.suggested_price_tokens,
        t.status,
        t.created_at,
        t.updated_at,
        t.archived_at,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', ti.id,
                    'path', ti.path,
                    'bucket', ti.bucket,
                    'created_at', ti.created_at
                )
            )
            FROM tool_images ti
            WHERE ti.tool_id = t.id
        ) as images
    FROM
        tools t
    WHERE
        t.id = tool_id_to_publish;

END;
$$ LANGUAGE plpgsql;
