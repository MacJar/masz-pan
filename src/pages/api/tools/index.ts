import type { APIRoute } from "astro";
import { ToolsService } from "@/lib/services/tools.service";
import { z } from "zod";
import type { ToolStatus } from "@/types";

export const prerender = false;

const getToolsQuerySchema = z.object({
  owner_id: z.string(),
  status: z.enum(["draft", "active", "archived", "inactive", "all"]).optional().default("all"),
  limit: z.coerce.number().int().positive().optional().default(10),
  cursor: z.string().optional(),
});

export const GET: APIRoute = async ({ request, locals }) => {
  const url = new URL(request.url);
  const queryParams = Object.fromEntries(url.searchParams.entries());

  const validation = getToolsQuerySchema.safeParse(queryParams);

  if (!validation.success) {
    return new Response(JSON.stringify({ error: validation.error.flatten() }), { status: 400 });
  }

  const { owner_id, status, limit, cursor } = validation.data;
  const { user } = locals;

  if (owner_id === "me" && !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
  }
  const resolvedOwnerId = owner_id === "me" ? user.id : owner_id;

  try {
    const service = new ToolsService(locals.supabase);
    const result = await service.getToolsByOwner({
      ownerId: resolvedOwnerId,
      status: status as ToolStatus | "all",
      limit,
      cursor,
    });
    return new Response(JSON.stringify(result), { status: 200 });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(error);
    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
  }
};

export const POST: APIRoute = async ({ locals }) => {
  const { user } = locals;
  if (!user) {
    return new Response(
      JSON.stringify({
        error: {
          code: "UNAUTHORIZED",
          message: "User is not authenticated.",
        },
      }),
      { status: 401, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    const service = new ToolsService(locals.supabase);
    const draftTool = await service.createDraftTool(user.id);

    return new Response(JSON.stringify(draftTool), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error: unknown) {
    // eslint-disable-next-line no-console
    console.error("Internal Server Error:", error);
    return new Response(
      JSON.stringify({
        error: {
          code: "INTERNAL_SERVER_ERROR",
          message: error instanceof Error ? error.message : "An unexpected error occurred on the server.",
        },
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
};
