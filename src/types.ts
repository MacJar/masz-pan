import type { Tables as Row, TablesInsert as Insert, TablesUpdate as Update, Enums } from "./db/database.types";
import { z } from "zod";
import { LedgerKindSchema } from "./lib/schemas/token.schema";

/**
 * Shared enums derived from DB
 */
export type ReservationStatus = Enums<"reservation_status">;
export type ToolStatus = Enums<"tool_status">;
export type LedgerKind = Enums<"ledger_kind">;
export type AwardKind = Enums<"award_kind">;

/** Generic cursor-based pagination wrapper */
export interface CursorPage<TItem> {
  items: TItem[];
  next_cursor: string | null;
}

/** Generic OK deletion result */
export interface DeleteResultDTO {
  deleted: true;
}

/** Generic archive result */
export interface ArchiveResultDTO {
  archived: true;
  archived_at: string;
}

/** Minimal GeoJSON Point for profile geocoding responses */
export interface GeoJSONPoint {
  type: "Point";
  coordinates: [number, number]; // [lon, lat]
}

/** Standard API error envelope (for convenience) */
export interface ApiErrorDTO {
  error: { code: string; message: string; details?: unknown };
}

// =====================
// Profiles
// =====================

export type ProfileDTO = Row<"profiles"> & { last_geocoded_at?: string | null };

export type ProfileUpsertCommand = Pick<Insert<"profiles">, "username" | "location_text" | "rodo_consent">;

/**
 * Public profile view mapped to API shape.
 * Note: DB view uses `avg_stars`; API exposes `avg_rating`.
 */
export interface PublicProfileDTO {
  id: NonNullable<Row<"public_profiles">["id"]>;
  username: Row<"public_profiles">["username"];
  location_text: Row<"public_profiles">["location_text"];
  avg_rating: Row<"public_profiles">["avg_stars"];
  ratings_count: Row<"public_profiles">["ratings_count"];
  active_tools: ToolSummaryDTO[];
}

export interface ProfileGeocodeResultDTO {
  location_geog: GeoJSONPoint;
}

// =====================
// Tools
// =====================

/**
 * Public tool summary for public profile view
 */
export interface ToolSummaryDTO {
  id: string;
  name: string;
  imageUrl: string | null;
  description: string;
}

/**
 * Tool row suitable for API responses. Internal search column omitted.
 */
export type ToolDTO = Omit<Row<"tools">, "search_name_tsv"> & {
  main_image_url: string | null;
};

export type CreateToolCommand = Pick<Insert<"tools">, "name" | "description" | "suggested_price_tokens">;

export const UpdateToolCommandSchema = z
  .object({
    name: z.string(),
    description: z.string(),
    suggested_price_tokens: z.number().int().positive(),
    status: z.enum(["draft", "active", "archived", "inactive"]),
  })
  .partial();

export type UpdateToolCommand = z.infer<typeof UpdateToolCommandSchema>;

export interface ToolArchivedResponseDto {
  archived: true;
  archivedAt: string; // Data w formacie ISO 8601
}

export type ToolListItemDTO = Pick<ToolDTO, "id" | "name" | "status">;
export type ToolListPageDTO = CursorPage<ToolSearchItemDTO>;

export interface ToolSearchItemDTO {
  id: string;
  name: string;
  distance_m: number;
  main_image_url: string | null;
  ownerName: string;
}
export type ToolSearchPageDTO = CursorPage<ToolSearchItemDTO>;

// =====================
// Tool Images & Storage
// =====================

const MAX_IMAGE_SIZE_MB = 5;
const MAX_IMAGE_SIZE_BYTES = MAX_IMAGE_SIZE_MB * 1024 * 1024;
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];

export const CreateToolImageUploadUrlCommand = z.object({
  content_type: z
    .string()
    .refine((value) => ALLOWED_IMAGE_TYPES.includes(value), { message: "Unsupported image type" }),
  size_bytes: z
    .number()
    .int()
    .positive()
    .max(MAX_IMAGE_SIZE_BYTES, { message: `Image size cannot exceed ${MAX_IMAGE_SIZE_MB}MB` }),
});

export type CreateToolImageUploadUrlCommand = z.infer<typeof CreateToolImageUploadUrlCommand>;

export interface ToolImageUploadUrlDto {
  upload_url: string;
  headers: Record<string, string>;
  storage_key: string;
}

export type ToolImageDTO = Row<"tool_images">;
export type ToolImageWithUrlDTO = ToolImageDTO & { public_url?: string };

export const CreateToolImageCommandSchema = z.object({
  storage_key: z.string(),
  position: z.number().int(),
});
export type CreateToolImageCommand = z.infer<typeof CreateToolImageCommandSchema>;

export interface CreateUploadUrlCommand {
  content_type: string;
  size_bytes: number;
}

export interface ImageUploadURLDTO {
  upload_url: string;
  headers: Record<string, string>;
  storage_key: string;
}

export type ToolWithImagesDTO = ToolDTO & { images: ToolImageWithUrlDTO[] };

// =====================
// Reservations
// =====================

export type ReservationDTO = Row<"reservations">;

export type CreateReservationCommand = Pick<Insert<"reservations">, "tool_id" | "owner_id">;

export type ReservationListItemDTO = Pick<ReservationDTO, "id" | "status">;
export type ReservationListPageDTO = CursorPage<ReservationListItemDTO>;

