import { defineMiddleware } from "astro:middleware";
import { createServerClient } from "@supabase/ssr";

import type { Database } from "../db/database.types.ts";

const supabaseUrl = import.meta.env.SUPABASE_URL;
const supabaseAnonKey = import.meta.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Supabase environment variables are not configured.");
}

export const onRequest = defineMiddleware(async (context, next) => {
  const supabase = createServerClient<Database>(supabaseUrl, supabaseAnonKey, {
    cookies: {
      get: (key) => context.cookies.get(key)?.value,
      set: (key, value, options) => context.cookies.set(key, value, options),
      remove: (key, options) => context.cookies.delete(key, options),
    },
  });

  context.locals.supabase = supabase;

  let {
    data: { session },
  } = await supabase.auth.getSession();

  // In development, if AUTH_BYPASS is true and a user ID is provided, create a mock session.
  const isDevAuthBypass =
    import.meta.env.AUTH_BYPASS === "true" && import.meta.env.AUTH_BYPASS_USER_ID && import.meta.env.DEV;

  if (isDevAuthBypass && !session) {
    session = {
      access_token: "mock-token-never-expires",
      refresh_token: "mock-refresh-token",
      expires_in: 9999999999,
      expires_at: 9999999999,
      token_type: "bearer",
      user: {
        id: import.meta.env.AUTH_BYPASS_USER_ID,
        app_metadata: { provider: "email", providers: ["email"] },
        user_metadata: { name: "Dev User" },
        aud: "authenticated",
        created_at: new Date().toISOString(),
        email: "dev-user@example.com",
      } as any, // Cast to any to avoid filling all User properties
    };
  }

  context.locals.session = session;
  context.locals.user = session?.user ?? null;

  const { pathname } = context.url;

  // --- Redirection logic ---

  // List of paths that require authentication
  const protectedPaths = ["/profile", "/tools/my", "/tools/new", "/tools/my-reservations"];
  const protectedApiPaths = [
    "/api/tools", 
    "/api/reservations", 
    "/api/profile"
];

  const isProtectedPath =
    protectedPaths.some((p) => pathname.startsWith(p)) ||
    protectedApiPaths.some((p) => pathname.startsWith(p) && !pathname.startsWith("/api/profile/geocode"));

  // 1. Handle unauthenticated users trying to access protected routes
  if (!session && isProtectedPath) {
    if (pathname.startsWith("/api/")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }
    return context.redirect("/", 303);
  }

  // 2. Handle authenticated users with incomplete profiles
  if (session) {
    // Paths accessible even with an incomplete profile
    const allowedPaths = ["/profile", "/api/profile"];
    const isAsset = /\.(gif|jpeg|jpg|png|svg|webp|js|css|woff|woff2|ttf|eot)$/i.test(pathname);

    if (!allowedPaths.some((p) => pathname.startsWith(p)) && !isAsset) {
      const { data: profile, error } = await supabase
        .from("profiles")
        .select("username, rodo_consent")
        .eq("id", session.user.id)
        .single();
        
      // Fail open in case of a DB error during profile fetch
      if (error && error.code !== 'PGRST116') { // PGRST116 = 0 rows, which is a valid case
        console.error("Middleware profile fetch error:", error.message);
      } else {
        const isProfileComplete = profile && profile.username && profile.rodo_consent === true;
  
        if (!isProfileComplete) {
          return context.redirect("/profile", 303);
        }
      }
    }
  }

  const response = await next();

  return response;
});
