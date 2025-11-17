import React, { useState, useEffect } from "react";
import type { ProfileDTO, ProfileUpsertCommand } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";

interface ProfileFormProps {
  profile: ProfileDTO | null;
  isSubmitting: boolean;
  onSubmit: (command: ProfileUpsertCommand) => void;
  fieldErrors: Record<string, string>;
  onClearFieldErrors: (fieldName: string) => void;
}

const initialState: ProfileUpsertCommand = {
  username: "",
  location_text: "",
  rodo_consent: false,
};

export function ProfileForm({ profile, isSubmitting, onSubmit, fieldErrors, onClearFieldErrors }: ProfileFormProps) {
  const [formData, setFormData] = useState<ProfileUpsertCommand>(initialState);

  useEffect(() => {
    if (profile) {
      setFormData({
        username: profile.username || "",
        location_text: profile.location_text || "",
        rodo_consent: profile.rodo_consent || false,
      });
    } else {
      setFormData(initialState);
    }
  }, [profile]);

  const handleFieldChange = (field: keyof ProfileUpsertCommand, value: string | boolean) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    if (fieldErrors[field]) {
      onClearFieldErrors(field);
    }
  };

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const isSubmitDisabled = isSubmitting || !formData.username.trim() || !formData.rodo_consent;

  return (
    <form onSubmit={handleFormSubmit} className="space-y-6">
      <div className="space-y-2">
        <Label htmlFor="username">Nazwa użytkownika</Label>
        <Input
          id="username"
          value={formData.username}
          onChange={(e) => handleFieldChange("username", e.target.value)}
          aria-invalid={!!fieldErrors.username}
          aria-describedby="username-error"
        />
        {fieldErrors.username && (
          <p id="username-error" className="text-sm text-red-500">
            {fieldErrors.username}
          </p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="location_text">Lokalizacja (np. miasto, kod pocztowy)</Label>
        <div className="flex items-center gap-2">
          <Input
            id="location_text"
            className="flex-grow"
            value={formData.location_text || ""}
            onChange={(e) => handleFieldChange("location_text", e.target.value)}
          />
        </div>
      </div>

      <div className="flex items-center space-x-2">
        <Checkbox
          id="rodo_consent"
          checked={formData.rodo_consent}
          onCheckedChange={(checked) => handleFieldChange("rodo_consent", !!checked)}
          aria-invalid={!!fieldErrors.rodo_consent}
          aria-describedby="rodo-error"
        />
        <Label htmlFor="rodo_consent" className="text-sm font-normal cursor-pointer">
          Wyrażam zgodę na przetwarzanie moich danych osobowych zgodnie z polityką prywatności.
        </Label>
        {fieldErrors.rodo_consent && (
          <p id="rodo-error" className="text-sm text-red-500">
            {fieldErrors.rodo_consent}
          </p>
        )}
      </div>

      <Button type="submit" disabled={isSubmitDisabled}>
        {isSubmitting ? "Zapisywanie..." : "Zapisz zmiany"}
      </Button>
    </form>
  );
}
