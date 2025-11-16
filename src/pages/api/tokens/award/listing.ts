import type { APIRoute } from "astro";
import { jsonError, jsonOk } from "@/lib/api/responses";
import { AwardListingBonusPayloadSchema } from "@/lib/schemas/token.schema";
import { LISTING_BONUS_AMOUNT, tokensService } from "@/lib/services/tokens.service";
import { AppError } from "@/lib/services/errors.service";

export const prerender = false;

export const POST: APIRoute = async ({ request, locals }) => {
  const { user, supabase } = locals;

  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  if (!user) {
    return jsonError(401, "auth_required", "Authentication required.");
  }

  let payload;
  try {
    const json = await request.json();
    payload = AwardListingBonusPayloadSchema.parse(json);
  } catch {
    return jsonError(400, "validation_error", "Invalid request body.");
  }

  try {
    await tokensService.awardListingBonus(supabase, user.id, payload.toolId);
    return jsonOk({ awarded: true, amount: LISTING_BONUS_AMOUNT, count_used: 0 });
  } catch (e) {
    if (e instanceof AppError) {
      return jsonError(e.status, e.code, e.message);
    }
    // eslint-disable-next-line no-console
    console.error("Error awarding listing bonus:", e);
    return jsonError(500, "internal_error", "Internal Server Error");
  }
};
