import type { APIRoute } from "astro";
import { createSupabaseServerClient } from "../../../db/supabase.client";
import { ZodError } from "zod";
import { registerSchema } from "@/lib/schemas/auth.schema";

export const prerender = false;

export const POST: APIRoute = async ({ request, cookies, url }) => {
  try {
    const body = await request.json();
    const { email, password } = registerSchema.parse(body);

    const supabase = createSupabaseServerClient({ cookies, headers: request.headers });

    const correctedOrigin = url.origin.replace("127.0.0.1", "localhost");

    // The redirect URL should point to the callback route.
    // The callback will exchange the code for a session and redirect to the 'next' URL.
    const emailRedirectTo = new URL("/api/auth/callback?next=/profile", correctedOrigin).toString();

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo,
      },
    });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
      });
    }

    return new Response(JSON.stringify({ user: data.user }), {
      status: 200,
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return new Response(JSON.stringify({ error: error.errors.map((e) => e.message).join(", ") }), {
        status: 400,
      });
    }
    // eslint-disable-next-line no-console
    console.error("Register endpoint error:", error);
    return new Response(JSON.stringify({ error: "Wystąpił wewnętrzny błąd serwera." }), {
      status: 500,
    });
  }
};
