import { z } from "zod";
import type { APIRoute } from "astro";

import { ToolsService } from "../../../../lib/services/tools.service";
import { AppError } from "../../../../lib/services/errors.service";

export const prerender = false;

export const CreateToolImageDtoSchema = z.object({
  storage_key: z.string().min(1, { message: "Storage key is required" }),
  position: z
    .number()
    .int()
    .min(0, { message: "Position must be a non-negative integer" }),
});

export type CreateToolImageDto = z.infer<typeof CreateToolImageDtoSchema>;

const paramsSchema = z.object({
  id: z.string().uuid({ message: "Tool ID must be a valid UUID." }),
});

export const POST: APIRoute = async ({ params, request, locals }) => {
  try {
    const { session } = locals;
    if (!session?.user) {
      return new Response(
        JSON.stringify({
          error: {
            code: "UNAUTHORIZED",
            message: "Authentication is required.",
          },
        }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    const paramsValidation = paramsSchema.safeParse(params);
    if (!paramsValidation.success) {
      return new Response(
        JSON.stringify({
          error: {
            code: "BAD_REQUEST",
            message: "Invalid tool ID provided.",
            details: paramsValidation.error.flatten(),
          },
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const body = await request.json();
    const bodyValidation = CreateToolImageDtoSchema.safeParse(body);

    if (!bodyValidation.success) {
      return new Response(
        JSON.stringify({
          error: {
            code: "BAD_REQUEST",
            message: "Invalid request body.",
            details: bodyValidation.error.flatten(),
          },
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const service = new ToolsService(locals.supabase);
    const newImage = await service.createToolImage(
      paramsValidation.data.id,
      session.user.id,
      bodyValidation.data
    );

    return new Response(JSON.stringify(newImage), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    if (error instanceof AppError) {
      return new Response(
        JSON.stringify({
          error: {
            code: error.code,
            message: error.message,
          },
        }),
        { status: error.status, headers: { "Content-Type": "application/json" } }
      );
    }

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
