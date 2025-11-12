import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "../../../../lib/api/responses";
import { BadRequestError } from "../../../../lib/services/errors.service";
import { ToolsService } from "../../../../lib/services/tools.service";

export const prerender = false;

const GetParamsSchema = z.object({
  id: z.string().uuid(),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const validation = GetParamsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  const { supabase, session } = locals;
  const toolsService = new ToolsService(supabase);
  const currentUserId = session?.user.id;
  const toolId = validation.data.id;

  try {
    const images = await toolsService.getToolImagesForTool(toolId, currentUserId);
    return apiSuccess(200, images);
  } catch (error) {
    return apiError(error);
  }
};
