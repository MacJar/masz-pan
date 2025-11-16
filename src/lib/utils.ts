import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

function resolveSupabaseUrl(): string | undefined {
  if (typeof window !== "undefined" && window.__SUPABASE_URL) {
    return window.__SUPABASE_URL;
  }

  return import.meta.env.SUPABASE_URL;
}

export function getToolImagePublicUrl(storageKey: string): string {
  const supabaseUrl = resolveSupabaseUrl();
  if (!supabaseUrl) {
    // eslint-disable-next-line no-console
    console.warn("Supabase URL is not defined, returning empty string for tool image URL.");
    return "";
  }

  const normalizedBase = supabaseUrl.replace(/\/$/, "");
  const normalizedKey = storageKey.replace(/^\//, "");

  return `${normalizedBase}/storage/v1/object/public/tool_images/${normalizedKey}`;
}
