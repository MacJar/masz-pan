
import type { APIRoute } from 'astro';
import { CreateReservationSchema } from '../../../lib/schemas/reservation.schema';
import { ReservationsService } from '../../../lib/services/reservations.service';
import { AppError } from '../../../lib/services/errors.service';
import { GetReservationsQuerySchema } from '../../../lib/schemas/reservation.schema';
import { handleApiError } from '../../../lib/services/errors.service';

export const prerender = false;

export const POST: APIRoute = async ({ request, locals }) => {
  const { user } = locals;

  if (!user) {
    return new Response(JSON.stringify({ message: 'Unauthorized' }), { status: 401 });
  }

  try {
    const body = await request.json();
    const validation = CreateReservationSchema.safeParse(body);

    if (!validation.success) {
      return new Response(JSON.stringify({ message: 'Invalid input', errors: validation.error.flatten() }), {
        status: 400,
      });
    }

    const command = validation.data;
    const reservationsService = new ReservationsService(locals.supabase);
    const reservation = await reservationsService.createReservation(command, user.id);

    return new Response(JSON.stringify(reservation), { status: 201 });
  } catch (error) {
    if (error instanceof AppError) {
      return new Response(JSON.stringify({ message: error.message }), { status: error.status });
    }
    console.error(error);
    return new Response(JSON.stringify({ message: 'Internal Server Error' }), { status: 500 });
  }
};

export const GET: APIRoute = async ({ locals, request }) => {
  const { session, supabase } = locals;
  if (!session?.user) {
    return new Response(JSON.stringify({ message: 'Unauthorized' }), { status: 401 });
  }

  const url = new URL(request.url);
  const queryParams = Object.fromEntries(url.searchParams.entries());

  // Handling status which can be an array
  if (url.searchParams.has('status')) {
    const statusValues = url.searchParams.getAll('status');
    queryParams.status = statusValues.length > 1 ? statusValues : statusValues[0];
  }

  const validation = GetReservationsQuerySchema.safeParse(queryParams);

  if (!validation.success) {
    return new Response(
      JSON.stringify({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid query parameters',
          details: validation.error.flatten(),
        },
      }),
      { status: 400 }
    );
  }

  try {
    const service = new ReservationsService(supabase);
    const result = await service.listUserReservations(session.user.id, validation.data);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return handleApiError(error);
  }
};
