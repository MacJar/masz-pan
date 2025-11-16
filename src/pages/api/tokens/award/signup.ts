import type { APIRoute } from "astro";
import { tokensService } from "@/lib/services/tokens.service";
import { AlreadyAwardedError } from "@/lib/services/errors.service";
import type { AwardSignupResultDTO } from "@/types";

export const prerender = false;

export const POST: APIRoute = async ({ locals }) => {
  const { user, supabase } = locals;

  if (!user || !supabase) {
    return new Response(JSON.stringify({ message: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    await tokensService.awardSignupBonus(supabase, user.id);

    const responseBody: AwardSignupResultDTO = {
      awarded: true,
      amount: 50, // TODO: optionally return actual amount from DB if needed
    };

    return new Response(JSON.stringify(responseBody), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    if (error instanceof AlreadyAwardedError) {
      return new Response(JSON.stringify({ message: error.message }), {
        status: 409,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.error("Failed to award signup bonus:", error);
    return new Response(JSON.stringify({ message: "Internal Server Error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
};
