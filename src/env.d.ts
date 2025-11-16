/// <reference types="astro/client" />

import type { Session, User } from "@supabase/supabase-js";
import type { SupabaseClient } from "./db/supabase.client.ts";

declare global {
  namespace App {
    interface Locals {
      supabase: SupabaseClient;
      session: Session | null;
      user: User | null;
    }
  }
}

interface ImportMetaEnv {
  readonly SUPABASE_URL: string;
  readonly SUPABASE_KEY: string;
  readonly SUPABASE_SERVICE_ROLE_KEY: string;
  readonly GOOGLE_MAPS_API_KEY: string;
  readonly OPENAI_API_KEY: string;
  readonly AUTH_BYPASS?: string; // "true" or "false"
  readonly AUTH_BYPASS_USER_ID?: string; // mock user id when bypassing
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare namespace App {
  interface Locals {
    user?: {
      id: string;
      email?: string;
    };
  }
}

declare global {
  interface Window {
    __SUPABASE_URL?: string;
  }
}