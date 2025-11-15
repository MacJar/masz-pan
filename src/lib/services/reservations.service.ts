import type { SupabaseClient } from "../../db/supabase.client";
import type { CreateReservationCommand, GetReservationsQuerySchema } from "../schemas/reservation.schema";
import type { Reservation, ReservationContactsDto, ReservationDetailsDto, ReservationListPageDTO } from "../../types";
import {
  ForbiddenError,
  NotFoundError,
  ConflictError,
  UnprocessableEntityError,
  InternalServerError,
} from "./errors.service";
import { z } from "zod";
import type { ReservationDTO, ReservationStatus, ReservationTransitionResponseDto } from "../../types";
import { ReservationTransitionCommandSchema } from "../schemas/reservation.schema";

type ReservationTransitionCommand = z.infer<typeof ReservationTransitionCommandSchema>;

const authorizationMap: Record<ReservationStatus, { allowedActors: ("owner" | "borrower")[] }> = {
  requested: { allowedActors: ["owner", "borrower"] },
  owner_accepted: { allowedActors: ["borrower"] },
  borrower_confirmed: { allowedActors: ["owner", "borrower"] },
  picked_up: { allowedActors: ["owner"] },
  returned: { allowedActors: ["owner", "borrower"] },
  cancelled: { allowedActors: [] },
  rejected: { allowedActors: [] },
};

export class ReservationsService {
  private supabase: SupabaseClient;

  constructor(supabase: SupabaseClient) {
    this.supabase = supabase;
  }

  async createReservation(command: CreateReservationCommand, borrowerId: string): Promise<Reservation> {
    const { tool_id, owner_id } = command;

    if (borrowerId === owner_id) {
      throw new ForbiddenError("User cannot reserve their own tool");
    }

    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("id, owner_id, status")
      .eq("id", tool_id)
      .single();

    if (toolError || !tool) {
      throw new NotFoundError("Tool not found or not available for reservation");
    }

    if (tool.owner_id !== owner_id) {
      throw new NotFoundError("Tool owner mismatch");
    }

    if (tool.status !== "active") {
      throw new ConflictError("Tool is not available for reservation");
    }

    const { data: existingReservation, error: reservationError } = await this.supabase
      .from("reservations")
      .select("id")
      .eq("tool_id", tool_id)
      .in("status", ["requested", "owner_accepted", "borrower_confirmed", "picked_up"])
      .maybeSingle();

    if (reservationError) {
      throw reservationError;
    }

    if (existingReservation) {
      throw new ConflictError("Tool already has an active reservation");
    }

    const { data: newReservation, error: createError } = await this.supabase
      .from("reservations")
      .insert({
        tool_id,
        owner_id,
        borrower_id: borrowerId,
        status: "requested",
      })
      .select()
      .single();

    if (createError || !newReservation) {
      throw new Error("Failed to create reservation");
    }

    return newReservation as Reservation;
  }

  async getReservationDetails(reservationId: string, userId: string): Promise<ReservationDetailsDto> {
    const { data, error } = await this.supabase
      .from("reservations")
      .select(
        `
        id,
        status,
        agreed_price_tokens,
        owner_id,
        borrower_id,
        created_at,
        updated_at,
        tool:tools (
          id,
          name
        )
      `
      )
      .eq("id", reservationId)
      .or(`owner_id.eq.${userId},borrower_id.eq.${userId}`)
      .single();

    if (error || !data) {
      // Log the actual error for debugging, but don't expose details to the client.
      console.error("Error fetching reservation details:", error);
      throw new NotFoundError("Reservation not found or you do not have permission to view it.");
    }

    // The type assertion is necessary because Supabase's inferred type for relations can be an array.
    // The `.single()` call ensures it's an object. The check for `!data.tool` handles the case where the relation is empty.
    const toolData = Array.isArray(data.tool) ? data.tool[0] : data.tool;
    if (!toolData) {
      console.error("Inconsistent data: Reservation exists but related tool not found.");
      throw new NotFoundError("Associated tool not found for this reservation.");
    }

    return {
      id: data.id,
      status: data.status,
      agreedPriceTokens: data.agreed_price_tokens,
      tool: {
        id: toolData.id,
        name: toolData.name,
      },
      ownerId: data.owner_id,
      borrowerId: data.borrower_id,
      createdAt: data.created_at,
      updatedAt: data.updated_at,
    };
  }

