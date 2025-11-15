import { tokensService } from "@/lib/services/tokens.service";
import { jsonError, jsonOk } from "../../../lib/api/responses.ts";
import type { APIContext } from "astro";

export const prerender = false;

export async function GET({ locals }: APIContext): Promise<Response> {
  const { session, supabase } = locals;

  if (!supabase) {
    return jsonError(500, "internal_error", "Unexpected server configuration error.");
  }

  if (!session?.user) {
    return jsonError(401, "auth_required", "Authentication required.");
  }

  try {
    const balance = await tokensService.getUserBalance(supabase, session.user.id);
    return jsonOk(balance);
  } catch (error) {
    console.error("API Error fetching token balance:", error);
    return jsonError(500, "internal_error", "Could not fetch token balance");
  }
}
