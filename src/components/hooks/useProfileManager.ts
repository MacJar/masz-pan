import { useState, useEffect, useCallback } from "react";
import type { ProfileDTO, ProfileUpsertCommand } from "@/types";
import { getProfile, upsertProfile } from "@/lib/api/profile.client";

export function useProfileManager() {
  const [profile, setProfile] = useState<ProfileDTO | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  const fetchProfile = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const userProfile = await getProfile();
      setProfile(userProfile);
    } catch {
      setError("Nie udało się załadować profilu. Spróbuj odświeżyć stronę.");
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  const saveProfile = async (command: ProfileUpsertCommand) => {
    setIsSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      const updatedProfile = await upsertProfile(command);
      setProfile(updatedProfile);
      return { success: true, data: updatedProfile };
    } catch (err) {
      if (err instanceof Response) {
        if (err.status === 409) {
          const body = await err.json();
          setFieldErrors({ username: body.error?.message || "Nazwa użytkownika jest już zajęta." });
        } else if (err.status === 400) {
          const body = await err.json();
          // Assuming the body has a structure like { errors: { field: "message" } }
          setFieldErrors(body.errors || {});
        } else {
          setError("Wystąpił nieoczekiwany błąd serwera. Spróbuj ponownie.");
        }
      } else {
        setError("Wystąpił błąd sieci. Sprawdź połączenie i spróbuj ponownie.");
      }
      return { success: false };
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    profile,
    isLoading,
    isSubmitting,
    error,
    fieldErrors,
    saveProfile,
    setFieldErrors, // Allow clearing field errors from the form component
  };
}