  async listUserReservations(
    userId: string,
    query: z.infer<typeof GetReservationsQuerySchema>
  ): Promise<ReservationListPageDTO> {
    const { role, status, limit, cursor } = query;

    let decodedCursor: { created_at: string; id: string } | undefined;
    if (cursor) {
      try {
        const decodedString = Buffer.from(cursor, "base64").toString("ascii");
        decodedCursor = JSON.parse(decodedString);
      } catch (error) {
        // Invalid cursor, ignore and fetch from the beginning
      }
    }

    let queryBuilder = this.supabase
      .from("reservations")
      .select(
        `
        *,
        tool:tools(id, name),
        borrower:profiles!reservations_borrower_id_fkey(id, username),
        owner:profiles!reservations_owner_id_fkey(id, username)
      `
      )
      .eq(role === "owner" ? "owner_id" : "borrower_id", userId)
      .order("created_at", { ascending: false })
      .order("id", { ascending: false }) // Tie-breaker for stable sorting
      .limit(limit + 1); // Fetch one extra to check for next page

    if (status) {
      const statusArray = Array.isArray(status) ? status : [status];
      queryBuilder = queryBuilder.in("status", statusArray);
    }

    if (decodedCursor) {
      queryBuilder = queryBuilder.lt("created_at", decodedCursor.created_at);
      // This is a simplified version. A robust implementation
      // would handle cases where created_at is identical.
      // For now, we rely on created_at + id sorting.
      // A full keyset pagination implementation would look like:
      // .or(`created_at.lt.${decodedCursor.created_at},and(created_at.eq.${decodedCursor.created_at},id.lt.${decodedCursor.id})`)
    }

    const { data, error } = await queryBuilder;

    if (error) {
      console.error("Error fetching reservations:", error);
      throw new Error("Could not fetch reservations.");
    }

    const hasNextPage = data.length > limit;
    const items = hasNextPage ? data.slice(0, limit) : data;

    let next_cursor: string | null = null;
    if (hasNextPage) {
      const lastItem = items[items.length - 1];
      const cursorPayload = JSON.stringify({
        created_at: lastItem.created_at,
        id: lastItem.id,
      });
      next_cursor = Buffer.from(cursorPayload).toString("base64");
    }

    return {
      items: items,
      next_cursor,
    };
  }

  async transitionReservationState(
    reservationId: string,
    actorId: string,
    command: ReservationTransitionCommand
  ): Promise<ReservationTransitionResponseDto> {
    // 1. Fetch reservation
    const { data: reservation, error: fetchError } = await this.supabase
      .from("reservations")
      .select("*")
      .eq("id", reservationId)
      .single();

    if (fetchError || !reservation) {
      throw new NotFoundError("Reservation not found");
    }

    // 2. Authorize user
    const isOwner = reservation.owner_id === actorId;
    const isBorrower = reservation.borrower_id === actorId;

    if (!isOwner && !isBorrower) {
      throw new ForbiddenError("You are not authorized to perform this action.");
    }

    const actorRole = isOwner ? "owner" : "borrower";
    const allowedActors = authorizationMap[reservation.status as ReservationStatus]?.allowedActors;
    if (!allowedActors?.includes(actorRole)) {
      throw new ForbiddenError(`As ${actorRole}, you cannot transition from ${reservation.status}.`);
    }

    // 3. Call RPC
    const { error: rpcError } = await this.supabase.rpc("reservation_transition", {
      p_reservation_id: reservationId,
      p_new_status: command.new_status,
      p_price_tokens: command.price_tokens,
    });

    if (rpcError) {
      if (rpcError.code === "P0001") {
        // RAISE EXCEPTION in PL/pgSQL
        if (rpcError.message.includes("is not a valid transition")) {
          throw new ConflictError(rpcError.message);
        }
        if (rpcError.message.includes("Not enough tokens")) {
          throw new UnprocessableEntityError(rpcError.message);
        }
      }
      throw new InternalServerError(`State transition failed: ${rpcError.message}`);
    }

    // 4. Fetch updated reservation
    const { data: updatedReservation, error: updatedFetchError } = (await this.supabase
      .from("reservations")
      .select("*")
      .eq("id", reservationId)
      .single()) as { data: ReservationDTO | null; error: unknown };

    if (updatedFetchError || !updatedReservation) {
      throw new InternalServerError("Failed to fetch updated reservation.");
    }

    return { reservation: updatedReservation };
  }

