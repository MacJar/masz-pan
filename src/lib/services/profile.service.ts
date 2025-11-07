import type { SupabaseClient } from "../../db/supabase.client.ts";
import { createServiceClient } from "../../db/supabase.client.ts";
import type { ProfileDTO } from "../../types.ts";
import type { Database, Json } from "../../db/database.types.ts";

const NOT_FOUND_ERROR_CODE = "PGRST116";

/**
 * Error raised when authentication metadata cannot be retrieved from Supabase.
 */
export class SupabaseAuthError extends Error {
  readonly cause?: unknown;

  constructor(message: string, cause?: unknown) {
    super(message);
    this.name = "SupabaseAuthError";
    this.cause = cause;
  }
}

/**
 * Error raised when a Supabase query fails or returns an unexpected shape.
 */
export class SupabaseQueryError extends Error {
  readonly cause?: unknown;
  readonly code?: string;

  constructor(message: string, code?: string, cause?: unknown) {
    super(message);
    this.name = "SupabaseQueryError";
    this.code = code;
    this.cause = cause;
  }
}

/**
 * Returns the authenticated user id or null when the request is unauthenticated.
 *
 * @throws {SupabaseAuthError} When the user metadata call fails.
 */
export async function getAuthenticatedUserId(supabase: SupabaseClient): Promise<string | null> {
  // TODO: Remove this when we have a proper auth system
  if (import.meta.env.AUTH_BYPASS === "true") {
    const mockUserId = import.meta.env.AUTH_BYPASS_USER_ID ?? "00000000-0000-0000-0000-000000000000";
    return mockUserId;
  }
  const { data, error } = await supabase.auth.getUser();
  if (error) {
    throw new SupabaseAuthError("Failed to retrieve authenticated user.", error);
  }
  const userId = data?.user?.id;
  if (!userId) {
    return null;
  }
  return userId;
}

/**
 * Fetches the profile associated with the provided user identifier.
 *
 * @returns The profile row or null when missing.
 * @throws {SupabaseQueryError} When Supabase returns an error other than not found.
 */
export async function fetchProfileById(supabase: SupabaseClient, userId: string): Promise<ProfileDTO | null> {
  const { data, error } = await supabase.from("profiles").select("*").eq("id", userId).limit(1).single();

  if (error) {
    if (error.code === NOT_FOUND_ERROR_CODE) {
      return null;
    }

    throw new SupabaseQueryError("Failed to fetch profile.", error.code, error);
  }

  if (!data) {
    return null;
  }

  return data;
}

/**
 * Attempts to persist an audit event. Failures are swallowed to keep the caller's
 * control flow unaffected (e.g. when RLS denies access).
 */
export async function logAuditEvent(
  supabase: SupabaseClient,
  eventType: string,
  actorId: string | null,
  details?: Json,
  reservationId?: string | null
): Promise<void> {
  const payload: Database["public"]["Tables"]["audit_log"]["Insert"] = {
    event_type: eventType,
    actor_id: actorId,
    reservation_id: reservationId ?? null,
  };

  if (typeof details !== "undefined") {
    payload.details = details;
  }

  // TODO: Remove this when we have a proper auth system
  // Prefer service-role client (bypasses RLS safely on server)
  const serviceClient = createServiceClient();
  if (serviceClient) {
    const { error } = await serviceClient.from("audit_log").insert(payload);
    if (error && import.meta.env.DEV) {
      // eslint-disable-next-line no-console -- server-side diagnostic only in development
      console.warn("Failed to write audit event (service)", { eventType, error });
    }
    return;
  }

  // In bypass mode without service key: skip audit writes to avoid noisy RLS errors
  if (import.meta.env.AUTH_BYPASS === "true") {
    return;
  }

  const { error } = await supabase.from("audit_log").insert(payload);
  if (error && import.meta.env.DEV) {
    // eslint-disable-next-line no-console -- server-side diagnostic only in development
    console.warn("Failed to write audit event", { eventType, error });
  }
}
