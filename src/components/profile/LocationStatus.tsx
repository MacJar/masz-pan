import React from "react";
import { Badge } from "@/components/ui/badge";

export type GeocodingStatus = "SUCCESS" | "PENDING" | "ERROR" | "NOT_SET";

interface LocationStatusProps {
  status: GeocodingStatus;
}

const statusConfig = {
  SUCCESS: { text: "Lokalizacja potwierdzona", variant: "success" as const },
  PENDING: { text: "Lokalizacja oczekuje na weryfikację", variant: "default" as const },
  ERROR: { text: "Błąd weryfikacji lokalizacji", variant: "destructive" as const },
  NOT_SET: { text: "Brak lokalizacji", variant: "secondary" as const },
};

export function LocationStatus({ status }: LocationStatusProps) {
  const { text, variant } = statusConfig[status];
  return <Badge variant={variant}>{text}</Badge>;
}
