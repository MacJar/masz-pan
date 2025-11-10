import type { ApiErrorDTO } from "../../types.ts";

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
