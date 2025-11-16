
import type { APIRoute } from 'astro';
import { CreateReservationSchema, GetReservationsQuerySchema } from '@/lib/schemas/reservation.schema';
import { ReservationsService } from '@/lib/services/reservations.service';
import { handleApiError } from '@/lib/services/errors.service';

export const prerender = false;

export const POST: APIRoute = async ({ request, locals }) => {
  const { user, supabase } = locals;
  if (!user) {
    return new Response(JSON.stringify({ message: "Unauthorized" }), { status: 401 });
  }

  try {
    const reservationsService = new ReservationsService(supabase);

    const body = await request.json();
    const command = CreateReservationSchema.omit({ borrower_id: true }).parse({
      tool_id: body.tool_id,
      owner_id: body.owner_id,
    });

    const newReservation = await reservationsService.createReservation(command, user.id);

    return new Response(JSON.stringify(newReservation), { status: 201 });
  } catch (error) {
    return handleApiError(error);
  }
};

export const GET: APIRoute = async ({ locals, request }) => {
  const { user, supabase } = locals;
  if (!user) {
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
    const result = await service.listUserReservations(user.id, validation.data);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return handleApiError(error);
  }
};
