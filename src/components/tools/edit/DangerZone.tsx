import React, { useState } from "react";
import type { ToolStatus } from "@/types";
import ActionConfirmationDialog from "@/components/tools/my/ActionConfirmationDialog";
import { Button } from "@/components/ui/button";

interface DangerZoneProps {
  toolId: string;
  toolStatus: ToolStatus;
  onArchive: () => void;
}

export function DangerZone({ toolId, toolStatus, onArchive }: DangerZoneProps) {
  const [isArchiveConfirmOpen, setIsArchiveConfirmOpen] = useState(false);

  if (toolStatus === "archived") {
    return null; // Don't show anything if already archived
  }

  return (
    <div className="border border-destructive/50 rounded-lg p-4 space-y-4">
      <h3 className="text-lg font-medium text-destructive">Strefa niebezpieczna</h3>
      <div>
        <h4 className="font-semibold">Archiwizuj narzędzie</h4>
        <p className="text-sm text-muted-foreground">
          Zarchiwizowane narzędzie nie będzie widoczne w wyszukiwarce i nie będzie można go zarezerwować. Będziesz mógł
          je przywrócić w przyszłości.
        </p>
      </div>
      <div className="flex justify-end">
        <Button variant="destructive" onClick={() => setIsArchiveConfirmOpen(true)}>
          Archiwizuj
        </Button>
      </div>

      <ActionConfirmationDialog
        isOpen={isArchiveConfirmOpen}
        onOpenChange={setIsArchiveConfirmOpen}
        onConfirm={() => {
          onArchive();
          setIsArchiveConfirmOpen(false);
        }}
        title="Czy na pewno chcesz zarchiwizować to narzędzie?"
        description="Tej akcji nie można cofnąć w łatwy sposób. Spowoduje to usunięcie narzędzia z publicznej listy i anulowanie przyszłych rezerwacji."
      />
    </div>
  );
}


