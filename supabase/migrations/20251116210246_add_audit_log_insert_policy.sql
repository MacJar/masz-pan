-- Dodaj politykę RLS INSERT dla tabeli audit_log
-- Pozwala authenticated użytkownikom zapisywać zdarzenia audytowe
-- gdzie actor_id jest ich własnym ID lub null (dla zdarzeń systemowych)

-- Upewnij się, że RLS jest włączone
ALTER TABLE IF EXISTS "public"."audit_log" ENABLE ROW LEVEL SECURITY;

-- Polityka INSERT dla authenticated użytkowników
-- Pozwala zapisywać zdarzenia gdzie actor_id = auth.uid() lub actor_id IS NULL
CREATE POLICY "audit_log_insert_auth"
ON "public"."audit_log"
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK (
  actor_id = auth.uid() OR actor_id IS NULL
);

