import React from "react";
import { CheckCircle, XCircle, Hourglass, HelpCircle } from "lucide-react";

// This type is defined in ProfileView.tsx, maybe it should be in a shared types file?
// For now, let's define it here to match the possible values.
export type GeocodingStatus = "NOT_SET" | "PENDING" | "SUCCESS" | "ERROR";

interface LocationStatusProps {
  status: GeocodingStatus;
}

const statusConfig: Record<GeocodingStatus, { Icon: React.ElementType; color: string; text: string }> = {
  NOT_SET: {
    Icon: HelpCircle,
    color: "text-muted-foreground",
    text: "Nie ustawiono",
  },
  PENDING: {
    Icon: Hourglass,
    color: "text-blue-500",
    text: "Oczekuje na weryfikację",
  },
  SUCCESS: {
    Icon: CheckCircle,
    color: "text-green-500",
    text: "Zweryfikowano",
  },
  ERROR: {
    Icon: XCircle,
    color: "text-red-500",
    text: "Błąd weryfikacji",
  },
};

export function LocationStatus({ status }: LocationStatusProps) {
  const config = statusConfig[status];

  if (!config) {
    // Fallback for any unexpected status
    return null;
  }

  const { Icon, color, text } = config;

  return (
    <div className={`flex items-center gap-1.5 text-sm ${color}`}>
      <Icon className="h-4 w-4" />
      <span>{text}</span>
    </div>
  );
}
