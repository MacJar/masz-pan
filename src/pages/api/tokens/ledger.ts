import type { APIRoute } from "astro";
import { GetLedgerEntriesQuerySchema } from "@/lib/schemas/token.schema";
import { TokensService } from "@/lib/services/tokens.service";
import { ErrorService } from "@/lib/services/errors.service";

export const prerender = false;

export const GET: APIRoute = async ({ request, locals }) => {
  const session = locals.session;
  if (!session?.user) {
    return ErrorService.json({ code: "UNAUTHORIZED", message: "Not authenticated" }, 401);
  }

  const url = new URL(request.url);
  const queryParams = Object.fromEntries(url.searchParams.entries());

  const validationResult = GetLedgerEntriesQuerySchema.safeParse(queryParams);
  if (!validationResult.success) {
    return ErrorService.json(
      {
        code: "BAD_REQUEST",
        message: "Invalid query parameters",
        details: validationResult.error.flatten(),
      },
      400,
    );
  }

  try {
    const result = await TokensService.getLedgerEntries(locals.supabase, session.user.id, validationResult.data);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error fetching token ledger:", error);
    return ErrorService.json({ code: "INTERNAL_SERVER_ERROR", message: "Could not fetch token ledger" }, 500);
  }
};
