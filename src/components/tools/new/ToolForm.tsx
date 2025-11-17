import React, { useEffect, useState, useRef } from "react";
import type { ToolFormViewModel } from "./NewTool.types";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { AIDescribeButton } from "./AIDescribeButton";
import type { ToolWithImagesDTO, UpdateToolCommand } from "@/types";
import { Button } from "@/components/ui/button";
import { isEqual } from "lodash-es";

interface ToolFormProps {
  // For uncontrolled mode (like in EditToolView)
  initialData?: ToolWithImagesDTO;
  isSubmitting?: boolean;
  onSubmit?: (data: UpdateToolCommand) => void;

  // For controlled mode (like in NewToolView)
  formData?: ToolFormViewModel | UpdateToolCommand;
  onFormChange?: (field: keyof UpdateToolCommand, value: string | number) => void;
}

export function ToolForm({
  initialData,
  isSubmitting,
  onSubmit,
  formData: controlledFormData,
  onFormChange: onControlledFormChange,
}: ToolFormProps) {
  const [internalFormData, setInternalFormData] = useState<UpdateToolCommand>({
    name: initialData?.name ?? "",
    description: initialData?.description ?? "",
    suggested_price_tokens: initialData?.suggested_price_tokens ?? 1,
  });
  const [isDirty, setIsDirty] = useState(false);
  const initialDataRef = useRef<UpdateToolCommand | null>(null);

  // Determine if the component is controlled
  const isControlled = controlledFormData !== undefined && onControlledFormChange !== undefined;
  const formData = isControlled ? controlledFormData : internalFormData;

  // Initialize form data when initialData changes (only for uncontrolled mode)
  useEffect(() => {
    if (!isControlled && initialData) {
      const initialCommand: UpdateToolCommand = {
        name: initialData.name,
        description: initialData.description ?? "",
        suggested_price_tokens: initialData.suggested_price_tokens ?? 1,
      };
      initialDataRef.current = initialCommand;
      setInternalFormData(initialCommand);
      setIsDirty(false);
    }
  }, [initialData, isControlled]);

  // Check if form is dirty whenever internalFormData changes
  useEffect(() => {
    if (!isControlled && initialDataRef.current) {
      setIsDirty(!isEqual(initialDataRef.current, internalFormData));
    }
  }, [internalFormData, isControlled]);

  const handleFormChange = (field: keyof UpdateToolCommand, value: string | number) => {
    if (isControlled) {
      onControlledFormChange(field, value);
    } else {
      setInternalFormData((prev) => ({ ...prev, [field]: value }));
    }
  };

  const handlePriceChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const numericValue = value === "" ? "" : parseInt(value, 10);

    if (numericValue === "" || (numericValue >= 1 && numericValue <= 5)) {
      handleFormChange("suggested_price_tokens", numericValue as number);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (onSubmit) {
      onSubmit(isControlled ? (controlledFormData as UpdateToolCommand) : internalFormData);
    }
  };

  const isFormValid = formData && formData.name.trim().length > 0 && formData.suggested_price_tokens >= 1;

  // NOTE: This component is now controlled internally for form data,
  // but submits the data via onSubmit prop.
  // This is a refactoring from its original use in NewToolView.
  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="space-y-2">
        <Label htmlFor="name">Nazwa narzędzia</Label>
        <Input
          id="name"
          value={formData?.name ?? ""}
          onChange={(e) => handleFormChange("name", e.target.value)}
          placeholder="np. Wiertarka udarowa Bosch"
          maxLength={100}
          required
        />
        <p className="text-sm text-muted-foreground">To pole jest wymagane do publikacji.</p>
      </div>

      <div className="space-y-2">
        <Label htmlFor="description">Opis</Label>
        <Textarea
          id="description"
          value={formData?.description ?? ""}
          onChange={(e) => handleFormChange("description", e.target.value)}
          placeholder="Opisz swoje narzędzie, jego stan, do czego może służyć."
          rows={6}
          maxLength={1000}
        />
        <div className="flex justify-end">
          <AIDescribeButton />
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="price">Sugerowana cena (w żetonach za dzień)</Label>
        <Input
          id="price"
          type="number"
          value={formData?.suggested_price_tokens ?? 1}
          onChange={handlePriceChange}
          min={1}
          max={5}
          step={1}
          required
          className="w-32"
        />
        <p className="text-sm text-muted-foreground">Wybierz wartość od 1 do 5.</p>
      </div>
      <div className="flex justify-end">
        {!isControlled && (
          <Button type="submit" disabled={isSubmitting || !isDirty || !isFormValid}>
            {isSubmitting ? "Zapisywanie..." : "Zapisz zmiany"}
          </Button>
        )}
      </div>
    </form>
  );
}
