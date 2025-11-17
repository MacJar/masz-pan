import React from "react";
import type { ToolStatus } from "@/types";
import { Badge } from "@/components/ui/badge";

interface ToolInfoProps {
  name: string;
  description: string | null;
  status: ToolStatus;
  suggestedPrice: number | null;
}

const statusMap: Record<ToolStatus, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  draft: { label: "Szkic", variant: "outline" },
  inactive: { label: "Niedostępne", variant: "secondary" },
  active: { label: "Dostępne", variant: "default" },
  archived: { label: "Zarchiwizowane", variant: "destructive" },
};

export default function ToolInfo({ name, description, status, suggestedPrice }: ToolInfoProps) {
  const { label, variant } = statusMap[status] || { label: "Nieznany", variant: "outline" };

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-bold">{name}</h1>

      <div className="flex items-center gap-2">
        <Badge variant={variant}>{label}</Badge>
        {suggestedPrice !== null && (
          <Badge variant="outline">
            Sugerowana cena: <span className="ml-1 font-semibold">{suggestedPrice}</span> tokenów
          </Badge>
        )}
      </div>

      {description && <p className="text-muted-foreground">{description}</p>}
    </div>
  );
}
