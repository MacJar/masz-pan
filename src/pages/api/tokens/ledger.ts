import type { APIRoute } from "astro";
import { GetLedgerEntriesQuerySchema } from "@/lib/schemas/token.schema";
import { tokensService } from "@/lib/services/tokens.service";
import { jsonError } from "../../../lib/api/responses.ts";

export const prerender = false;

export const GET: APIRoute = async ({ request, locals }) => {
  const session = locals.session;
  const supabase = locals.supabase;

  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  if (!session?.user) {
    return jsonError(401, "auth_required", "Authentication required.");
  }

  const url = new URL(request.url);
  const queryParams = Object.fromEntries(url.searchParams.entries());

  const validationResult = GetLedgerEntriesQuerySchema.safeParse(queryParams);
  if (!validationResult.success) {
    return jsonError(400, "validation_error", "Invalid query parameters", validationResult.error.flatten());
  }

  try {
    const result = await tokensService.getLedgerEntries(supabase, session.user.id, validationResult.data);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error fetching token ledger:", error);
    return jsonError(500, "internal_error", "Could not fetch token ledger");
  }
};
