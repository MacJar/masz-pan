import React from "react";
import type { ToolFormViewModel } from "./NewTool.types";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { AIDescribeButton } from "./AIDescribeButton";

interface ToolFormProps {
  formData: Pick<ToolFormViewModel, "name" | "description" | "suggested_price_tokens">;
  onFormChange: (field: keyof ToolFormViewModel, value: any) => void;
  onGenerateDescription: () => Promise<void>;
  isGeneratingDescription: boolean;
}

export function ToolForm({ formData, onFormChange, onGenerateDescription, isGeneratingDescription }: ToolFormProps) {
  const handlePriceChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    // Allow empty input to clear the field, otherwise parse as integer
    const numericValue = value === "" ? "" : parseInt(value, 10);

    if (numericValue === "" || (numericValue >= 1 && numericValue <= 5)) {
      onFormChange("suggested_price_tokens", numericValue);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <Label htmlFor="name">Nazwa narzędzia</Label>
        <Input
          id="name"
          value={formData.name}
          onChange={(e) => onFormChange("name", e.target.value)}
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
          value={formData.description}
          onChange={(e) => onFormChange("description", e.target.value)}
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
          value={formData.suggested_price_tokens}
          onChange={handlePriceChange}
          min={1}
          max={5}
          step={1}
          required
          className="w-32"
        />
        <p className="text-sm text-muted-foreground">Wybierz wartość od 1 do 5.</p>
      </div>
    </div>
  );
}
