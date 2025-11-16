import React from "react";
import { Button } from "@/components/ui/button";

export function QuickActions() {
  return (
    <div className="mt-8 border-t pt-6">
      <h2 className="text-xl font-semibold mb-4">Szybkie akcje</h2>
      <div className="flex flex-wrap gap-4">
        <Button asChild variant="outline">
          <a href="/tools/my">Moje narzędzia</a>
        </Button>
        <Button asChild variant="outline">
          <a href="/reservations/my">Moje rezerwacje</a>
        </Button>
        <Button asChild variant="outline">
          <a href="/tokens">Moje żetony</a>
        </Button>
        <Button asChild variant="outline">
          <a href="/tools/new">Dodaj nowe narzędzie</a>
        </Button>
      </div>
    </div>
  );
}

