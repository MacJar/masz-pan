import { TokensService } from "@/lib/services/tokens.service";
import type { APIContext } from "astro";

export const prerender = false;

export async function GET({ locals }: APIContext) {
	const { session, supabase } = locals;

	if (!session?.user) {
		return new Response("Unauthorized", { status: 401 });
	}

	try {
		const balance = await TokensService.getUserBalance(supabase, session.user.id);
		return new Response(JSON.stringify(balance), {
			status: 200,
			headers: { "Content-Type": "application/json" },
		});
	} catch (error) {
		console.error("API Error fetching token balance:", error);
		return new Response("Internal Server Error", { status: 500 });
	}
}
