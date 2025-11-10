import React from "react";
import { Button } from "@/components/ui/button";

export interface LocationBannerProps {
  visible: boolean;
  reason?: "missing_location" | "no_results";
}

export default function LocationBanner(props: LocationBannerProps): JSX.Element | null {
  const { visible, reason } = props;
  if (!visible) return null;

  return (
    <div className="flex items-center justify-between rounded-md border border-amber-300 bg-amber-50 px-4 py-3 text-amber-950">
      <p className="text-sm">
        {reason === "missing_location"
          ? "Aby wyszukiwać narzędzia w pobliżu, ustaw lokalizację profilu."
          : "Brak wyników w okolicy lub dla podanego zapytania."}
      </p>
      <a href="/profile/edit">
        <Button variant="outline" size="sm">Uzupełnij lokalizację</Button>
      </a>
    </div>
  );
}


