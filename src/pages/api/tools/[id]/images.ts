import type { APIRoute } from "astro";
import { z } from "zod";
import {
	ForbiddenError,
	NotFoundError,
	SupabaseQueryError,
	ToolsService,
} from "../../../../lib/services/tools.service";
import { apiError, apiSuccess } from "../../../../lib/api/responses";

export const prerender = false;

const ParamsSchema = z.object({
	id: z.string().uuid(),
});

export const GET: APIRoute = async ({ params, locals }) => {
	const validation = ParamsSchema.safeParse(params);
	if (!validation.success) {
		return apiError(400, "INVALID_INPUT", "Tool ID must be a valid UUID", validation.error.flatten());
	}

	const { supabase, session } = locals;
	const toolsService = new ToolsService(supabase);
	const currentUserId = session?.user.id;
	const toolId = validation.data.id;

	try {
		const images = await toolsService.getToolImagesForTool(toolId, currentUserId);
		return apiSuccess(images);
	} catch (error) {
		if (error instanceof NotFoundError) {
			return apiError(404, "NOT_FOUND", error.message);
		}
		if (error instanceof ForbiddenError) {
			return apiError(403, "FORBIDDEN", error.message);
		}
		if (error instanceof SupabaseQueryError) {
			console.error("Supabase error while fetching tool images:", error.cause);
			return apiError(500, "DATABASE_ERROR", "Could not fetch tool images due to a database error.");
		}
		console.error("Unexpected error fetching tool images:", error);
		return apiError(500, "INTERNAL_SERVER_ERROR", "An unexpected error occurred.");
	}
};
