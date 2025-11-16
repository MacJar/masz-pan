import type { APIRoute } from "astro";
import { createSupabaseServerClient } from "../../../db/supabase.client";

export const prerender = false;

export const GET: APIRoute = async ({ url, cookies, redirect, request }) => {
  const code = url.searchParams.get("code");
  const next = url.searchParams.get("next") || "/";

  if (!code) {
    // eslint-disable-next-line no-console
    console.error("No code found in callback URL");
    // Redirect to an error page or show an error message
    return redirect("/auth/login?error=Brak kodu weryfikacyjnego");
  }

  const supabase = createSupabaseServerClient({ cookies, headers: request.headers });
  const { error } = await supabase.auth.exchangeCodeForSession(code);

  if (error) {
    // eslint-disable-next-line no-console
    console.error("Error exchanging code for session:", error.message);
    // Redirect to an error page or show an error message
    return redirect(`/auth/login?error=${encodeURIComponent(`Błąd podczas weryfikacji: ${error.message}`)}`);
  }

  return redirect(next);
};
