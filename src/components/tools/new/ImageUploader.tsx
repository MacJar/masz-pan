import React, { useCallback } from "react";
import { useDropzone } from "react-dropzone";
import type { ImageUploadState } from "./NewTool.types";
import { UploadCloud, X } from "lucide-react";

interface ImageUploaderProps {
  images: ImageUploadState[];
  onImageAdd: (file: File) => void;
  onImageRemove: (imageId: string) => void;
}

const statusMap: Record<ImageUploadState["status"], string> = {
  pending: "Oczekuje",
  compressing: "Kompresowanie...",
  getting_url: "Przygotowanie...",
  uploading: "Wysyłanie...",
  saving: "Zapisywanie...",
  completed: "Gotowe",
  error: "Błąd",
};

function ImagePreviewItem({ image, onRemove }: { image: ImageUploadState; onRemove: (id: string) => void }) {
  const objectUrl = React.useMemo(() => URL.createObjectURL(image.file), [image.file]);

  return (
    <div className="relative border rounded-lg overflow-hidden aspect-square">
      <img src={objectUrl} alt={image.file.name} className="w-full h-full object-cover" />
      <div className="absolute top-1 right-1">
        <button
          type="button"
          onClick={() => onRemove(image.id)}
          className="p-1.5 bg-gray-900/50 text-white rounded-full hover:bg-gray-900/75 transition-colors"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
      {image.status !== "completed" && (
        <div className="absolute bottom-0 left-0 right-0 p-2 bg-gray-900/75 text-white text-xs">
          <p>{statusMap[image.status]}</p>
          {(image.status === "uploading" || image.status === "compressing") && (
            <div className="w-full bg-gray-600 rounded-full h-1 mt-1">
              <div
                className="bg-blue-500 h-1 rounded-full"
                style={{ width: `${image.progressPercent}%` }}
              ></div>
            </div>
          )}
          {image.status === "error" && <p className="text-red-400 truncate">{image.errorMessage}</p>}
        </div>
      )}
    </div>
  );
}

export function ImageUploader({ images, onImageAdd, onImageRemove }: ImageUploaderProps) {
  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      acceptedFiles.forEach(onImageAdd);
    },
    [onImageAdd],
  );

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      "image/jpeg": [],
      "image/png": [],
      "image/webp": [],
      "image/gif": [],
    },
    maxSize: 5 * 1024 * 1024, // 5MB
  });

  return (
    <div className="space-y-4">
      <div
        {...getRootProps()}
        className={`p-8 border-2 border-dashed rounded-lg text-center cursor-pointer transition-colors ${
          isDragActive ? "border-primary bg-primary/10" : "border-border hover:border-primary/50"
        }`}
      >
        <input {...getInputProps()} />
        <div className="flex flex-col items-center gap-2 text-muted-foreground">
          <UploadCloud className="h-8 w-8" />
          {isDragActive ? (
            <p>Upuść pliki tutaj...</p>
          ) : (
            <p>Przeciągnij i upuść zdjęcia tutaj, lub kliknij, aby wybrać</p>
          )}
          <p className="text-xs">Max 5MB na plik. Dozwolone typy: JPG, PNG, WEBP, GIF.</p>
        </div>
      </div>
      {images.length > 0 && (
        <div className="grid grid-cols-3 gap-4">
          {images.map((image) => (
            <ImagePreviewItem key={image.id} image={image} onRemove={onImageRemove} />
          ))}
        </div>
      )}
    </div>
  );
}
