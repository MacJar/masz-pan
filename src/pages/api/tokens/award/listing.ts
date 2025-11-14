import type { APIRoute } from "astro";
import { apiError, apiSuccess } from "@/lib/api/responses";
import { AwardListingBonusPayloadSchema } from "@/lib/schemas/token.schema";
import { tokensService } from "@/lib/services/tokens.service";
import { AppError } from "@/lib/services/errors.service";

export const prerender = false;

export const POST: APIRoute = async ({ request, locals }) => {
  const { user } = locals;

  if (!user) {
    return apiError(401, "Unauthorized");
  }

  let payload;
  try {
    const json = await request.json();
    payload = AwardListingBonusPayloadSchema.parse(json);
  } catch (e) {
    return apiError(400, "Invalid request body.");
  }

  try {
    const result = await tokensService.awardListingBonus(locals.supabase, {
      userId: user.id,
      toolId: payload.toolId,
    });
    return apiSuccess(result);
  } catch (e) {
    if (e instanceof AppError) {
      return apiError(e.status, e.message, e.code);
    }
    console.error("Error awarding listing bonus:", e);
    return apiError(500, "Internal Server Error");
  }
};
