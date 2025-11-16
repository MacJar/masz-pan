import type { APIRoute } from "astro";
import { AppError, UnprocessableEntityError } from "@/lib/services/errors.service";
import { jsonError, jsonOk } from "@/lib/api/responses";
import { ToolsService } from "@/lib/services/tools.service";
import { ToolIdParamSchema } from "@/lib/schemas/tool.schema";

export const prerender = false;

export const POST: APIRoute = async ({ params, locals }) => {
  const { user } = locals;
  if (!user) {
    return jsonError(401, "UNAUTHORIZED", "User is not authenticated.");
  }

  const validation = ToolIdParamSchema.safeParse(params);
  if (!validation.success) {
    return jsonError(400, "INVALID_TOOL_ID", "Invalid tool ID format", validation.error.flatten());
  }

  const { id: toolId } = validation.data;
  const toolService = new ToolsService(locals.supabase);

  try {
    const publishedTool = await toolService.publishTool(toolId, user.id);
    return jsonOk(publishedTool);
  } catch (err) {
    if (err instanceof AppError) {
      return jsonError(err.status, err.code, err.message);
    }
    if (err instanceof UnprocessableEntityError) {
      return jsonError(422, "UNPROCESSABLE_ENTITY", err.message);
    }
    console.error("Error publishing tool:", err);
    return jsonError(500, "INTERNAL_SERVER_ERROR", "Failed to publish tool due to an unexpected error.");
  }
};


