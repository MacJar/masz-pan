import type { APIRoute } from "astro";
import { AppError, UnprocessableEntityError } from "../../../../lib/services/errors.service";
import { createApiErrorResponse, createApiSuccessResponse } from "../../../../lib/api/responses";
import { ToolsService } from "../../../../lib/services/tools.service";
import { ToolIdParamSchema } from "../../../../lib/schemas/tool.schema";

export const prerender = false;

export const POST: APIRoute = async ({ params, locals }) => {
  const { user } = locals;
  if (!user) {
    return createApiErrorResponse(401, "Unauthorized");
  }

  const validation = ToolIdParamSchema.safeParse(params);
  if (!validation.success) {
    return createApiErrorResponse(400, "Invalid tool ID format", validation.error.flatten());
  }

  const { id: toolId } = validation.data;
  const toolService = new ToolsService(locals.supabase);

  try {
    const publishedTool = await toolService.publishTool(toolId, user.id);
    return createApiSuccessResponse(publishedTool);
  } catch (err) {
    if (err instanceof AppError) {
      return createApiErrorResponse(err.status, err.message);
    }
    if (err instanceof UnprocessableEntityError) {
      return createApiErrorResponse(422, err.message);
    }
    console.error("Error publishing tool:", err);
    return createApiErrorResponse(500, "Failed to publish tool due to an unexpected error.");
  }
};

