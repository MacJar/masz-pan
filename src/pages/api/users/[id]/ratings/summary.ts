import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "@/lib/api/responses";
import { BadRequestError, NotFoundError } from "@/lib/services/errors.service";
import { getRatingSummary } from "@/lib/services/profile.service";

export const prerender = false;

const UserIdParamsSchema = z.object({
  id: z.string().uuid({ message: "User ID must be a valid UUID." }),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const { supabase } = locals;
  const parseResult = UserIdParamsSchema.safeParse(params);

  if (!parseResult.success) {
    return apiError(new BadRequestError("Invalid User ID"));
  }

  const { id: userId } = parseResult.data;

  try {
    const summary = await getRatingSummary(supabase, userId);

    if (!summary) {
      return apiError(new NotFoundError("User not found"));
    }

    return apiSuccess(200, summary);
  } catch (error) {
    return apiError(error);
  }
};
