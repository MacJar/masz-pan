import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "@/lib/api/responses";
import { BadRequestError, UnauthorizedError } from "@/lib/services/errors.service";
import { ToolsService } from "@/lib/services/tools.service";

export const prerender = false;

export const DeleteParamsSchema = z.object({
  id: z.string().uuid({ message: "Invalid tool ID format" }),
  imageId: z.string().uuid({ message: "Invalid image ID format" }),
});

export const DELETE: APIRoute = async ({ params, locals }) => {
  const { supabase, user } = locals;

  if (!user) {
    return apiError(new UnauthorizedError("You must be logged in to delete an image."));
  }

  const result = DeleteParamsSchema.safeParse(params);

  if (!result.success) {
    return apiError(new BadRequestError("Invalid request params"));
  }

  const { id: toolId, imageId } = result.data;
  const toolsService = new ToolsService(supabase);

  try {
    await toolsService.deleteToolImage({
      toolId,
      imageId,
      userId: user.id,
    });
    return apiSuccess(200, { deleted: true });
  } catch (error) {
    return apiError(error);
  }
};
