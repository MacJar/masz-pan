
import React from "react";
import type { ProfileEditViewModel, ProfileUpdateDto } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { LocationStatus } from "./LocationStatus";
import { ErrorDisplay } from "./ErrorDisplay";

interface ProfileFormProps {
  formData: ProfileEditViewModel;
  isSubmitting: boolean;
  onFieldChange: (field: keyof ProfileUpdateDto, value: string | boolean) => void;
  onSubmit: () => void;
}

export function ProfileForm({
  formData,
  isSubmitting,
  onFieldChange,
  onSubmit,
}: ProfileFormProps) {
  const { username, location_text, rodo_consent, errors, locationStatus } = formData;

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit();
  };
  
  const isSubmitDisabled = isSubmitting || !username.trim() || !location_text.trim() || !rodo_consent;

  return (
    <form onSubmit={handleFormSubmit} className="space-y-6">
      {errors.form && <ErrorDisplay message={errors.form} />}

      <div className="space-y-2">
        <Label htmlFor="username">Nazwa użytkownika</Label>
        <Input
          id="username"
          value={username}
          onChange={(e) => onFieldChange("username", e.target.value)}
          aria-invalid={!!errors.username}
          aria-describedby="username-error"
        />
        {errors.username && (
          <p id="username-error" className="text-sm text-red-500">{errors.username}</p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="location_text">Lokalizacja (np. miasto, kod pocztowy)</Label>
        <div className="flex items-center gap-2">
          <Input
            id="location_text"
            className="flex-grow"
            value={location_text}
            onChange={(e) => onFieldChange("location_text", e.target.value)}
            aria-invalid={!!errors.location_text}
            aria-describedby="location-error"
          />
          <LocationStatus status={locationStatus} />
        </div>
        {errors.location_text && (
          <p id="location-error" className="text-sm text-red-500">{errors.location_text}</p>
        )}
      </div>

      <div className="flex items-center space-x-2">
        <Checkbox
          id="rodo_consent"
          checked={rodo_consent}
          onCheckedChange={(checked) => onFieldChange("rodo_consent", !!checked)}
        />
        <Label htmlFor="rodo_consent" className="text-sm font-normal cursor-pointer">
          Wyrażam zgodę na przetwarzanie moich danych osobowych zgodnie z polityką prywatności.
        </Label>
      </div>

      <Button type="submit" disabled={isSubmitDisabled}>
        {isSubmitting ? "Zapisywanie..." : "Zapisz zmiany"}
      </Button>
    </form>
  );
}
