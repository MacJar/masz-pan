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
  public readonly details?: unknown;
  constructor(message = "Bad Request", details?: unknown) {
    super(message, 400, "BAD_REQUEST");
    this.details = details;
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized") {
    super(message, 401, "UNAUTHORIZED");
  }
}

export class ForbiddenError extends AppError {
  constructor(message = "Forbidden") {
    super(message, 403, "FORBIDDEN");
  }
}

export class NotFoundError extends AppError {
  constructor(message = "Not Found") {
    super(message, 404, "NOT_FOUND");
  }
}

export class ConflictError extends AppError {
  constructor(message = "Conflict") {
    super(message, 409, "CONFLICT");
  }
}

export class UnprocessableEntityError extends AppError {
  constructor(message = "Unprocessable Entity") {
    super(message, 422, "UNPROCESSABLE_ENTITY");
  }
}

export class ToolHasActiveReservationsError extends ConflictError {
  constructor(message = "Tool has active reservations and cannot be archived.") {
    super(message);
    this.code = "TOOL_HAS_ACTIVE_RESERVATIONS";
  }
}

export class AlreadyAwardedError extends ConflictError {
  constructor(message = "Bonus already awarded.") {
    super(message);
    this.name = "AlreadyAwardedError";
    this.code = "ALREADY_AWARDED";
  }
}

export class LimitReachedError extends ConflictError {
  constructor(message = "The limit for this action has been reached.") {
    super(message);
    this.name = "LimitReachedError";
    this.code = "LIMIT_REACHED";
  }
}

// 5xx Server Errors
export class InternalServerError extends AppError {
  constructor(message = "Internal Server Error") {
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
