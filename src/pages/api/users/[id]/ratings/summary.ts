import type { APIRoute } from "astro";
import { z } from "zod";
import { getRatingSummary, SupabaseQueryError } from "../../../../lib/services/profile.service";

export const prerender = false;

const UserIdParams = z.object({
  id: z.string().uuid({ message: "User ID must be a valid UUID." }),
});

export const GET: APIRoute = async ({ params, locals }) => {
  const supabase = locals.supabase;
  const parseResult = UserIdParams.safeParse(params);

  if (!parseResult.success) {
    return new Response(
      JSON.stringify({
        message: "Invalid input",
        errors: parseResult.error.flatten().fieldErrors.id,
      }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }

  const { id: userId } = parseResult.data;

  try {
    const summary = await getRatingSummary(supabase, userId);

    if (!summary) {
      return new Response(JSON.stringify({ message: "User not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify(summary), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    const isQueryError = error instanceof SupabaseQueryError;
    // Log the actual error for debugging
    console.error("Error fetching rating summary:", {
      message: error instanceof Error ? error.message : String(error),
      userId,
      isQueryError,
      code: isQueryError ? error.code : undefined,
    });

    return new Response(JSON.stringify({ message: "An internal server error occurred." }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
};
