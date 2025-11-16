import type { APIRoute } from "astro";
import { AppError } from "@/lib/services/errors.service";
import { CreateRatingSchema } from "@/lib/schemas/rating.schema";
import { createRating, type CreateRatingCommand } from "@/lib/services/ratings.service";

export const prerender = false;

export const POST: APIRoute = async ({ request, locals }) => {
  const { session, supabase } = locals;
  if (!session) {
    return new Response(JSON.stringify({ error: { message: "Unauthorized" } }), { status: 401 });
  }

  try {
    const body = await request.json();
    const validation = CreateRatingSchema.safeParse(body);

    if (!validation.success) {
      return new Response(
        JSON.stringify({
          error: {
            message: "Bad Request",
            details: validation.error.flatten(),
          },
        }),
        { status: 400 }
      );
    }

    const { reservation_id, stars } = validation.data;

    const command: CreateRatingCommand = {
      reservationId: reservation_id,
      stars: stars,
      raterId: session.user.id,
    };

    const newRating = await createRating(supabase, command);

    return new Response(JSON.stringify(newRating), { status: 201 });
  } catch (error) {
    if (error instanceof AppError) {
      return new Response(JSON.stringify({ error: { message: error.message, code: error.code } }), {
        status: error.status,
      });
    }

    // eslint-disable-next-line no-console
    console.error("Unexpected error creating rating:", error);
    return new Response(
      JSON.stringify({ error: { message: "Internal Server Error", code: "INTERNAL_SERVER_ERROR" } }),
      { status: 500 }
    );
  }
};
