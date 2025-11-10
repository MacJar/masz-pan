import type { APIContext } from "astro";
import { z } from "zod";

import { jsonError, jsonOk } from "../../../lib/api/responses.ts";
import {
	getAuthenticatedUserId,
	logAuditEvent,
	SupabaseAuthError,
	SupabaseQueryError,
} from "../../../lib/services/profile.service.ts";
import {
	MissingLocationError,
	ValidationError,
	searchActiveToolsNearProfile,
} from "../../../lib/services/tools.service.ts";

export const prerender = false;

const QuerySchema = z.object({
	q: z.string().trim().min(1).max(128),
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
				endpoint: "/api/tools/search",
				reason: "auth_required",
			});
			return jsonError(401, "auth_required", "Authentication required.");
		}

		const queryObject = Object.fromEntries(url.searchParams);
		const parsed = QuerySchema.safeParse(queryObject);
		if (!parsed.success) {
			await logAuditEvent(supabase, "tools_search_failed", userId, {
				endpoint: "/api/tools/search",
				reason: "validation_error",
			});
			return jsonError(400, "validation_error", "Invalid query.", parseZodIssues(parsed.error));
		}

		const result = await searchActiveToolsNearProfile(supabase, userId, {
			q: parsed.data.q.trim(),
			limit: parsed.data.limit,
			cursor: parsed.data.cursor,
		});

		await logAuditEvent(supabase, "tools_search", userId, {
			endpoint: "/api/tools/search",
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
			return jsonError(500, "internal_error", "Unexpected server error.", error.code ? { code: error.code } : undefined);
		}
		if (error instanceof SupabaseAuthError) {
			return jsonError(401, "auth_required", "Authentication required.");
		}
		return jsonError(500, "internal_error", "Unexpected server error.");
	}
}

function parseZodIssues(error: z.ZodError): Array<{ path: string; message: string }> {
	return error.issues.map((i) => ({ path: i.path.join("."), message: i.message }));
}


