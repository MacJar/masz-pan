import React from "react";
import { useToolEditor } from "@/components/hooks/useToolEditor";
import StateContainer from "@/components/tools/StateContainer";
import { Skeleton } from "@/components/ui/skeleton";
import { ToolForm } from "@/components/tools/new/ToolForm";
import { ImageManager } from "./ImageManager";
import { DangerZone } from "./DangerZone";

interface EditToolViewProps {
  toolId: string;
}

const EditToolView: React.FC<EditToolViewProps> = ({ toolId }) => {
  const {
    tool,
    isLoading,
    error,
    updateTool,
    isSubmitting,
    handleImageAdd,
    handleImageDelete,
    handleImageReorder,
    handleArchiveTool,
  } = useToolEditor(toolId);

  return (
    <StateContainer
      isLoading={isLoading}
      error={error}
      skeleton={
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="md:col-span-2 space-y-4">
            <Skeleton className="h-10 w-1/2" />
            <Skeleton className="h-24 w-full" />
            <Skeleton className="h-10 w-1/4" />
          </div>
          <div className="space-y-4">
            <Skeleton className="h-48 w-full" />
          </div>
        </div>
      }
    >
      {tool && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="md:col-span-2">
            <div className="space-y-8">
              <ToolForm initialData={tool} onSubmit={updateTool} isSubmitting={isSubmitting} />
              <DangerZone toolId={tool.id} toolStatus={tool.status} onArchive={handleArchiveTool} />
            </div>
          </div>
          <div className="space-y-8">
            <ImageManager
              images={tool.images}
              toolId={tool.id}
              onImageAdd={handleImageAdd}
              onImageDelete={handleImageDelete}
              onImageReorder={handleImageReorder}
            />
          </div>
        </div>
      )}
    </StateContainer>
  );
};

export default EditToolView;
