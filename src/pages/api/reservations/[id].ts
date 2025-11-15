import { z } from "zod";
import type { APIRoute } from "astro";

import { ReservationsService } from "../../../../lib/services/reservations.service";
import { AppError } from "../../../../lib/services/errors.service";
import { createApiSuccessResponse, createApiErrorResponse } from "../../../../lib/api/responses";

export const prerender = false;

const uuidSchema = z.string().uuid();

export const GET: APIRoute = async ({ params, locals }) => {
  const { user } = locals;
  if (!user) {
    return createApiErrorResponse(401, "UNAUTHORIZED", "User not authenticated.");
  }

  const parseResult = uuidSchema.safeParse(params.id);
  if (!parseResult.success) {
    return createApiErrorResponse(400, "INVALID_PARAM", "Invalid reservation ID format.");
  }
  const reservationId = parseResult.data;

  const reservationsService = new ReservationsService(locals.supabase);

  try {
    const reservationDetails = await reservationsService.getReservationDetails(reservationId, user.id);
    return createApiSuccessResponse(200, reservationDetails);
  } catch (error) {
    if (error instanceof AppError) {
      return createApiErrorResponse(error.status, error.code, error.message);
    }
    console.error("Unexpected error fetching reservation:", error);
    return createApiErrorResponse(500, "INTERNAL_SERVER_ERROR", "An unexpected error occurred.");
  }
};

