/// <reference types="astro/client" />

import type { SupabaseClient } from "./db/supabase.client.ts";

declare global {
  namespace App {
    interface Locals {
      supabase: SupabaseClient;
    }
  }
}

interface ImportMetaEnv {
  readonly SUPABASE_URL: string;
  readonly SUPABASE_KEY: string;
  readonly OPENROUTER_API_KEY: string;
  // TODO: Remove this when we have a proper auth system
  readonly AUTH_BYPASS: string; // 'true' to bypass Supabase Auth on server
  readonly AUTH_BYPASS_USER_ID: string; // mock user id when bypassing
  readonly SUPABASE_SERVICE_ROLE_KEY: string; // optional: enables RLS-bypassing server writes (server-only)
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
