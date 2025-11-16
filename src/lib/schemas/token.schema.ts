import { z } from "zod";

export const LedgerKindSchema = z.enum(["debit", "credit", "hold", "release", "transfer", "award"]);

export const GetLedgerEntriesQuerySchema = z.object({
  kind: LedgerKindSchema.optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().positive().max(50).optional().default(20),
});

export const AwardListingBonusPayloadSchema = z.object({
  toolId: z.string().uuid({ message: "Valid tool ID is required" }),
});

export const AwardListingBonusResponseDtoSchema = z.object({
  awarded: z.literal(true),
  amount: z.number().int().positive(),
  toolId: z.string().uuid(),
});

export type AwardListingBonusResponseDto = z.infer<typeof AwardListingBonusResponseDtoSchema>;

export const RescueTokenResponseDtoSchema = z.object({
  awarded: z.literal(true),
  amount: z.literal(1),
  claim_date_cet: z.string(), // YYYY-MM-DD
});

export type RescueTokenResponseDto = z.infer<typeof RescueTokenResponseDtoSchema>;
