import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "@/lib/api/responses";
import { ToolsService } from "@/lib/services/tools.service";
import { AppError, BadRequestError, InternalServerError, UnauthorizedError } from "@/lib/services/errors.service";
import { UpdateToolCommandSchema, type ToolArchivedResponseDto } from "@/types";

export const prerender = false;

const paramsSchema = z.object({
  id: z.string().uuid({ message: "Tool ID must be a valid UUID." }),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const validation = paramsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  const { supabase } = locals;
  if (!supabase) {
    return apiError(new InternalServerError("Supabase client not initialized."));
  }

  const service = new ToolsService(supabase);
  const toolId = validation.data.id;

  try {
    const tool = await service.findToolWithImagesById(toolId);
    return apiSuccess(200, tool);
  } catch (error) {
    return apiError(error);
  }
};

export const PATCH: APIRoute = async ({ params, request, locals }) => {
  const paramsValidation = paramsSchema.safeParse(params);
  if (!paramsValidation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  let requestBody;
  try {
    requestBody = await request.json();
  } catch {
    return apiError(new BadRequestError("Invalid JSON body"));
  }

  const bodyValidation = UpdateToolCommandSchema.safeParse(requestBody);
  if (!bodyValidation.success) {
    return apiError(new BadRequestError("Invalid request body", bodyValidation.error));
  }

  const { supabase, user } = locals;
  if (!supabase) {
    return apiError(new InternalServerError("Supabase client not initialized."));
  }

  if (!user) {
    return apiError(new UnauthorizedError());
  }

  const toolsService = new ToolsService(supabase);
  const toolId = paramsValidation.data.id;
  const command = bodyValidation.data;

  try {
    const updatedTool = await toolsService.updateTool(toolId, user.id, command);
    return apiSuccess(200, updatedTool);
  } catch (error) {
    return apiError(error);
  }
};

export const DELETE: APIRoute = async ({ params, locals }) => {
  const { supabase, user } = locals;

  if (!user) {
    return apiError(new UnauthorizedError("No active session found."));
  }

  if (!supabase) {
    return apiError(new InternalServerError("Supabase client not initialized."));
  }

  const result = paramsSchema.safeParse(params);
  if (!result.success) {
    return apiError(new BadRequestError("Invalid tool ID provided.", result.error));
  }
  const { id: toolId } = result.data;

  try {
    const toolsService = new ToolsService(supabase);
    const { archivedAt } = await toolsService.archiveTool(toolId, user.id);

    const response: ToolArchivedResponseDto = {
      archived: true,
      archivedAt: archivedAt.toISOString(),
    };

    return apiSuccess(200, response);
  } catch (err) {
    if (err instanceof AppError) {
      return apiError(err);
    }

    // eslint-disable-next-line no-console
    console.error("Unexpected error while archiving tool:", err);
    return apiError(new AppError("An unexpected error occurred.", 500, "INTERNAL_ERROR"));
  }
};
