import { z } from "zod";
import type { APIRoute } from "astro";
import { ReservationTransitionCommandSchema } from "../../../../lib/schemas/reservation.schema";
import { ReservationsService } from "../../../../lib/services/reservations.service";
import { handleApiError } from "../../../../lib/services/errors.service";

export const prerender = false;

const uuidSchema = z.string().uuid();

export const POST: APIRoute = async ({ params, request, locals }) => {
  const user = locals.user;
  if (!user) {
    return new Response(null, { status: 401 });
  }

  const reservationIdValidation = uuidSchema.safeParse(params.id);
  if (!reservationIdValidation.success) {
    return new Response(JSON.stringify({ error: "Invalid reservation ID" }), { status: 400 });
  }
  const reservationId = reservationIdValidation.data;

  try {
    const command = await request.json();
    const validation = ReservationTransitionCommandSchema.safeParse(command);

    if (!validation.success) {
      return new Response(JSON.stringify({ error: validation.error.flatten() }), { status: 400 });
    }

    const service = new ReservationsService(locals.supabase);
    const result = await service.transitionReservationState(reservationId, user.id, validation.data);

    return new Response(JSON.stringify(result), { status: 200 });
  } catch (error) {
    console.error(`[API] Error transitioning reservation ${reservationId}:`, error);
    return handleApiError(error);
  }
};

