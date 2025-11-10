import type { APIRoute } from "astro";
import { z } from "zod";
// FIX: Correct import path to follow project structure guidelines
import { ToolsService } from "../../../lib/services/tools.service";

export const prerender = false;

const paramsSchema = z.object({
  id: z.string().uuid({ message: "Tool ID must be a valid UUID." }),
});

export const GET: APIRoute = async ({ params, locals }) => {
  try {
    const validation = paramsSchema.safeParse(params);
    if (!validation.success) {
      return new Response(
        JSON.stringify({
          error: {
            code: "BAD_REQUEST",
            message: "Invalid tool ID provided.",
            details: validation.error.flatten(),
          },
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const service = new ToolsService(locals.supabase);
    const tool = await service.findToolWithImagesById(validation.data.id);

    if (!tool) {
      return new Response(
        JSON.stringify({
          error: {
            code: "NOT_FOUND",
            message: "The requested tool does not exist or you do not have permission to view it.",
          },
        }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(tool), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Internal Server Error:", error);
    return new Response(
      JSON.stringify({
        error: {
          code: "INTERNAL_SERVER_ERROR",
          message: "An unexpected error occurred on the server.",
        },
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
};
