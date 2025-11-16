import { z } from "zod";
import type { Profile, ProfileUpdateDto, PublicProfileDTO } from "@/types";

/**
 * Fetches the current user's profile.
 * Handles a 404 response by returning null, indicating a new user who hasn't created a profile yet.
 * @returns {Promise<Profile | null>} The user profile or null if not found.
 */
export async function getProfile(): Promise<Profile | null> {
  const response = await fetch("/api/profile");

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    //
    const errorData = await response.json().catch(() => ({ message: "Failed to fetch profile" }));
    const error = new Error(errorData.message || "Failed to fetch profile");
    (error as Error & { status: number }).status = response.status;
    throw error;
  }

  return response.json();
}

/**
 * Updates a user's profile.
 * @param {ProfileUpdateDto} command - The profile data to save.
 * @returns {Promise<Profile>} The updated user profile.
 */
export async function upsertProfile(command: ProfileUpdateDto): Promise<Profile> {
  const response = await fetch("/api/profile", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({ message: "An unexpected error occurred" }));
    const error = new Error(errorData.error || "An unexpected error occurred");
    (error as Error & { status: number }).status = response.status;
    throw error;
  }

  return response.json();
}

// Schemas and functions for Public Profile View

const ToolSummaryDTOSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  imageUrl: z.string().url().nullable(),
  description: z.string(),
});

const PublicProfileDTOSchema = z.object({
  id: z.string().uuid(),
  username: z.string(),
  location_text: z.string().nullable(),
  avg_rating: z.number().nullable(),
  ratings_count: z.number().int().nonnegative(),
  active_tools: z.array(ToolSummaryDTOSchema),
});

export class ProfileNotFoundError extends Error {
  constructor(message = "Profile not found") {
    super(message);
    this.name = "ProfileNotFoundError";
  }
}

export class ApiValidationError extends Error {
  constructor(message = "Invalid data structure from API", cause?: z.ZodError) {
    super(message);
    this.name = "ApiValidationError";
    this.cause = cause;
  }
}

/**
 * Fetches the public profile for a given user.
 * @param userId The UUID of the user.
 * @returns A promise that resolves to the public profile data.
 * @throws {ProfileNotFoundError} If the profile is not found (404).
 * @throws {ApiValidationError} If the API response fails validation.
 * @throws {Error} For other network or server errors.
 */
export async function fetchPublicProfile(userId: string): Promise<PublicProfileDTO> {
  const response = await fetch(`/api/profiles/${userId}/public`);

  if (response.status === 404) {
    throw new ProfileNotFoundError();
  }

  if (!response.ok) {
    // Here you could add more specific error handling based on status codes
    throw new Error(`Failed to fetch public profile: ${response.statusText}`);
  }

  const data = await response.json();

  const validationResult = PublicProfileDTOSchema.safeParse(data);

  if (!validationResult.success) {
    // eslint-disable-next-line no-console
    console.error("Public profile API response validation failed", validationResult.error.flatten());
    throw new ApiValidationError("Invalid data structure from public profile API", validationResult.error);
  }

  return validationResult.data;
}