  /**
   * Cancels a reservation.
   *
   * @param reservationId - The ID of the reservation to cancel.
   * @param userId - The ID of the user attempting to cancel the reservation.
   * @param reason - An optional reason for cancellation.
   * @returns The updated reservation object.
   * @throws {NotFoundError} If the reservation is not found.
   * @throws {ForbiddenError} If the user is not authorized to cancel the reservation.
   * @throws {ConflictError} If the reservation is not in a cancellable state.
   * @throws {InternalServerError} If the database operation fails.
   */
  async cancelReservation(reservationId: string, userId: string, reason?: string): Promise<Reservation> {
    // 1. Fetch reservation
    const { data: reservation, error: fetchError } = await this.supabase
      .from("reservations")
      .select("*")
      .eq("id", reservationId)
      .single();

    if (fetchError || !reservation) {
      throw new NotFoundError("Reservation not found");
    }

    // 2. Authorize user
    const isOwner = reservation.owner_id === userId;
    const isBorrower = reservation.borrower_id === userId;

    if (!isOwner && !isBorrower) {
      throw new ForbiddenError("You are not authorized to cancel this reservation.");
    }

    // 3. Verify reservation state
    const cancellableStates: ReservationStatus[] = ["requested", "owner_accepted", "borrower_confirmed"];
    if (!cancellableStates.includes(reservation.status as ReservationStatus)) {
      throw new ConflictError(`Reservation in status '${reservation.status}' cannot be cancelled.`);
    }

    // 4. Call RPC to transition state
    const { error: rpcError } = await this.supabase.rpc("reservation_transition", {
      p_reservation_id: reservationId,
      p_new_status: "cancelled",
      p_cancelled_reason: reason,
    });

    if (rpcError) {
      // Handle potential custom errors from the RPC function, if any
      if (rpcError.code === "P0001") {
        throw new ConflictError(rpcError.message);
      }
      throw new InternalServerError(`Failed to cancel reservation: ${rpcError.message}`);
    }

    // 5. Fetch and return updated reservation
    const { data: updatedReservation, error: updatedFetchError } = (await this.supabase
      .from("reservations")
      .select("*")
      .eq("id", reservationId)
      .single()) as { data: Reservation | null; error: any };

    if (updatedFetchError || !updatedReservation) {
      throw new InternalServerError("Failed to fetch updated reservation after cancellation.");
    }

    return updatedReservation;
  }

  async getReservationContacts(reservationId: string): Promise<ReservationContactsDto> {
    const { data, error } = await this.supabase.rpc("get_counterparty_contact", {
      p_reservation_id: reservationId,
    });

    if (error) {
      if (error.code === "P0001") {
        // RAISE EXCEPTION from plpgsql
        if (error.message.includes("Reservation not found")) {
          throw new NotFoundError(error.message);
        }
        if (error.message.includes("User is not a party")) {
          throw new ForbiddenError(error.message);
        }
        if (error.message.includes("not in a state to reveal contacts")) {
          throw new ConflictError(error.message);
        }
      }
      // For any other database error, throw a generic server error
      throw new InternalServerError(`Failed to retrieve contacts: ${error.message}`);
    }

    if (!data || data.length === 0) {
      throw new InternalServerError("Failed to retrieve contacts: RPC returned no data.");
    }

    // The RPC function returns a table with one row, so we access the first element
    const contacts = data[0];

    return {
      owner_email: contacts.owner_email,
      borrower_email: contacts.borrower_email,
    };
  }
}
