import type { APIContext } from "astro";
import { z } from "zod";

import { jsonError, jsonOk } from "@/lib/api/responses";
import {
  getAuthenticatedUserId,
  logAuditEvent,
  SupabaseAuthError,
  SupabaseQueryError,
} from "@/lib/services/profile.service";
import { MissingLocationError, ToolsService, ValidationError } from "@/lib/services/tools.service";

export const prerender = false;

const QuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(20),
  cursor: z.string().trim().optional(),
});

export async function GET({ locals, url }: APIContext): Promise<Response> {
  const supabase = locals.supabase;

  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  try {
    const userId = await getAuthenticatedUserId(supabase);
    if (!userId) {
      await logAuditEvent(supabase, "security", null, {
        endpoint: "/api/tools/nearby",
        reason: "auth_required",
      });
      return jsonError(401, "auth_required", "Authentication required.");
    }

    const queryObject = Object.fromEntries(url.searchParams);
    const parsed = QuerySchema.safeParse(queryObject);
    if (!parsed.success) {
      await logAuditEvent(supabase, "tools_nearby_failed", userId, {
        endpoint: "/api/tools/nearby",
        reason: "validation_error",
      });
      return jsonError(400, "validation_error", "Invalid query.", parseZodIssues(parsed.error));
    }

    const service = new ToolsService(supabase);
    const result = await service.getActiveToolsNearProfile(userId, {
      limit: parsed.data.limit,
      cursor: parsed.data.cursor,
    });

    await logAuditEvent(supabase, "tools_nearby", userId, {
      endpoint: "/api/tools/nearby",
      items: result.items.length,
      has_next: Boolean(result.next_cursor),
    });

    return jsonOk(result);
  } catch (error) {
    // Domain errors
    if (error instanceof MissingLocationError) {
      return jsonError(400, "profile_location_missing", "Profile location required.");
    }
    if (error instanceof ValidationError) {
      return jsonError(400, "validation_error", error.message, error.details as unknown);
    }
    // Infra errors
    if (error instanceof SupabaseQueryError) {
      return jsonError(
        500,
        "internal_error",
        "Unexpected server error.",
        error.code ? { code: error.code } : undefined
      );
    }
    if (error instanceof SupabaseAuthError) {
      return jsonError(401, "auth_required", "Authentication required.");
    }
    console.error("Unhandled error in /api/tools/nearby:", error);
    return jsonError(500, "internal_error", "Unexpected server error.");
  }
}

function parseZodIssues(error: z.ZodError): { path: string; message: string }[] {
  return error.issues.map((i) => ({ path: i.path.join("."), message: i.message }));
}
