import type { SupabaseClient } from "../../db/supabase.client.ts";
import type {
  ProfileDTO,
  ProfileUpsertCommand,
  PublicProfileDTO,
  RatingSummaryDTO,
  ToolSummaryDTO,
} from "../../types.ts";
import type { Database, Json } from "../../db/database.types.ts";
import { getDefaultPostalCode, getDefaultCoordinates } from "./geocoding.service.ts";
import { getToolImagePublicUrl } from "../utils.ts";

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
 * Fetches the user's rating summary from the materialized view.
 * If the user has no ratings but the profile exists, it returns a zero-summary.
 *
 * @returns {Promise<RatingSummaryDTO | null>} The rating summary or null if the user profile does not exist.
 * @throws {SupabaseQueryError} When the database query fails for reasons other than the user not being found.
 */
export async function getRatingSummary(supabase: SupabaseClient, userId: string): Promise<RatingSummaryDTO | null> {
  // First, try to get the summary from the materialized view
  const { data: summary, error: summaryError } = await supabase
    .from("rating_stats")
    .select("rated_user_id, avg_stars, ratings_count")
    .eq("rated_user_id", userId)
    .single();

  if (summaryError && summaryError.code !== NOT_FOUND_ERROR_CODE) {
    throw new SupabaseQueryError("Failed to fetch rating summary.", summaryError.code, summaryError);
  }

  if (summary) {
    return summary;
  }

  // If no summary, check if the profile exists
  const profile = await fetchProfileById(supabase, userId);
  if (!profile) {
    return null; // User not found
  }

  // Profile exists, but no ratings yet
  return {
    rated_user_id: userId,
    avg_stars: null,
    ratings_count: 0,
  };
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

/**
 * Automatycznie ustawia domyślne wartości geolokalizacji dla użytkownika, jeśli ich nie ma.
 * Wywoływane automatycznie przy logowaniu lub odczycie profilu.
 */
export async function ensureDefaultLocationIfMissing(supabase: SupabaseClient, userId: string): Promise<void> {
  const profile = await fetchProfileById(supabase, userId);
  if (!profile) {
    return; // Profil nie istnieje, nie robimy nic
  }

  // Jeśli użytkownik nie ma geolokalizacji, ustaw domyślne wartości
  if (!profile.location_geog) {
    const defaultPostalCode = getDefaultPostalCode();
    const defaultCoords = getDefaultCoordinates();

    // Ustawiamy location_text jeśli nie ma
    if (!profile.location_text) {
      await supabase.from("profiles").update({ location_text: defaultPostalCode }).eq("id", userId);
    }

    // Ustawiamy location_geog używając funkcji RPC
    await supabase.rpc("set_profile_location_geog", {
      p_user_id: userId,
      p_lon: defaultCoords.lon,
      p_lat: defaultCoords.lat,
    });
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
    // Dla nowych użytkowników używamy domyślnych wartości zamiast geokodowania
    const defaultPostalCode = getDefaultPostalCode();
    const defaultCoords = getDefaultCoordinates();

    const insertRow: Database["public"]["Tables"]["profiles"]["Insert"] = {
      id: userId,
      username: normalizedUsername,
      rodo_consent: cmd.rodo_consent,
      location_text: normalizedLocation ?? defaultPostalCode,
      // location_geog zostanie ustawione przez funkcję RPC poniżej
    };

    const { error } = await supabase.from("profiles").insert(insertRow).select("*").single();
    if (error) {
      // Map unique violation to conflict
      if (error.code === "23505") {
        throw new UsernameTakenError();
      }
      throw new SupabaseQueryError("Failed to create profile.", error.code, error);
    }

    // Ustawiamy domyślną geolokalizację używając funkcji RPC z PostGIS
    const { error: rpcError } = await supabase.rpc("set_profile_location_geog", {
      p_user_id: userId,
      p_lon: defaultCoords.lon,
      p_lat: defaultCoords.lat,
    });

    if (rpcError) {
      throw new SupabaseQueryError("Failed to set default location.", rpcError.code, rpcError);
    }

    geocodeTriggered = true; // Oznaczamy że ustawiliśmy geolokalizację (domyślną)

    // Pobieramy zaktualizowany profil z geolokalizacją
    const updatedProfile = await fetchProfileById(supabase, userId);
    if (!updatedProfile) {
      throw new SupabaseQueryError("Failed to fetch updated profile.", undefined, undefined);
    }

    return { profile: updatedProfile, created: true, geocodeTriggered };
  }

  const updates: Database["public"]["Tables"]["profiles"]["Update"] = {};
  if (current.username !== normalizedUsername) {
    updates.username = normalizedUsername;
  }
  if (current.rodo_consent !== cmd.rodo_consent) {
    updates.rodo_consent = cmd.rodo_consent;
  }

  // Sprawdź czy użytkownik nie ma ustawionej geolokalizacji - jeśli nie, ustaw domyślne wartości
  const hasNoLocation = !current.location_geog;
  const locationChanged = hasLocationChanged(current.location_text, normalizedLocation);

  if (hasNoLocation || locationChanged) {
    const defaultPostalCode = getDefaultPostalCode();

    // Jeśli użytkownik nie ma geolokalizacji, ustaw domyślne wartości
    if (hasNoLocation) {
      // Jeśli użytkownik nie ma location_text, ustaw domyślny kod pocztowy
      if (!current.location_text) {
        updates.location_text = defaultPostalCode;
      }
      geocodeTriggered = true;
    } else if (locationChanged) {
      // Jeśli użytkownik zmienił lokalizację tekstową, ustaw nową lokalizację
      updates.location_text = normalizedLocation ?? defaultPostalCode;
      geocodeTriggered = true;
    }

    // Ustawiamy domyślną geolokalizację używając funkcji RPC z PostGIS (poza updates, bo to osobne zapytanie)
    // Zrobimy to po update, jeśli są jakieś updates
  }

  // Jeśli są updates, wykonaj update
  if (Object.keys(updates).length > 0) {
    const { error } = await supabase.from("profiles").update(updates).eq("id", userId).select("*").single();
    if (error) {
      if (error.code === "23505") {
        throw new UsernameTakenError();
      }
      throw new SupabaseQueryError("Failed to update profile.", error.code, error);
    }

    // Jeśli ustawiamy geolokalizację, użyj funkcji RPC
    if (geocodeTriggered) {
      const defaultCoordsForRpc = getDefaultCoordinates();
      const { error: rpcError } = await supabase.rpc("set_profile_location_geog", {
        p_user_id: userId,
        p_lon: defaultCoordsForRpc.lon,
        p_lat: defaultCoordsForRpc.lat,
      });

      if (rpcError) {
        throw new SupabaseQueryError("Failed to set default location.", rpcError.code, rpcError);
      }

      // Pobieramy zaktualizowany profil z geolokalizacją
      const updatedProfile = await fetchProfileById(supabase, userId);
      if (!updatedProfile) {
        throw new SupabaseQueryError("Failed to fetch updated profile.", undefined, undefined);
      }
      return { profile: updatedProfile, created: false, geocodeTriggered };
    }

    return { profile: current, created: false, geocodeTriggered };
  }

  // Jeśli nie ma updates, ale ustawiamy geolokalizację (hasNoLocation)
  if (geocodeTriggered && hasNoLocation) {
    const defaultCoordsForRpc = getDefaultCoordinates();
    const { error: rpcError } = await supabase.rpc("set_profile_location_geog", {
      p_user_id: userId,
      p_lon: defaultCoordsForRpc.lon,
      p_lat: defaultCoordsForRpc.lat,
    });

    if (rpcError) {
      throw new SupabaseQueryError("Failed to set default location.", rpcError.code, rpcError);
    }

    // Pobieramy zaktualizowany profil z geolokalizacją
    const updatedProfile = await fetchProfileById(supabase, userId);
    if (!updatedProfile) {
      throw new SupabaseQueryError("Failed to fetch updated profile.", undefined, undefined);
    }
    return { profile: updatedProfile, created: false, geocodeTriggered };
  }

  return { profile: current, created: false, geocodeTriggered };
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
 *
 * Uses RLS policy "audit_log_insert_auth" which allows authenticated users
 * to insert events where actor_id matches their user ID or is null.
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

  // In bypass mode: skip audit writes to avoid noisy RLS errors
  if (import.meta.env.AUTH_BYPASS === "true") {
    return;
  }

  const { error } = await supabase.from("audit_log").insert(payload);
  if (error && import.meta.env.DEV) {
    // eslint-disable-next-line no-console -- server-side diagnostic only in development
    console.warn("Failed to write audit event", { eventType, error });
  }
}

export const profileService = {
  getAuthenticatedUserId,
  getRatingSummary,
  fetchProfileById,
  upsertOwnProfile,
  normalizeLocationText,
  hasLocationChanged,
  logAuditEvent,
  /**
   * Returns a public profile DTO enriched with active tools owned by the user.
   * This is used by both the public profile API and the `/u/:id` page.
   */
  getPublicProfile: async (supabase: SupabaseClient, userId: string): Promise<PublicProfileDTO | null> => {
    const { data, error } = await supabase.from("public_profiles").select().eq("id", userId).single();

    if (error) {
      // eslint-disable-next-line no-console
      console.error("Error fetching public profile:", error);
      if (error.code === "PGRST116") {
        // No rows found is not a critical error, just return null
        return null;
      }
      throw new Error("Could not fetch user's public profile.");
    }

    if (!data) {
      return null;
    }

    // Fetch active tools for this user (public-only)
    const { data: tools, error: toolsError } = await supabase
      .from("tools")
      .select("id, name, description, images:tool_images(storage_key)")
      .eq("owner_id", userId)
      .eq("status", "active")
      .order("created_at", { ascending: false });

    if (toolsError) {
      // eslint-disable-next-line no-console
      console.error("Error fetching active tools for public profile:", toolsError);
      throw new Error("Could not fetch user's public tools.");
    }

    interface ToolWithImages {
      id: string;
      name: string | null;
      description: string | null;
      images: { storage_key: string }[] | null;
    }

    const active_tools: ToolSummaryDTO[] = Array.isArray(tools)
      ? tools.map((tool: ToolWithImages) => {
          const firstImage = Array.isArray(tool.images) && tool.images.length > 0 ? tool.images[0] : null;
          const imageUrl =
            firstImage && typeof firstImage.storage_key === "string" && firstImage.storage_key.length > 0
              ? getToolImagePublicUrl(firstImage.storage_key)
              : null;

          return {
            id: tool.id,
            name: tool.name ?? "",
            imageUrl,
            description: tool.description ?? "",
          };
        })
      : [];

    // Map db view + tools to DTO
    const profile: PublicProfileDTO = {
      id: typeof data.id === "string" ? data.id : "",
      username: data.username ?? "",
      location_text: data.location_text ?? null,
      avg_rating: data.avg_stars ?? null, // Remap avg_stars to avg_rating
      ratings_count: typeof data.ratings_count === "number" ? data.ratings_count : 0,
      active_tools,
    };

    return profile;
  },
};
