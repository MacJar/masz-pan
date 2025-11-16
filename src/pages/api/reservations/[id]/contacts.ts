import type { APIRoute } from "astro";
import { z } from "zod";
import { ReservationsService } from "../../../../lib/services/reservations.service";
import { handleApiError } from "../../../../lib/services/errors.service";

export const prerender = false;

const UuidSchema = z.string().uuid();

export const GET: APIRoute = async (context) => {
  const { locals, params } = context;
  const { supabase, user } = locals;

  if (!user) {
    return new Response(JSON.stringify({ message: "Unauthorized" }), { status: 401 });
  }

  const reservationIdValidation = UuidSchema.safeParse(params.id);
  if (!reservationIdValidation.success) {
    return new Response(JSON.stringify({ message: "Invalid reservation ID format" }), { status: 400 });
  }
  const reservationId = reservationIdValidation.data;

  const reservationsService = new ReservationsService(supabase);

  try {
    const contacts = await reservationsService.getReservationContacts(reservationId, user.id);
    return new Response(JSON.stringify(contacts), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return handleApiError(error);
  }
};

