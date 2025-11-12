export const prerender = false;

import type { APIRoute } from "astro";
import { z } from "zod";
import { CreateToolImageUploadUrlCommand } from "../../../../../types";
import { AppError, ForbiddenError, NotFoundError } from "../../../../../lib/services/errors.service";
import { ToolsService } from "../../../../../lib/services/tools.service";

// TODO: Replace with real authentication
const MOCK_USER_ID = "1f587053-c01e-4aa6-8931-33567ca6a080";

export const POST: APIRoute = async ({ params, request, locals }) => {
  // const session = locals?.session;
  //
  // if (!session?.user) {
  //   return new Response(JSON.stringify({ error: { message: "Unauthorized" } }), {
  //     status: 401,
  //     headers: { "Content-Type": "application/json" },
  //   });
  // }
  if (!MOCK_USER_ID) {
    throw new Error("MOCK_USER_ID is not defined");
  }

  const toolId = params.id;
  if (!toolId || !z.string().uuid().safeParse(toolId).success) {
    return new Response(JSON.stringify({ error: { message: "Invalid tool ID" } }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  let requestBody;
  try {
    requestBody = await request.json();
  } catch (error) {
    return new Response(JSON.stringify({ error: { message: "Invalid JSON body" } }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const validation = CreateToolImageUploadUrlCommand.safeParse(requestBody);
  if (!validation.success) {
    return new Response(
      JSON.stringify({
        error: { message: "Invalid request body", details: validation.error.flatten() },
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  const command = validation.data;
  const toolsService = new ToolsService(locals.supabase);

  try {
    const result = await toolsService.createSignedImageUploadUrl(toolId, MOCK_USER_ID, command);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    if (error instanceof NotFoundError || error instanceof ForbiddenError) {
      return new Response(JSON.stringify({ error: { message: error.message } }), {
        status: error.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (error instanceof AppError) {
      console.error("AppError caught in upload-url:", error);
      return new Response(JSON.stringify({ error: { message: error.message, code: error.code } }), {
        status: error.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.error("Unhandled error in upload-url:", error);
    const errorMessage = error instanceof Error ? error.message : "An unknown error occurred";
    return new Response(JSON.stringify({ error: { message: "Internal Server Error", details: errorMessage } }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
};
