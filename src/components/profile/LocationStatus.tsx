import React from "react";
import { CheckCircle, XCircle, Hourglass } from "lucide-react";
import type { LocationStatus as LocationStatusType } from "@/types";

interface LocationStatusProps {
  status: LocationStatusType;
}

const statusConfig = {
  IDLE: {
    Icon: Hourglass,
    color: "text-gray-500",
    text: "Oczekuje",
  },
  VERIFIED: {
    Icon: CheckCircle,
    color: "text-green-500",
    text: "Zweryfikowano",
  },
  ERROR: {
    Icon: XCircle,
    color: "text-red-500",
    text: "Błąd",
  },
};

export function LocationStatus({ status }: LocationStatusProps) {
  const { Icon, color, text } = statusConfig[status];

  return (
    <div className={`flex items-center gap-1.5 text-sm ${color}`}>
      <Icon className="h-4 w-4" />
      <span>{text}</span>
    </div>
  );
}
