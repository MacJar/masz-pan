import type { APIContext } from "astro";

import type { ProfileDTO } from "../../types.ts";
import {
  SupabaseAuthError,
  SupabaseQueryError,
  fetchProfileById,
  logAuditEvent,
  getAuthenticatedUserId,
} from "../../lib/services/profile.service.ts";
import { jsonError, jsonOk } from "../../lib/api/responses.ts";

class ProfilePayloadError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ProfilePayloadError";
  }
}

export const prerender = false;

/**
 * Returns the authenticated user's profile or an error describing why it cannot be retrieved.
 */
export async function GET({ locals }: APIContext): Promise<Response> {
  const supabase = locals.supabase;

  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  try {
    const userId = await getAuthenticatedUserId(supabase);

    if (!userId) {
      await logAuditEvent(supabase, "security", null, {
        endpoint: "/api/profile",
        reason: "auth_required",
      });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    const profile = await fetchProfileById(supabase, userId);

    if (!profile) {
      await logAuditEvent(supabase, "profile_missing", userId, {
        endpoint: "/api/profile",
      });
      return jsonError(404, "profile_not_found", "Profile not found.");
    }

    const safeProfile = validateProfilePayload(profile);

    await logAuditEvent(supabase, "profile_read", userId, {
      endpoint: "/api/profile",
      profile_id: safeProfile.id,
    });

    return jsonOk(safeProfile);
  } catch (error) {
    return handleUnexpectedError(error);
  }
}

function handleUnexpectedError(error: unknown): Response {
  const details = extractErrorDetails(error);

  return jsonError(500, "internal_error", "Unexpected server error.", details);
}

function extractErrorDetails(error: unknown): Record<string, unknown> | undefined {
  if (error instanceof ProfilePayloadError) {
    return { issue: "profile_payload_invalid" };
  }

  if (error instanceof SupabaseQueryError) {
    return error.code ? { code: error.code } : undefined;
  }

  if (error instanceof SupabaseAuthError) {
    return undefined;
  }

  if (error instanceof Error) {
    return {
      name: error.name,
    };
  }

  return undefined;
}

function validateProfilePayload(profile: ProfileDTO): ProfileDTO {
  if (typeof profile.id !== "string" || profile.id.length === 0) {
    throw new ProfilePayloadError("Profile payload is missing id.");
  }

  if (typeof profile.username !== "string" || profile.username.length === 0) {
    throw new ProfilePayloadError("Profile payload is missing username.");
  }

  return profile;
}

/*
Quick manual checks:
- GET /api/profile without session -> 401 auth_required
- GET /api/profile with session but no profile row -> 404 profile_not_found
- GET /api/profile with valid profile -> 200 profile payload, no-store caching
*/
