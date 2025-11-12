import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "../../../../lib/api/responses";
import { BadRequestError } from "../../../../lib/services/errors.service";
import { ToolsService } from "../../../../lib/services/tools.service";
import { CreateToolImageCommandSchema } from "../../../../types";

export const prerender = false;

// TODO: Replace with real authentication
const MOCK_USER_ID = "1f587053-c01e-4aa6-8931-33567ca6a080";

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

export const POST: APIRoute = async ({ params, request, locals }) => {
  if (!MOCK_USER_ID) {
    throw new Error("MOCK_USER_ID is not defined");
  }

  const validation = GetParamsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  let requestBody;
  try {
    requestBody = await request.json();
  } catch {
    return apiError(new BadRequestError("Invalid JSON body"));
  }

  const bodyValidation = CreateToolImageCommandSchema.safeParse(requestBody);
  if (!bodyValidation.success) {
    return apiError(new BadRequestError("Invalid request body"));
  }

  const { supabase } = locals;
  const toolsService = new ToolsService(supabase);
  const toolId = validation.data.id;
  const command = bodyValidation.data;

  try {
    const newImage = await toolsService.createToolImage(toolId, MOCK_USER_ID, command);
    return apiSuccess(201, newImage);
  } catch (error) {
    return apiError(error);
  }
};
