import type { APIRoute } from "astro";
import { ToolsService } from "../../../lib/services/tools.service";

export const prerender = false;

// TODO: Replace with real authentication
const MOCK_USER_ID = "1f587053-c01e-4aa6-8931-33567ca6a080";

export const POST: APIRoute = async ({ locals }) => {
  // const session = await locals.auth.getSession();
  // if (!session) {
  //   return new Response(
  //     JSON.stringify({
  //       error: {
  //         code: "UNAUTHORIZED",
  //         message: "User is not authenticated.",
  //       },
  //     }),
  //     { status: 401, headers: { "Content-Type": "application/json" } }
  //   );
  // }
  if (!MOCK_USER_ID) {
    throw new Error("MOCK_USER_ID is not defined");
  }

  try {
    const service = new ToolsService(locals.supabase);
    const draftTool = await service.createDraftTool(MOCK_USER_ID);

    return new Response(JSON.stringify(draftTool), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error: any) {
    console.error("Internal Server Error:", error);
    return new Response(
      JSON.stringify({
        error: {
          code: "INTERNAL_SERVER_ERROR",
          message: error.message || "An unexpected error occurred on the server.",
        },
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
};
