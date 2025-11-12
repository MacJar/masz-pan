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

  const {
    data: { session },
  } = await supabase.auth.getSession();
  context.locals.session = session;
  context.locals.user = session?.user ?? null;

  const response = await next();

  return response;
});
