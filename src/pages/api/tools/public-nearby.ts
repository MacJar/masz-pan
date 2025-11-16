import type { APIContext } from "astro";
import { z } from "zod";
import { jsonError, jsonOk } from "../../../lib/api/responses";
import { SupabaseQueryError } from "../../../lib/services/errors.service";
import { ToolsService } from "../../../lib/services/tools.service";

export const prerender = false;

const QuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lon: z.coerce.number().min(-180).max(180),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  cursor: z.string().trim().optional(),
});

export async function GET({ locals, url }: APIContext): Promise<Response> {
  const supabase = locals.supabase;
  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  const queryObject = Object.fromEntries(url.searchParams);
  const parsed = QuerySchema.safeParse(queryObject);
  if (!parsed.success) {
    return jsonError(400, "validation_error", "Invalid query.", parsed.error.issues);
  }

  try {
    const service = new ToolsService(supabase);
    const result = await service.getPublicActiveToolsNearLocation({
      lat: parsed.data.lat,
      lon: parsed.data.lon,
      limit: parsed.data.limit,
      cursor: parsed.data.cursor,
    });
    return jsonOk(result);
  } catch (error) {
    console.error("Public nearby tools error:", error);
    if (error instanceof SupabaseQueryError) {
      return jsonError(500, "db_error", "Database query failed.");
    }
    return jsonError(500, "internal_error", "An unexpected error occurred.");
  }
}

