import type { APIRoute } from "astro";
import { ReservationsService } from "../../../../lib/services/reservations.service";
import { CancelReservationSchema } from "../../../../lib/schemas/reservation.schema";
import { z } from "zod";
import { handleServiceCall } from "../../../../lib/services/errors.service";

export const prerender = false;

const IdSchema = z.string().uuid();

export const POST: APIRoute = async ({ params, request, locals }) => {
  const { user } = locals;
  if (!user) {
    return new Response(null, { status: 401 });
  }

  const idValidation = IdSchema.safeParse(params.id);
  if (!idValidation.success) {
    return new Response(JSON.stringify({ error: "Invalid reservation ID format" }), { status: 422 });
  }
  const reservationId = idValidation.data;

  let requestBody;
  try {
    requestBody = await request.json();
  } catch (e) {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), { status: 400 });
  }

  const bodyValidation = CancelReservationSchema.safeParse(requestBody);

  if (!bodyValidation.success) {
    return new Response(JSON.stringify({ error: "Invalid request body", details: bodyValidation.error.flatten() }), {
      status: 422,
    });
  }

  const { cancelled_reason } = bodyValidation.data;
  const reservationsService = new ReservationsService(locals.supabase);

  return handleServiceCall(
    () => reservationsService.cancelReservation(reservationId, user.id, cancelled_reason),
    "Successfully cancelled reservation"
  );
};

