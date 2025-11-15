import { z } from "zod";

export const CreateReservationSchema = z.object({
  tool_id: z.string().uuid(),
  owner_id: z.string().uuid(),
  borrower_id: z.string().uuid(),
  // owner_id will be derived from the tool
});

export type CreateReservationCommand = z.infer<typeof CreateReservationSchema>;

const ReservationStatusEnum = z.enum([
  "requested",
  "owner_accepted",
  "borrower_confirmed",
  "picked_up",
  "returned",
  "cancelled",
  "rejected",
]);

export const GetReservationsQuerySchema = z.object({
  role: z.enum(["owner", "borrower"]),
  status: z.union([ReservationStatusEnum, z.array(ReservationStatusEnum)]).optional(),
  limit: z.coerce.number().int().min(1).max(50).optional().default(20),
  cursor: z.string().optional(),
});

export const ReservationTransitionCommandSchema = z
  .object({
    new_status: z.enum(["owner_accepted", "borrower_confirmed", "picked_up", "returned", "cancelled", "rejected"]),
    price_tokens: z.number().int().positive().optional(),
    cancelled_reason: z.string().optional(),
  })
  .refine(
    (data) => {
      if (data.new_status === "owner_accepted") {
        return data.price_tokens !== undefined;
      }
      return true;
    },
    {
      message: "price_tokens is required when new_status is owner_accepted",
      path: ["price_tokens"],
    }
  );

export const CancelReservationSchema = z.object({
  cancelled_reason: z.string().max(500, "Reason cannot be longer than 500 characters.").optional(),
});
