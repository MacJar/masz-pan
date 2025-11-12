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
    return jsonError(error.status, error.code, error.message);
  }

  // TODO: Add logging for unexpected errors
  return jsonError(500, "INTERNAL_SERVER_ERROR", "An unexpected error has occurred.");
}
