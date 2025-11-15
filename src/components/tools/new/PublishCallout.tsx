import React from "react";
import { Button } from "@/components/ui/button";
import { ListChecks } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

interface PublishCalloutProps {
  canPublish: boolean;
  isPublishing: boolean;
  onPublish: () => void;
  isSaving: boolean;
  onSaveDraft: () => void;
  conditions: {
    hasName: boolean;
    hasPrice: boolean;
    hasImage: boolean;
  };
}

export function PublishCallout({
  canPublish,
  isPublishing,
  onPublish,
  isSaving,
  onSaveDraft,
  conditions,
}: PublishCalloutProps) {
  return (
    <Alert>
      <ListChecks className="h-4 w-4" />
      <AlertTitle>Gotowy do publikacji?</AlertTitle>
      <AlertDescription className="space-y-3">
        <p className="text-sm text-muted-foreground">Aby zapisać szkic lub opublikować narzędzie, musisz spełnić poniższe warunki:</p>
        <ul className="text-sm text-muted-foreground list-inside">
          <li className={conditions.hasName ? "text-green-600" : ""}>✓ Podaj nazwę narzędzia</li>
          <li className={conditions.hasPrice ? "text-green-600" : ""}>✓ Ustaw poprawną cenę (1-5)</li>
          <li className={conditions.hasImage ? "text-green-600" : ""}>✓ Dodaj przynajmniej jedno zdjęcie</li>
        </ul>
        <div className="space-y-2">
          <Button onClick={onSaveDraft} disabled={!canPublish || isSaving} className="w-full" variant="outline">
            {isSaving ? "Zapisywanie..." : "Zapisz jako szkic"}
          </Button>
          <Button onClick={onPublish} disabled={!canPublish || isPublishing} className="w-full">
            {isPublishing ? "Publikowanie..." : "Opublikuj narzędzie"}
          </Button>
        </div>
      </AlertDescription>
    </Alert>
  );
}
