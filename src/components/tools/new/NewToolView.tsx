import React from "react";
import { useNewToolManager } from "@/components/hooks/useNewToolManager";
import { ToolForm } from "./ToolForm";
import { ImageUploader } from "./ImageUploader";
import { PublishCallout } from "./PublishCallout";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { AlertTriangle } from "lucide-react";

export function NewToolView() {
  const { state, handleFormChange, handleImageAdd, handleImageRemove, handlePublish, canPublish, handleSaveDraft } =
    useNewToolManager();

  if (state.status === "creating_draft") {
    return (
      <div className="space-y-4">
        <Skeleton className="h-12 w-1/2" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-10 w-1/4" />
      </div>
    );
  }

  // General error display for publish error
  if (state.status === "error" && state.errorMessage) {
    return (
      <Alert variant="destructive">
        <AlertTriangle className="h-4 w-4" />
        <AlertTitle>Wystąpił błąd</AlertTitle>
        <AlertDescription>
          <p>{state.errorMessage}</p>
          <p>Odśwież stronę i spróbuj ponownie.</p>
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div className="md:col-span-2">
        <ToolForm formData={state} onFormChange={handleFormChange} />
      </div>
      <div className="space-y-8">
        <ImageUploader images={state.images} onImageAdd={handleImageAdd} onImageRemove={handleImageRemove} />
        <PublishCallout
          canPublish={canPublish}
          isPublishing={state.status === "publishing"}
          onPublish={handlePublish}
          isSaving={state.status === "saving"}
          onSaveDraft={handleSaveDraft}
          conditions={{
            hasName: !!state.name.trim(),
            hasPrice: state.suggested_price_tokens >= 1 && state.suggested_price_tokens <= 5,
            hasImage: state.images.some((img) => img.status === "completed"),
          }}
        />
      </div>
    </div>
  );
}

export default NewToolView;
