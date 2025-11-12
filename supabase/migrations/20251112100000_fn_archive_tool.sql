
-- supabase/migrations/20251112100000_fn_archive_tool.sql

-- Disable realtime logging for this migration
ALTER PUBLICATION supabase_realtime SET (publish = 'insert,update,delete');

-- 1. Create the function
CREATE OR REPLACE FUNCTION archive_tool(p_tool_id UUID, p_user_id UUID)
RETURNS TABLE (
  success BOOLEAN,
  code TEXT,
  message TEXT,
  http_status INT,
  archived_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tool_owner_id UUID;
  v_has_active_reservations BOOLEAN;
  v_current_timestamp TIMESTAMPTZ := now();
BEGIN
  -- Authorization check should be done in RLS policies or application layer before calling this.
  -- We just fetch the owner_id to be sure.
  SELECT owner_id INTO v_tool_owner_id FROM public.tools WHERE id = p_tool_id;

  IF v_tool_owner_id != p_user_id THEN
    RETURN QUERY SELECT false, 'FORBIDDEN', 'User is not the owner of the tool.', 403, null::timestamptz;
    RETURN;
  END IF;

  -- Check for active reservations
  SELECT EXISTS (
    SELECT 1
    FROM public.reservations
    WHERE tool_id = p_tool_id
      AND status IN ('requested', 'owner_accepted', 'borrower_confirmed', 'picked_up')
  ) INTO v_has_active_reservations;

  IF v_has_active_reservations THEN
    RETURN QUERY SELECT false, 'TOOL_HAS_ACTIVE_RESERVATIONS', 'Tool has active reservations and cannot be archived.', 409, null::timestamptz;
    RETURN;
  END IF;

  -- Update the tool
  UPDATE public.tools
  SET
    status = 'archived',
    archived_at = v_current_timestamp
  WHERE id = p_tool_id;

  -- Insert into audit log
  INSERT INTO public.audit_log (user_id, event_type, details)
  VALUES (p_user_id, 'tool_archived', jsonb_build_object('tool_id', p_tool_id));

  -- Return success
  RETURN QUERY SELECT true, 'OK', 'Tool archived successfully.', 200, v_current_timestamp;

END;
$$;

-- 2. Enable RLS for the function (if not already covered by table policies)
-- Note: Assuming RLS is enabled on the `tools` and `reservations` tables.

-- 3. Grant execute permission to the 'authenticated' role
GRANT EXECUTE ON FUNCTION public.archive_tool(UUID, UUID) TO authenticated;

-- Re-enable realtime logging
ALTER PUBLICATION supabase_realtime SET (publish = 'insert,update,delete,truncate');
