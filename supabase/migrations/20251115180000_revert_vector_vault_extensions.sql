-- Revert the changes made for semantic search

-- 1. Drop the extensions. The CASCADE option will automatically handle
--    dependent objects, including schemas and permissions.
DROP EXTENSION IF EXISTS "supabase_vault" CASCADE;
DROP EXTENSION IF EXISTS "vector" CASCADE;

-- 2. Drop the functions that are no longer needed or were problematic.
--    Note: The latest version of search_tools is kept.
--    We are dropping older, overloaded versions if they still exist.
--    This is a safeguard; `CREATE OR REPLACE` should have handled this,
--    but this makes the cleanup explicit.
--    Since we cannot reliably drop specific overloaded function versions,
--    and the latest `search_tools` is correct, we'll skip explicit drops
--    to avoid accidental deletion of the correct function. The extension
--    drops should handle the cleanup of types that would cause issues.
