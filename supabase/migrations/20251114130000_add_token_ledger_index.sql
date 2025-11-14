CREATE INDEX IF NOT EXISTS idx_token_ledger_user_kind_created_at_id ON public.token_ledger (user_id, kind, created_at DESC, id DESC);
