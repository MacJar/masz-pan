import type { PublicProfileDTO, ToolWithImagesDTO } from "@/types";

/**
 * ViewModel combining tool data with its owner's public profile.
 * Used by the ToolDetailsView component to manage all data required for rendering.
 */
export interface ToolDetailsViewModel {
  tool: ToolWithImagesDTO;
  owner: PublicProfileDTO;
}
