import type { ApiErrorDTO } from "../../types.ts";
import { AppError } from "../services/errors.service.ts";

export const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
} as const;

export function jsonOk<T>(body: T): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: JSON_HEADERS,
  });
}

export function jsonCreated<T>(body: T): Response {
  return new Response(JSON.stringify(body), {
    status: 201,
    headers: JSON_HEADERS,
  });
}

export function jsonError(
  status: number,
  code: string,
  message: string,
  details?: ApiErrorDTO["error"]["details"]
): Response {
  const payload: ApiErrorDTO = {
    error: sanitizeErrorPayload(code, message, details),
  };

  return new Response(JSON.stringify(payload), {
    status,
    headers: JSON_HEADERS,
  });
}

function sanitizeErrorPayload(
  code: string,
  message: string,
  details?: ApiErrorDTO["error"]["details"]
): ApiErrorDTO["error"] {
  if (typeof details === "undefined") {
    return { code, message };
  }

  return { code, message, details };
}

export function apiSuccess<T>(status: 200 | 201, data: T): Response {
  if (status === 201) {
    return jsonCreated(data);
  }
  return jsonOk(data);
}

export function apiError(error: unknown): Response {
  if (error instanceof AppError) {
    const details = (error as AppError & { details?: unknown }).details;
    return jsonError(error.status, error.code, error.message, details);
  }

  // TODO: Add logging for unexpected errors
  return jsonError(500, "INTERNAL_SERVER_ERROR", "An unexpected error has occurred.");
}

/**
 * Small helper for frontend API clients.
 * - Parses JSON when available
 * - On non-2xx responses tries to interpret payload as ApiErrorDTO and throws AppError
 */
export async function handleApiResponse<T>(response: Response): Promise<T> {
  const text = await response.text();
  const isJson = response.headers.get("content-type")?.includes("application/json");
  const parsed = isJson && text ? (JSON.parse(text) as unknown) : null;

  if (!response.ok) {
    const errorPayload = (parsed as ApiErrorDTO | null)?.error;

    if (errorPayload) {
      throw new AppError(errorPayload.message, response.status, errorPayload.code);
    }

    throw new AppError("Unexpected error", response.status, "INTERNAL_SERVER_ERROR");
  }

  // For 204 / empty body, parsed will be null – caller decides how to interpret it
  return (parsed as T) ?? ({} as T);
}
