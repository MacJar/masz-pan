import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "../../../lib/api/responses";
import { ToolsService } from "../../../lib/services/tools.service";
import { BadRequestError } from "../../../lib/services/errors.service";
import { UpdateToolCommandSchema } from "../../../types";
import { supabase } from "../../../db/supabase.client";
import {
  AppError,
  BadRequestError,
  ForbiddenError,
  NotFoundError,
  ToolHasActiveReservationsError,
  UnauthorizedError,
} from "../../../lib/services/errors.service";
import type { ToolArchivedResponseDto } from "../../../types";
import { createApiErrorResponse, createApiSuccessResponse } from "../../../lib/api/responses";

export const prerender = false;

// TODO: Replace with real authentication
const MOCK_USER_ID = "1f587053-c01e-4aa6-8931-33567ca6a080";

const paramsSchema = z.object({
  id: z.string().uuid({ message: "Tool ID must be a valid UUID." }),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const validation = paramsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  const service = new ToolsService(locals.supabase);
  const toolId = validation.data.id;

  try {
    const tool = await service.findToolWithImagesById(toolId);
    return apiSuccess(200, tool);
  } catch (error) {
    return apiError(error);
  }
};

export const PATCH: APIRoute = async ({ params, request, locals }) => {
  if (!MOCK_USER_ID) {
    throw new Error("MOCK_USER_ID is not defined");
  }

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

  const { supabase } = locals;
  const toolsService = new ToolsService(supabase);
  const toolId = paramsValidation.data.id;
  const command = bodyValidation.data;

  try {
    const updatedTool = await toolsService.updateTool(toolId, MOCK_USER_ID, command);
    return apiSuccess(200, updatedTool);
  } catch (error) {
    return apiError(error);
  }
};

export const DELETE: APIRoute = async ({ params, locals }) => {
  const session = locals.session;
  if (!session) {
    return createApiErrorResponse(new UnauthorizedError("No active session found."));
  }

  const result = IdParamsSchema.safeParse(params);
  if (!result.success) {
    return createApiErrorResponse(new BadRequestError("Invalid tool ID provided.", result.error));
  }
  const { id: toolId } = result.data;
  const { user } = session;

  try {
    const toolsService = new ToolsService(supabase);
    const { archivedAt } = await toolsService.archiveTool(toolId, user.id);

    const response: ToolArchivedResponseDto = {
      archived: true,
      archivedAt: archivedAt.toISOString(),
    };

    return createApiSuccessResponse(response);
  } catch (err: unknown) {
    if (err instanceof AppError) {
      return createApiErrorResponse(err);
    }
    console.error("Unexpected error while archiving tool:", err);
    return createApiErrorResponse(new AppError("An unexpected error occurred.", 500, "INTERNAL_ERROR"));
  }
};
