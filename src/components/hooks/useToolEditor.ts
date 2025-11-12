import { useState, useEffect, useCallback } from "react";
import type { ToolWithImagesDTO, UpdateToolCommand } from "@/types";
import {
  getTool,
  updateTool as apiUpdateTool,
  deleteToolImage,
  getUploadUrl,
  uploadFile,
  saveToolImage,
  archiveTool as apiArchiveTool,
  reorderToolImages,
} from "@/lib/api/tools.client";
import { toast } from "sonner";
import imageCompression from "browser-image-compression";

export function useToolEditor(toolId: string) {
  const [tool, setTool] = useState<ToolWithImagesDTO | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchTool = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await getTool(toolId);
      setTool(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An unknown error occurred");
    } finally {
      setIsLoading(false);
    }
  }, [toolId]);

  useEffect(() => {
    fetchTool();
  }, [fetchTool]);

  const updateTool = useCallback(
    async (data: UpdateToolCommand) => {
      setIsSubmitting(true);
      try {
        const updatedTool = await apiUpdateTool(toolId, data);
        setTool((prevTool) => (prevTool ? { ...prevTool, ...updatedTool } : null));
        toast.success("Zmiany zostały zapisane.");
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Wystąpił nieznany błąd.");
      } finally {
        setIsSubmitting(false);
      }
    },
    [toolId]
  );

  const handleImageAdd = useCallback(
    async (file: File) => {
      if (!toolId) return;

      toast.info("Rozpoczęto przesyłanie zdjęcia...");

      try {
        const compressedFile = await imageCompression(file, {
          maxSizeMB: 1,
          maxWidthOrHeight: 1920,
          useWebWorker: true,
        });

        const { upload_url, headers, storage_key } = await getUploadUrl(toolId, {
          content_type: compressedFile.type,
          size_bytes: compressedFile.size,
        });

        await uploadFile(upload_url, compressedFile, headers);

        const savedImage = await saveToolImage(toolId, {
          storage_key,
          position: tool?.images.length ?? 0,
        });

        setTool((prevTool) =>
          prevTool
            ? {
                ...prevTool,
                images: [...prevTool.images, savedImage],
              }
            : null
        );

        toast.success("Zdjęcie zostało dodane.");
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "Błąd podczas dodawania zdjęcia.");
      }
    },
    [toolId, tool?.images.length]
  );

  const handleImageDelete = useCallback(
    async (imageId: string) => {
      if (!toolId) return;

      try {
        await deleteToolImage(toolId, imageId);
        setTool((prevTool) =>
          prevTool
            ? {
                ...prevTool,
                images: prevTool.images.filter((img) => img.id !== imageId),
              }
            : null
        );
        toast.success("Zdjęcie zostało usunięte.");
      } catch (error) {
        toast.error(error instanceof Error ? error.message : "Błąd podczas usuwania zdjęcia.");
      }
    },
    [toolId]
  );

  const handleImageReorder = useCallback(
    async (reorderedImages: ToolWithImagesDTO["images"]) => {
      if (!tool) return;

      // Optimistic UI update
      const optimisticState = reorderedImages.map((image, index) => ({ ...image, position: index }));
      setTool({ ...tool, images: optimisticState });

      try {
        const imageIds = reorderedImages.map((img) => img.id);
        const updatedImages = await reorderToolImages(tool.id, imageIds);
        // Sync with server state
        setTool({ ...tool, images: updatedImages });
        toast.success("Kolejność zdjęć została zaktualizowana.");
      } catch (error) {
        // Revert on error
        setTool(tool);
        toast.error("Nie udało się zapisać nowej kolejności zdjęć.");
      }
    },
    [tool]
  );

  const handleArchiveTool = useCallback(async () => {
    if (!toolId) return;

    try {
      await apiArchiveTool(toolId);
      toast.success("Narzędzie zostało zarchiwizowane.");
      // Redirect to the list of user's tools
      window.location.href = "/tools/my";
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Wystąpił nieznany błąd podczas archiwizacji.");
    }
  }, [toolId]);

  return {
    tool,
    isLoading,
    isSubmitting,
    error,
    updateTool,
    handleImageAdd,
    handleImageDelete,
    handleImageReorder,
    handleArchiveTool,
  };
}
