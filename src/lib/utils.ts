import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getToolImagePublicUrl(storageKey: string): string {
  const supabaseUrl = import.meta.env.SUPABASE_URL;
  if (!supabaseUrl) {
    console.warn("SUPABASE_URL is not defined, returning empty string for tool image URL.");
    return "";
  }
  return `${supabaseUrl}/storage/v1/object/public/tool_images/${storageKey}`;
}
