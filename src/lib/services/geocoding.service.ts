import { z } from "zod";
import type { ProfileGeocodeResultDTO } from "../../types.ts";

const GEOCODE_TIMEOUT_MS = 3000;

export class GeocodingError extends Error {
  readonly cause?: unknown;
  constructor(message: string, cause?: unknown) {
    super(message);
    this.name = "GeocodingError";
    this.cause = cause;
  }
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
  } catch (err) {
    inMemoryCache.set(normalized, null);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}


