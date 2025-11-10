import type { SupabaseClient } from "../../db/supabase.client.ts";
import { createServiceClient } from "../../db/supabase.client.ts";
import type { ProfileDTO, ProfileUpsertCommand } from "../../types.ts";
import type { Database, Json } from "../../db/database.types.ts";
import { geocodeLocation } from "./geocoding.service.ts";

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

export class UsernameTakenError extends Error {
  constructor() {
    super("Username taken");
    this.name = "UsernameTakenError";
  }
}

export async function upsertOwnProfile(
  supabase: SupabaseClient,
  userId: string,
  cmd: ProfileUpsertCommand
): Promise<{ profile: ProfileDTO; created: boolean; geocodeTriggered: boolean }> {
  const normalizedUsername = cmd.username.trim();
  const normalizedLocation = normalizeLocationText(cmd.location_text ?? null);

  const current = await fetchProfileById(supabase, userId);
  let geocodeTriggered = false;

  // Uniqueness check only if username differs from current or profile doesn't exist
  if (!current || current.username !== normalizedUsername) {
    const { data: existing, error: existingErr } = await supabase
      .from("profiles")
      .select("id")
      .eq("username", normalizedUsername)
      .neq("id", userId)
      .limit(1);
    if (existingErr) {
      throw new SupabaseQueryError("Failed to check username uniqueness.", existingErr.code, existingErr);
    }
    if (Array.isArray(existing) && existing.length > 0) {
      throw new UsernameTakenError();
    }
  }

  if (!current) {
    const insertRow: Database["public"]["Tables"]["profiles"]["Insert"] = {
      id: userId,
      username: normalizedUsername,
      rodo_consent: cmd.rodo_consent,
      location_text: normalizedLocation,
    };
    if (normalizedLocation) {
      const geo = await geocodeLocation(normalizedLocation);
      if (geo) {
        geocodeTriggered = true;
        insertRow.location_geog = geo.location_geog as unknown;
      }
    }
    const { data, error } = await supabase
      .from("profiles")
      .insert(insertRow)
      .select("*")
      .single();
    if (error) {
      // Map unique violation to conflict
      if (error.code === "23505") {
        throw new UsernameTakenError();
      }
      throw new SupabaseQueryError("Failed to create profile.", error.code, error);
    }
    return { profile: data as ProfileDTO, created: true, geocodeTriggered };
  }

  const updates: Database["public"]["Tables"]["profiles"]["Update"] = {};
  if (current.username !== normalizedUsername) {
    updates.username = normalizedUsername;
  }
  if (current.rodo_consent !== cmd.rodo_consent) {
    updates.rodo_consent = cmd.rodo_consent;
  }
  if (hasLocationChanged(current.location_text, normalizedLocation)) {
    updates.location_text = normalizedLocation;
    if (normalizedLocation) {
      const geo = await geocodeLocation(normalizedLocation);
      if (geo) {
        geocodeTriggered = true;
        updates.location_geog = geo.location_geog as unknown;
      } else {
        // if geocode failed, explicitly null out location_geog to avoid stale data when text changed
        updates.location_geog = null as unknown as undefined;
      }
    } else {
      updates.location_geog = null as unknown as undefined;
    }
  }

  if (Object.keys(updates).length === 0) {
    return { profile: current, created: false, geocodeTriggered };
  }

  const { data, error } = await supabase
    .from("profiles")
    .update(updates)
    .eq("id", userId)
    .select("*")
    .single();
  if (error) {
    if (error.code === "23505") {
      throw new UsernameTakenError();
    }
    throw new SupabaseQueryError("Failed to update profile.", error.code, error);
  }
  return { profile: data as ProfileDTO, created: false, geocodeTriggered };
}

export function normalizeLocationText(input: string | null | undefined): string | null {
  if (typeof input !== "string") {
    return null;
  }
  const trimmed = input.trim();
  return trimmed.length === 0 ? null : trimmed;
}

export function hasLocationChanged(prev: string | null, next: string | null): boolean {
  return normalizeLocationText(prev) !== normalizeLocationText(next);
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
