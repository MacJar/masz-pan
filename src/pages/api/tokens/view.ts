import type { APIRoute } from "astro";
import { tokensService } from "../../../lib/services/tokens.service";
import { ForbiddenError } from "../../../lib/services/errors.service";

export const prerender = false;

export const GET: APIRoute = async ({ locals }) => {
  const { user, supabase } = locals;
  if (!user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
  }

  try {
    const service = tokensService;

    const [balance, ledgerPage, bonusState] = await Promise.all([
      service.getBalance(user.id),
      service.getLedgerEntries({ userId: user.id, limit: 20 }),
      service.getBonusState(user.id),
    ]);

    return new Response(
      JSON.stringify({
        balance,
        ledgerPage,
        bonusState,
      }),
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching tokens view data:", error);
    if (error instanceof ForbiddenError) {
      return new Response(JSON.stringify({ error: error.message }), { status: 403 });
    }
    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
  }
};
