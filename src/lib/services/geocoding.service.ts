import { z } from "zod";
import type { ProfileGeocodeResultDTO } from "../../types.ts";
import { BadRequestError, NotFoundError, SupabaseQueryError, UnprocessableEntityError } from "./errors.service.ts";
import type { SupabaseClient } from "../db/supabase.client.ts";

const GEOCODE_TIMEOUT_MS = 3000;

// Domyślne wartości geolokalizacji (kod pocztowy 00-950, Warszawa)
const DEFAULT_POSTAL_CODE = "00-950";
const DEFAULT_LOCATION_HEX = "0101000020E6100000865AD3BCE3F4344075931804561E4A40";

export class GeocodingError extends Error {
  readonly cause?: unknown;
  constructor(message: string, cause?: unknown) {
    super(message);
    this.name = "GeocodingError";
    this.cause = cause;
  }
}

/**
 * Zwraca domyślne wartości geolokalizacji.
 * Używane jako fallback gdy geokodowanie nie działa.
 * Współrzędne odpowiadają kodowi pocztowemu 00-950 (Warszawa).
 */
export function getDefaultLocation(): ProfileGeocodeResultDTO {
  // Domyślne współrzędne dla kodu pocztowego 00-950 (Warszawa)
  // Hex string 0101000020E6100000865AD3BCE3F4344075931804561E4A40 odpowiada tym współrzędnym
  const lon = 21.012229;
  const lat = 52.229676;
  
  return {
    location_geog: {
      type: "Point",
      coordinates: [lon, lat], // [lon, lat] dla kodu pocztowego 00-950
    },
  };
}

/**
 * Zwraca domyślne współrzędne jako obiekt z lon i lat.
 * Używane do przekazania do funkcji PostGIS.
 */
export function getDefaultCoordinates(): { lon: number; lat: number } {
  return {
    lon: 21.012229,
    lat: 52.229676,
  };
}

/**
 * Zwraca domyślny kod pocztowy.
 */
export function getDefaultPostalCode(): string {
  return DEFAULT_POSTAL_CODE;
}

const GeocodeResponseSchema = z.object({
  lon: z.number(),
  lat: z.number(),
});

const inMemoryCache = new Map<string, ProfileGeocodeResultDTO | null>();

export async function geocodeLocation(query: string): Promise<ProfileGeocodeResultDTO | null> {
  const normalized = query.trim().toLowerCase();
  if (normalized.length === 0) {
    return null;
  }

  const cached = inMemoryCache.get(normalized);
  if (typeof cached !== "undefined") {
    return cached;
  }

  const url = import.meta.env.GEOCODING_URL;
  const key = import.meta.env.GEOCODING_KEY;
  if (!url || !key) {
    inMemoryCache.set(normalized, null);
    return null;
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), GEOCODE_TIMEOUT_MS);
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${key}`,
      },
      body: JSON.stringify({ q: query }),
      signal: controller.signal,
    });
    if (!res.ok) {
      inMemoryCache.set(normalized, null);
      return null;
    }
    const json = await res.json();
    const parsed = GeocodeResponseSchema.safeParse(json);
    if (!parsed.success) {
      inMemoryCache.set(normalized, null);
      return null;
    }
    const { lon, lat } = parsed.data;
    const result: ProfileGeocodeResultDTO = {
      location_geog: { type: "Point", coordinates: [lon, lat] },
    };
    inMemoryCache.set(normalized, result);
    return result;
  } catch {
    inMemoryCache.set(normalized, null);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

export async function geocodeAndSaveForProfile(
  userId: string,
  supabase: SupabaseClient
): Promise<ProfileGeocodeResultDTO> {
  const { data: profile, error } = await supabase.from("profiles").select().eq("id", userId).single();

  if (error) {
    throw new SupabaseQueryError("Failed to fetch profile", error.code, error);
  }

  if (!profile) {
    throw new NotFoundError("Profile not found");
  }

  const { location_text } = profile;
  if (!location_text || location_text.trim().length === 0) {
    throw new BadRequestError("Profile location_text is empty");
  }

  const geocoded = await geocodeLocation(location_text);
  if (!geocoded) {
    throw new UnprocessableEntityError("Could not geocode location_text");
  }

  const { error: updateError } = await supabase
    .from("profiles")
    .update({ location_geog: geocoded.location_geog })
    .eq("id", userId);

  if (updateError) {
    throw new SupabaseQueryError("Failed to update profile", updateError.code, updateError);
  }

  return geocoded;
}
