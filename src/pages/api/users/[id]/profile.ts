import type { APIRoute } from "astro";
import { z } from "zod";
import { profileService } from "@/lib/services/profile.service";

export const prerender = false;

const idSchema = z.string().uuid();

export const GET: APIRoute = async ({ params, locals }) => {
	const validation = idSchema.safeParse(params.id);
	if (!validation.success) {
		return new Response(JSON.stringify({ error: "Invalid user ID" }), { status: 400 });
	}

	const userId = validation.data;
	const { supabase } = locals;

	try {
		const profile = await profileService.getPublicProfile(supabase, userId);

		if (!profile) {
			return new Response(JSON.stringify({ error: "Profile not found" }), { status: 404 });
		}

		return new Response(JSON.stringify(profile));
	} catch (error) {
		console.error("Error fetching public profile:", error);
		return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
	}
};

