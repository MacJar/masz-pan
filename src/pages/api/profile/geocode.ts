import type { APIRoute } from "astro";
import { geocodeAndSaveForProfile } from "@/lib/services/geocoding.service";
import { AppError } from "@/lib/services/errors.service";
import { apiError, jsonError, jsonOk } from "@/lib/api/responses";

export const prerender = false;

export const POST: APIRoute = async ({ locals }) => {
  const { session, supabase } = locals;

  if (!session?.user) {
    return jsonError(401, "UNAUTHORIZED", "Unauthorized");
  }

  const { user } = session;

  try {
    const result = await geocodeAndSaveForProfile(user.id, supabase);
    return jsonOk(result);
  } catch (err) {
    if (err instanceof AppError) {
      return apiError(err);
    }
    // eslint-disable-next-line no-console
    console.error("Unknown error in POST /api/profile/geocode", err);
    return jsonError(500, "INTERNAL_SERVER_ERROR", "An unexpected error occurred.");
  }
};
