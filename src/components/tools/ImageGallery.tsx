import type { ToolImageWithUrlDTO } from "@/types";
import React from "react";
import { getToolImagePublicUrl } from "@/lib/utils";

interface ImageGalleryProps {
  images: ToolImageWithUrlDTO[];
  toolName: string;
}

const ImagePlaceholder = () => (
  <div className="flex h-full min-h-[400px] w-full items-center justify-center bg-muted text-muted-foreground">
    <span>Brak zdjęcia</span>
  </div>
);

export default function ImageGallery({ images, toolName }: ImageGalleryProps) {
  if (!images || images.length === 0) {
    return <ImagePlaceholder />;
  }

  const sortedImages = [...images].sort((a, b) => a.position - b.position);
  const primaryImage = sortedImages[0];
  const secondaryImages = sortedImages.slice(1, 5); // Max 4 secondary images

  return (
    <div className="grid grid-cols-1 gap-2 md:grid-cols-2">
      <div className="md:col-span-1">
        <img
          src={primaryImage.public_url ?? getToolImagePublicUrl(primaryImage.storage_key)}
          alt={`Główne zdjęcie narzędzia ${toolName}`}
          className="h-full w-full rounded-lg object-cover"
        />
      </div>
      {secondaryImages.length > 0 && (
        <div className="hidden grid-cols-2 grid-rows-2 gap-2 md:grid">
          {secondaryImages.map((image) => (
            <div key={image.storage_key}>
              <img
                src={image.public_url ?? getToolImagePublicUrl(image.storage_key)}
                alt={`Zdjęcie narzędzia ${toolName} #${image.position}`}
                className="h-full w-full rounded-lg object-cover"
              />
            </div>
          ))}
        </div>
      )}
      {secondaryImages.length === 0 && (
        <div className="hidden md:flex items-center justify-center h-full min-h-[200px] rounded-lg bg-muted/50 border-2 border-dashed border-muted-foreground/30">
          <span className="text-muted-foreground text-sm">Brak dodatkowych zdjęć</span>
        </div>
      )}
    </div>
  );
}
