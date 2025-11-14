
import React, { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { ProfileFormSchema, type ProfileFormValues } from "@/lib/schemas/profile.schema";
import type { ProfileDTO, ProfileUpsertCommand } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Toaster, toast } from "sonner";

interface ProfileFormProps {
  profile: ProfileDTO | null;
  isSubmitting: boolean;
  onSubmit: (data: ProfileUpsertCommand) => Promise<{ success: boolean }>;
  fieldErrors: Record<string, string>;
  onClearFieldErrors: (fieldName: keyof ProfileFormValues) => void;
}

export function ProfileForm({
  profile,
  isSubmitting,
  onSubmit,
  fieldErrors,
  onClearFieldErrors,
}: ProfileFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setError,
    watch,
  } = useForm<ProfileFormValues>({
    resolver: zodResolver(ProfileFormSchema),
    defaultValues: {
      username: profile?.username || "",
      location_text: profile?.location_text || "",
      rodo_consent: profile?.rodo_consent || false,
    },
  });

  useEffect(() => {
    reset({
      username: profile?.username || "",
      location_text: profile?.location_text || "",
      rodo_consent: profile?.rodo_consent || false,
    });
  }, [profile, reset]);

  useEffect(() => {
    for (const field in fieldErrors) {
      setError(field as keyof ProfileFormValues, {
        type: "manual",
        message: fieldErrors[field],
      });
    }
  }, [fieldErrors, setError]);

  const handleFormSubmit = async (data: ProfileFormValues) => {
    const result = await onSubmit(data);
    if (result.success) {
      toast.success("Profil został zaktualizowany.");
    }
  };

  const watchedFields = watch();
  useEffect(() => {
    const subscription = watch((value, { name }) => {
      if (name && errors[name]) {
        onClearFieldErrors(name);
      }
    });
    return () => subscription.unsubscribe();
  }, [watch, errors, onClearFieldErrors]);

  return (
    <>
      <Toaster position="top-center" richColors />
      <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-6">
        <div className="space-y-2">
          <Label htmlFor="username">Nazwa użytkownika</Label>
          <Input id="username" {...register("username")} />
          {errors.username && <p className="text-sm text-red-500">{errors.username.message}</p>}
        </div>

        <div className="space-y-2">
          <Label htmlFor="location_text">Lokalizacja (np. miasto, kod pocztowy)</Label>
          <Input id="location_text" {...register("location_text")} />
          {errors.location_text && <p className="text-sm text-red-500">{errors.location_text.message}</p>}
        </div>

        <div className="flex items-center space-x-2">
          <Checkbox id="rodo_consent" {...register("rodo_consent")} />
          <Label htmlFor="rodo_consent" className="text-sm font-normal">
            Wyrażam zgodę na przetwarzanie moich danych osobowych zgodnie z polityką prywatności.
          </Label>
        </div>
        {errors.rodo_consent && <p className="text-sm text-red-500">{errors.rodo_consent.message}</p>}

        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? "Zapisywanie..." : "Zapisz zmiany"}
        </Button>
      </form>
    </>
  );
}
