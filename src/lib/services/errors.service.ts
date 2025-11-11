/**
 * @file Centralized error classes for the application.
 * @licence MIT
 */

/**
 * Base class for all application-specific errors.
 * It ensures that all custom errors include an HTTP status code and a specific error code string.
 */
export class AppError extends Error {
  public readonly status: number;
  public readonly code: string;

  constructor(message: string, status: number, code: string) {
    super(message);
    this.status = status;
    this.code = code;
    this.name = this.constructor.name;
  }
}

// 4xx Client Errors
export class BadRequestError extends AppError {
  constructor(message: string = "Bad Request") {
    super(message, 400, "BAD_REQUEST");
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = "Unauthorized") {
    super(message, 401, "UNAUTHORIZED");
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = "Forbidden") {
    super(message, 403, "FORBIDDEN");
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = "Not Found") {
    super(message, 404, "NOT_FOUND");
  }
}

export class ConflictError extends AppError {
  constructor(message: string = "Conflict") {
    super(message, 409, "CONFLICT");
  }
}

// 5xx Server Errors
export class InternalServerError extends AppError {
  constructor(message: string = "Internal Server Error") {
    super(message, 500, "INTERNAL_SERVER_ERROR");
  }
}

/**
 * Represents an error that occurs during a Supabase query.
 * This could be a network error, a database constraint violation, or other issues.
 */
export class SupabaseQueryError extends InternalServerError {
  public readonly cause: unknown;
  public readonly dbCode?: string;

  constructor(message: string, dbCode?: string, cause?: unknown) {
    super(message);
    this.cause = cause;
    this.dbCode = dbCode;
  }
}
