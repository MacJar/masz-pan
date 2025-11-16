import type { APIContext } from "astro";
import { z } from "zod";
import { jsonError, jsonOk } from "@/lib/api/responses";
import { geocodeLocation } from "@/lib/services/geocoding.service";

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
    const result = await geocodeLocation(parsed.data.q);
    if (!result) {
      return jsonError(404, "geocoding_error", "Location could not be resolved.");
    }
    return jsonOk(result);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error("Geocoding API error:", error);
    const message = error instanceof Error ? error.message : "Geocoding failed.";
    return jsonError(500, "geocoding_error", message);
  }
}
