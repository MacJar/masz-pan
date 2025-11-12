import React from "react";
import type { ToolImageDTO } from "@/types";
import { ImageUploader } from "@/components/tools/new/ImageUploader";
import { getToolImagePublicUrl } from "@/lib/utils";
import { X, GripVertical } from "lucide-react";
import { DndContext, closestCenter, type DragEndEvent } from "@dnd-kit/core";
import { SortableContext, useSortable, arrayMove, rectSortingStrategy } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

interface ImageManagerProps {
  images: ToolImageDTO[];
  toolId: string;
  onImageAdd: (file: File) => void;
  onImageDelete: (imageId: string) => void;
  onImageReorder: (reorderedImages: ToolImageDTO[]) => void;
}

function SortableImageItem({ image, onRemove }: { image: ToolImageDTO; onRemove: (id: string) => void }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id: image.id });
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  const imageUrl = getToolImagePublicUrl(image.storage_key);

  return (
    <div ref={setNodeRef} style={style} className="relative border rounded-lg overflow-hidden aspect-square touch-none">
      <img src={imageUrl} alt={`Tool image ${image.position}`} className="w-full h-full object-cover" />
      <div className="absolute top-1 right-1">
        <button
          type="button"
          onClick={() => onRemove(image.id)}
          className="p-1.5 bg-gray-900/50 text-white rounded-full hover:bg-gray-900/75 transition-colors"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
      <div
        {...attributes}
        {...listeners}
        className="absolute top-1 left-1 p-1.5 bg-gray-900/50 text-white rounded-full hover:bg-gray-900/75 transition-colors cursor-grab"
      >
        <GripVertical className="h-4 w-4" />
      </div>
    </div>
  );
}

export function ImageManager({ images, toolId, onImageAdd, onImageDelete, onImageReorder }: ImageManagerProps) {
  const sortedImages = images.sort((a, b) => a.position - b.position);

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (over && active.id !== over.id) {
      const oldIndex = sortedImages.findIndex((img) => img.id === active.id);
      const newIndex = sortedImages.findIndex((img) => img.id === over.id);
      const reorderedImages = arrayMove(sortedImages, oldIndex, newIndex);
      onImageReorder(reorderedImages);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium mb-2">Zdjęcia</h3>
        {sortedImages.length > 0 ? (
          <DndContext collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
            <SortableContext items={sortedImages.map((i) => i.id)} strategy={rectSortingStrategy}>
              <div className="grid grid-cols-3 gap-4">
                {sortedImages.map((image) => (
                  <SortableImageItem key={image.id} image={image} onRemove={onImageDelete} />
                ))}
              </div>
            </SortableContext>
          </DndContext>
        ) : (
          <p className="text-sm text-muted-foreground">Brak zdjęć. Dodaj pierwsze zdjęcie.</p>
        )}
      </div>
      <div>
        <h3 className="text-lg font-medium mb-2">Dodaj nowe zdjęcia</h3>
        <ImageUploader images={[]} onImageAdd={onImageAdd} onImageRemove={() => {}} />
      </div>
    </div>
  );
}
