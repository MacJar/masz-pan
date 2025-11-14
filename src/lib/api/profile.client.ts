import type { ProfileDTO, ProfileUpsertCommand } from "@/types";

/**
 * Fetches the current user's profile.
 * Handles a 404 response by returning null, indicating a new user who hasn't created a profile yet.
 * @returns {Promise<ProfileDTO | null>} The user profile or null if not found.
 */
export async function getProfile(): Promise<ProfileDTO | null> {
  const response = await fetch("/api/profile");

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error("Failed to fetch profile");
  }

  return response.json();
}

/**
 * Creates or updates a user's profile.
 * @param {ProfileUpsertCommand} command - The profile data to save.
 * @returns {Promise<ProfileDTO>} The updated user profile.
 */
export async function upsertProfile(command: ProfileUpsertCommand): Promise<ProfileDTO> {
  const response = await fetch("/api/profile", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    // We expect the server to send back specific error information
    // which will be handled by the caller (e.g., the useProfileManager hook).
    throw response;
  }

  return response.json();
}
