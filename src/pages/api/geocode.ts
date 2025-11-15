import type { APIContext } from "astro";
import { z } from "zod";
import { jsonError, jsonOk } from "../../../lib/api/responses";
import { GeocodingService } from "../../../lib/services/geocoding.service";

export const prerender = false;

const QuerySchema = z.object({
  q: z.string().trim().min(1).max(128),
});

export async function GET({ url }: APIContext): Promise<Response> {
  const queryObject = Object.fromEntries(url.searchParams);
  const parsed = QuerySchema.safeParse(queryObject);
  if (!parsed.success) {
    return jsonError(400, "validation_error", "Invalid query.");
  }

  try {
    const service = new GeocodingService();
    const result = await service.geocode(parsed.data.q);
    return jsonOk(result);
  } catch (error) {
    console.error("Geocoding API error:", error);
    const message = error instanceof Error ? error.message : "Geocoding failed.";
    return jsonError(500, "geocoding_error", message);
  }
}
