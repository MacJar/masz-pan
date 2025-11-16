import type { APIRoute } from "astro";
import { ZodError } from "zod";
import { createSupabaseServerClient } from "../../../db/supabase.client";
import { updatePasswordSchema } from "@/lib/schemas/auth.schema";

export const prerender = false;

export const POST: APIRoute = async ({ request, cookies, locals }) => {
  if (!locals.user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
  }

  try {
    const body = await request.json();
    const { password } = updatePasswordSchema.parse(body);

    const supabase = createSupabaseServerClient({ cookies, headers: request.headers });
    const { error } = await supabase.auth.updateUser({ password });

    if (error) {
      console.error("Update password error:", error.message);
      return new Response(JSON.stringify({ error: "Nie udało się zaktualizować hasła." }), { status: 500 });
    }

    return new Response(JSON.stringify({ message: "Hasło zostało pomyślnie zaktualizowane." }), { status: 200 });

  } catch (error) {
    if (error instanceof ZodError) {
      return new Response(JSON.stringify({ error: error.errors.map((e) => e.message).join(", ") }), { status: 400 });
    }
    console.error("Update password endpoint error:", error);
    return new Response(JSON.stringify({ error: "Wystąpił wewnętrzny błąd serwera." }), { status: 500 });
  }
};

