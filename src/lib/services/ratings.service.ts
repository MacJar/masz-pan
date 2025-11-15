
import type { SupabaseClient } from "@/db/supabase.client";
import {
  ConflictError,
  ForbiddenError,
  NotFoundError,
  UnprocessableEntityError,
} from "@/lib/services/errors.service";
import type { Rating } from "@/types";

export interface CreateRatingCommand {
  reservationId: string;
  stars: number;
  raterId: string;
}

/**
 * Creates a new rating for a reservation.
 *
 * @param supabase - The Supabase client instance.
 * @param command - The command object containing rating details.
 * @returns The newly created rating object.
 * @throws {NotFoundError} If the reservation is not found.
 * @throws {UnprocessableEntityError} If the reservation is not in 'returned' state.
 * @throws {ForbiddenError} If the rater is not a participant in the reservation.
 * @throws {ConflictError} If the rater has already rated this reservation.
 */
export async function createRating(
  supabase: SupabaseClient,
  command: CreateRatingCommand,
): Promise<Rating> {
  const { reservationId, stars, raterId } = command;

  // 1. Fetch reservation from the database
  const { data: reservation, error: reservationError } = await supabase
    .from("reservations")
    .select("id, owner_id, borrower_id, status")
    .eq("id", reservationId)
    .single();

  if (reservationError || !reservation) {
    throw new NotFoundError("Reservation not found.");
  }

  // 2. Verify reservation status is 'returned'
  if (reservation.status !== "returned") {
    throw new UnprocessableEntityError("Rating can only be added to a returned reservation.");
  }

  // 3. Verify that raterId is a participant
  const isOwner = reservation.owner_id === raterId;
  const isBorrower = reservation.borrower_id === raterId;

  if (!isOwner && !isBorrower) {
    throw new ForbiddenError("You are not a participant in this reservation.");
  }

  // 4. Check if the user has already rated this reservation
  const { data: existingRating, error: existingRatingError } = await supabase
    .from("ratings")
    .select("id")
    .eq("reservation_id", reservationId)
    .eq("rater_id", raterId)
    .maybeSingle();

  if (existingRatingError) {
    throw existingRatingError;
  }

  if (existingRating) {
    throw new ConflictError("You have already rated this reservation.");
  }

  // 5. Determine the rated_user_id
  const ratedUserId = isOwner ? reservation.borrower_id : reservation.owner_id;

  // 6. Insert the new rating
  const { data: newRating, error: insertError } = await supabase
    .from("ratings")
    .insert({
      reservation_id: reservationId,
      rater_id: raterId,
      rated_user_id: ratedUserId,
      stars: stars,
    })
    .select()
    .single();

  if (insertError) {
    throw insertError;
  }

  return newRating;
}

