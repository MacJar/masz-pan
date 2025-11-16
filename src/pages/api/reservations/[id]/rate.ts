import { APIRoute } from "astro";
import { z } from "zod";
import { jsonOk, jsonError } from "@/lib/api/responses";

const ratingSchema = z.object({
  rating: z.number().int().min(1).max(5),
});

export const POST: APIRoute = async ({ request, cookies, params, locals }) => {
  const reservationId = params.id;
  if (!reservationId) {
    return jsonError(400, "BAD_REQUEST", "Reservation ID is required");
  }

  const { supabase, user } = locals;

  if (!user) {
    return jsonError(401, "UNAUTHORIZED", "User not authenticated");
  }

  let parsedBody;
  try {
    const body = await request.json();
    parsedBody = ratingSchema.parse(body);
  } catch (error) {
    return jsonError(400, "BAD_REQUEST", "Invalid request body");
  }

  const { rating } = parsedBody;

  try {
    // 1. Fetch the reservation
    const { data: reservation, error: reservationError } = await supabase
      .from("reservations")
      .select("owner_id, borrower_id, status")
      .eq("id", reservationId)
      .single();

    if (reservationError || !reservation) {
      return jsonError(404, "NOT_FOUND", "Reservation not found");
    }

    // 2. Check permissions and status
    const { owner_id, borrower_id, status } = reservation;
    if (user.id !== owner_id && user.id !== borrower_id) {
      return jsonError(403, "FORBIDDEN", "You are not a party to this reservation");
    }

    if (status !== "returned") {
      return jsonError(403, "FORBIDDEN", "You can only rate completed reservations");
    }

    // 3. Determine who is being rated
    const rater_id = user.id;
    const ratee_id = user.id === owner_id ? borrower_id : owner_id;

    // 4. Insert the rating
    const { error: insertError } = await supabase.from("ratings").insert({
      reservation_id: reservationId,
      rater_id,
      rated_user_id: ratee_id,
      stars: rating,
    });

    if (insertError) {
      // Handle unique constraint violation (user already rated)
      if (insertError.code === "23505") {
        return jsonError(403, "FORBIDDEN", "You have already rated this reservation");
      }
      console.error("Error inserting rating:", insertError);
      return jsonError(500, "INTERNAL_SERVER_ERROR", "Could not save the rating");
    }

    return jsonOk({ success: true });
  } catch (error) {
    console.error(error);
    return jsonError(500, "INTERNAL_SERVER_ERROR", "An unexpected error occurred");
  }
};
