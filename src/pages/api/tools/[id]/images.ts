import type { APIRoute } from "astro";
import { z } from "zod";
import { apiError, apiSuccess } from "@/lib/api/responses";
import {
  BadRequestError,
  InternalServerError,
  UnauthorizedError,
} from "@/lib/services/errors.service";
import { ToolsService } from "@/lib/services/tools.service";
import { CreateToolImageCommandSchema } from "@/types";

export const prerender = false;

const GetParamsSchema = z.object({
  id: z.string().uuid(),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const validation = GetParamsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  const { supabase, user } = locals;
  if (!supabase) {
    return apiError(new InternalServerError("Supabase client not initialized"));
  }

  const toolsService = new ToolsService(supabase);
  const currentUserId = user?.id ?? null;
  const toolId = validation.data.id;

  try {
    const images = await toolsService.getToolImagesForTool(toolId, currentUserId);
    return apiSuccess(200, images);
  } catch (error) {
    return apiError(error);
  }
};

export const POST: APIRoute = async ({ params, request, locals }) => {
  const validation = GetParamsSchema.safeParse(params);
  if (!validation.success) {
    return apiError(new BadRequestError("Tool ID must be a valid UUID"));
  }

  const { supabase, user } = locals;
  if (!supabase) {
    return apiError(new InternalServerError("Supabase client not initialized"));
  }

  if (!user) {
    return apiError(new UnauthorizedError());
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

  const toolsService = new ToolsService(supabase);
  const toolId = validation.data.id;
  const command = bodyValidation.data;

  try {
    const newImage = await toolsService.createToolImage(toolId, user.id, command);
    return apiSuccess(201, newImage);
  } catch (error) {
    return apiError(error);
  }
};
