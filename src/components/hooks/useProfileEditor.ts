import { useState, useEffect, useCallback } from "react";
import { toast } from "sonner";
import { getProfile, upsertProfile } from "@/lib/api/profile.client";
import type { ProfileEditViewModel, ProfileUpdateDto } from "@/types";

const INITIAL_FORM_DATA: ProfileEditViewModel = {
  username: "",
  location_text: "",
  rodo_consent: false,
  errors: {},
  locationStatus: "IDLE",
};

export function useProfileEditor() {
  const [formData, setFormData] = useState<ProfileEditViewModel>(INITIAL_FORM_DATA);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchProfile() {
      setIsLoading(true);
      setError(null);
      try {
        const profile = await getProfile();
        if (profile) {
          setFormData({
            username: profile.username || "",
            location_text: profile.location_text || "",
            rodo_consent: profile.rodo_consent || false,
            errors: {},
            locationStatus: profile.location_geog ? "VERIFIED" : "IDLE",
          });
        } else {
          // New user, initialize with empty form
          setFormData(INITIAL_FORM_DATA);
        }
      } catch {
        setError("Nie udało się pobrać danych profilu. Spróbuj ponownie.");
        toast.error("Wystąpił błąd podczas pobierania danych profilu.");
      } finally {
        setIsLoading(false);
      }
    }

    fetchProfile();
  }, []);

  const handleFieldChange = useCallback((field: keyof ProfileUpdateDto, value: string | boolean) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
      errors: {
        ...prev.errors,
        [field]: undefined,
        form: undefined,
      },
    }));
  }, []);

  const handleSubmit = useCallback(async () => {
    setIsSubmitting(true);
    setFormData((prev) => ({ ...prev, errors: {} }));

    const { username, location_text, rodo_consent } = formData;
    const updateDto: ProfileUpdateDto = { username, location_text, rodo_consent };

    try {
      await upsertProfile(updateDto);
      toast.success("Profil został zaktualizowany!");

      // Redirect to profile page after successful submission
      window.location.href = "/profile";
    } catch (err: unknown) {
      const error = err as { message?: string; status?: number };
      const errorMessage = error.message || "Wystąpił nieoczekiwany błąd.";
      if (error.status === 409) {
        setFormData((prev) => ({
          ...prev,
          errors: { ...prev.errors, username: "Ta nazwa użytkownika jest już zajęta." },
        }));
      } else if (error.status === 422) {
        setFormData((prev) => ({
          ...prev,
          errors: { ...prev.errors, location_text: "Nie udało się zweryfikować lokalizacji." },
          locationStatus: "ERROR",
        }));
      } else {
        setFormData((prev) => ({ ...prev, errors: { ...prev.errors, form: errorMessage } }));
        toast.error(`Błąd zapisu: ${errorMessage}`);
      }
    } finally {
      setIsSubmitting(false);
    }
  }, [formData]);

  return {
    formData,
    isLoading,
    isSubmitting,
    error,
    handleFieldChange,
    handleSubmit,
  };
}
