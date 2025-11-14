-- migration: add composite indexes to reservations table
-- purpose: improve performance of cursor-based pagination for listing user reservations
-- affected: public.reservations table indexes

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reservations_owner_created_at_id ON public.reservations (owner_id, created_at DESC, id DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reservations_borrower_created_at_id ON public.reservations (borrower_id, created_at DESC, id DESC);
