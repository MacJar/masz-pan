import React from "react";
import { Button } from "@/components/ui/button";

export interface ErrorStateProps {
  errorCode: string;
  details?: unknown;
  onRetry(): void;
}

function getMessage(code: string): string {
  switch (code) {
    case "auth_required":
      return "Musisz być zalogowany, aby wyszukiwać narzędzia.";
    case "profile_location_missing":
      return "Uzupełnij lokalizację profilu, aby wyszukiwać w pobliżu.";
    case "validation_error":
      return "Nieprawidłowe zapytanie wyszukiwania.";
    case "internal_error":
    default:
      return "Wystąpił nieoczekiwany błąd. Spróbuj ponownie.";
  }
}

export default function ErrorState(props: ErrorStateProps): JSX.Element {
  const { errorCode, onRetry } = props;
  const message = getMessage(errorCode);
  return (
    <div className="rounded-md border border-red-300 bg-red-50 p-4 text-red-950">
      <div className="flex items-center justify-between gap-4">
        <p className="text-sm">{message}</p>
        <Button variant="outline" onClick={onRetry}>
          Spróbuj ponownie
        </Button>
      </div>
    </div>
  );
}