export type ReservationWithToolDTO = ReservationDTO & {
  tool: Pick<ToolDTO, "id" | "name" | "main_image_url"> | null;
  borrower: Pick<ProfileDTO, "id" | "username"> | null;
  owner: Pick<ProfileDTO, "id" | "username"> | null;
};

export interface ReservationTransitionResponseDto {
  reservation: ReservationDTO;
}

export interface ReservationLedgerEffectsDTO {
  hold: number | null;
  transfer: number | null;
}

export interface ReservationTransitionResultDTO {
  reservation: ReservationDTO;
  ledger: ReservationLedgerEffectsDTO;
}

/**
 * Podstawowe, publiczne informacje o narzędziu.
 */
export interface ToolSummaryDto {
  id: string;
  name: string;
  mainImageUrl?: string;
}

/**
 * Szczegółowe informacje o rezerwacji zwracane przez endpoint.
 */
export interface ReservationDetailsDto {
  id: string;
  status: ReservationStatus;
  agreedPriceTokens: number | null;
  tool: ToolSummaryDto;
  ownerId: string;
  borrowerId: string;
  createdAt: string;
  updatedAt: string;
}

export type ReservationCounterpartyRole = "owner" | "borrower";

export interface ReservationContactsDto {
  counterparty_role: ReservationCounterpartyRole;
  counterparty_email: string;
}

export interface Reservation {
  id: string;
  status: "requested" | "owner_accepted" | "borrower_confirmed" | "picked_up" | "returned" | "cancelled" | "rejected";
  tool_id: string;
  owner_id: string;
  borrower_id: string;
  created_at: string;
}

export interface ReservationWithDetails extends Reservation {
  property: Property;
}

export interface AwardSignupBonusResponse {
  awarded: true;
  amount: number;
}

// =====================
// Tokens: Balances & Ledger
// =====================

export type BalanceDTO = Row<"balances">;

export type LedgerEntryKind = z.infer<typeof LedgerKindSchema>;

export interface LedgerEntryDto {
  id: string;
  kind: LedgerEntryKind;
  amount: number;
  details: Record<string, any>;
  createdAt: string;
}

export interface LedgerEntriesResponseDto {
  items: LedgerEntryDto[];
  nextCursor: string | null;
}

export interface AwardSignupResultDTO {
  awarded: boolean;
  amount: number;
}

export interface RescueClaimResultDTO {
  awarded: boolean;
  amount: number;
  claim_date_cet: string;
}

// =====================
// Ratings
// =====================

export type Rating = Row<"ratings">;

export type RatingSummaryDTO = Pick<Row<"rating_stats">, "rated_user_id" | "avg_stars" | "ratings_count">;

/**
 * @deprecated Use RatingSummaryDTO instead
 */
export interface UserRatingSummaryDto {
  rated_user_id: string;
  avg_stars: number | null;
  ratings_count: number;
}

// =====================
// Audit Log (limited)
// =====================

export type AuditEventDTO = Row<"audit_log">;
export type AuditEventPageDTO = CursorPage<AuditEventDTO>;

// =====================
// AI Helper
// =====================

export interface DescribeToolCommand {
  name: string;
}
export interface DescribeToolSuggestionDTO {
  suggestion: string;
}

// =====================
// View Models
// =====================

// Podsumowanie narzędzia z polem na link
export interface ToolSummaryViewModel {
  id: string;
  name: string;
  imageUrl: string | null;
  description: string;
  href: string;
}

// Publiczny profil użytkownika (konwencja camelCase)
export interface PublicProfileViewModel {
  id: string;
  username: string;
  locationText: string | null;
  avgRating: number | null;
  ratingsCount: number;
  activeTools: ToolSummaryViewModel[];
}

export interface ProfileUpdateDto {
  username: string;
  location_text: string;
  rodo_consent: boolean;
}

export type LocationStatus = "IDLE" | "VERIFIED" | "ERROR";

export interface ProfileEditViewModel {
  username: string;
  location_text: string;
  rodo_consent: boolean;
  errors: {
    username?: string;
    location_text?: string;
    form?: string;
  };
  locationStatus: LocationStatus;
}

// =====================
// Tokens
// =====================

// GET /api/tokens/balance
export interface TokenBalanceDto {
  user_id: string;
  total: number;
  held: number;
  available: number;
}

// GET /api/tokens/ledger
export type TokenLedgerKind = "debit" | "credit" | "hold" | "release" | "transfer" | "award";

export interface TokenLedgerEntryDto {
  id: string;
  kind: TokenLedgerKind;
  amount: number;
  details: Record<string, any>;
  created_at: string; // ISO 8601
}

// GET /api/tools?bonus_eligible=true
export interface EligibleToolDto {
  id: string;
  name: string;
}

// ViewModels (for UI)

// Type used by components to store bonus state
export interface BonusStateViewModel {
  signup: {
    isClaimed: boolean;
    isLoading: boolean;
  };
  listing: {
    eligibleTools: EligibleToolDto[];
    claimsUsed: number;
    isLoading: boolean;
  };
  rescue: {
    isAvailable: boolean; // Dostępne saldo == 0
    isClaimedToday: boolean;
    isLoading: boolean;
  };
}

// Enriched ledger entry type for easier display
export interface TokenLedgerEntryViewModel extends TokenLedgerEntryDto {
  formattedDate: string;
  description: string;
}
