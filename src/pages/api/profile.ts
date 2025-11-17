import type { APIContext } from "astro";

import type { ProfileDTO, ProfileUpsertCommand } from "@/types";
import {
  SupabaseAuthError,
  SupabaseQueryError,
  fetchProfileById,
  logAuditEvent,
  getAuthenticatedUserId,
  UsernameTakenError,
  upsertOwnProfile,
  ensureDefaultLocationIfMissing,
} from "@/lib/services/profile.service";
import { jsonError, jsonOk, jsonCreated } from "@/lib/api/responses";
import { z } from "zod";
import { createSupabaseServerClient } from "@/db/supabase.client";

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
export async function GET(context: APIContext): Promise<Response> {
  const supabase = createSupabaseServerClient({
    cookies: context.cookies,
    headers: context.request.headers,
  });

  try {
    const userId = await getAuthenticatedUserId(supabase);

    if (!userId) {
      await logAuditEvent(supabase, "security", null, {
        endpoint: "/api/profile",
        reason: "auth_required",
      });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    let profile = await fetchProfileById(supabase, userId);

    if (!profile) {
      await logAuditEvent(supabase, "profile_missing", userId, {
        endpoint: "/api/profile",
      });
      return jsonError(404, "profile_not_found", "Profile not found.");
    }

    // Automatycznie ustaw domyślne wartości geolokalizacji jeśli użytkownik ich nie ma
    await ensureDefaultLocationIfMissing(supabase, userId);

    // Pobierz zaktualizowany profil
    profile = await fetchProfileById(supabase, userId);
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
    return handleUnexpectedError(error, { headers: context.request.headers, cookies: context.cookies });
  }
}

/**
 * Creates or updates the authenticated user's profile.
 * - 201 Created on insert
 * - 200 OK on update
 */
export async function PUT({ request, cookies }: APIContext): Promise<Response> {
  const supabase = createSupabaseServerClient({
    cookies: cookies,
    headers: request.headers,
  });

  try {
    const userId = await getAuthenticatedUserId(supabase);
    if (!userId) {
      await logAuditEvent(supabase, "security", null, {
        endpoint: "/api/profile",
        reason: "auth_required",
      });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    const raw = await request.json().catch(() => ({}));
    const parseResult = ProfileUpsertCommandSchema.safeParse(raw);
    if (!parseResult.success) {
      await logAuditEvent(supabase, "profile_update_failed", userId, {
        endpoint: "/api/profile",
        reason: "validation_error",
      });
      return jsonError(400, "validation_error", "Invalid request payload.", parseZodIssues(parseResult.error));
    }

    const cmd = normalizeProfileUpsertCommand(parseResult.data);

    const { profile, created, geocodeTriggered } = await upsertOwnProfile(supabase, userId, cmd);

    await logAuditEvent(supabase, created ? "profile_create" : "profile_update", userId, {
      endpoint: "/api/profile",
      geocode_triggered: geocodeTriggered,
      profile_id: profile.id,
    });

    return created ? jsonCreated(profile) : jsonOk(profile);
  } catch (error) {
    if (error instanceof UsernameTakenError) {
      await logAuditEvent(
        createSupabaseServerClient({ cookies, headers: request.headers }),
        "profile_update_failed",
        null,
        {
          endpoint: "/api/profile",
          reason: "username_taken",
        }
      );
      return jsonError(409, "username_taken", "Username is already taken.");
    }

    return handleUnexpectedError(error, { cookies, headers: request.headers });
  }
}

const ProfileUpsertCommandSchema = z.object({
  username: z.string().trim().min(1),
  location_text: z.string().trim().optional(),
  rodo_consent: z.boolean(),
});

function normalizeProfileUpsertCommand(input: z.infer<typeof ProfileUpsertCommandSchema>): ProfileUpsertCommand {
  const location =
    typeof input.location_text === "string" && input.location_text.trim().length > 0
      ? input.location_text.trim()
      : null;
  return {
    username: input.username.trim(),
    location_text: location,
    rodo_consent: input.rodo_consent,
  };
}

function parseZodIssues(error: z.ZodError): { path: string; message: string }[] {
  return error.issues.map((i) => ({ path: i.path.join("."), message: i.message }));
}

function handleUnexpectedError(error: unknown): Response {
  // eslint-disable-next-line no-console
  console.error("[API:/api/profile] Unexpected Error:", error);

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
