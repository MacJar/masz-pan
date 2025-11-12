import { useReducer, useEffect, useCallback } from "react";
import { v4 as uuidv4 } from "uuid";
import imageCompression from "browser-image-compression";
import type { ToolFormViewModel, ImageUploadState } from "@/components/tools/new/NewTool.types";
import {
  createDraftTool,
  getUploadUrl,
  uploadFile,
  saveToolImage,
  deleteToolImage,
  updateDraftTool,
  publishTool,
} from "@/lib/api/tools.client";
import { useDebouncedValue } from "./useDebouncedValue";
import type { UpdateToolCommand } from "@/types";

type NewToolState = ToolFormViewModel;

type Action =
  | { type: "CREATE_DRAFT_START" }
  | { type: "CREATE_DRAFT_SUCCESS"; payload: { toolId: string } }
  | { type: "CREATE_DRAFT_ERROR"; payload: { error: string } }
  | { type: "FORM_CHANGE"; payload: { field: string; value: any } }
  | { type: "IMAGE_ADD_START"; payload: { file: File; tempId: string } }
  | { type: "IMAGE_UPLOAD_PROGRESS"; payload: { tempId: string; status: ImageUploadState["status"]; progress?: number } }
  | { type: "IMAGE_UPLOAD_SUCCESS"; payload: { tempId: string; databaseId: string; storage_key: string } }
  | { type: "IMAGE_UPLOAD_ERROR"; payload: { tempId: string; error: string } }
  | { type: "IMAGE_REMOVE_START"; payload: { tempId: string } }
  | { type: "IMAGE_REMOVE_SUCCESS"; payload: { tempId: string } }
  | { type: "IMAGE_REMOVE_ERROR"; payload: { tempId: string; error: string } }
  | { type: "SAVE_DRAFT_START" }
  | { type: "SAVE_DRAFT_SUCCESS" }
  | { type: "SAVE_DRAFT_ERROR"; payload: { error: string } }
  | { type: "PUBLISH_START" }
  | { type: "PUBLISH_SUCCESS" }
  | { type: "PUBLISH_ERROR"; payload: { error: string } };

const initialState: NewToolState = {
  toolId: null,
  name: "",
  description: "",
  suggested_price_tokens: 1,
  images: [],
  status: "idle",
  errorMessage: null,
};

function reducer(state: NewToolState, action: Action): NewToolState {
  switch (action.type) {
    case "CREATE_DRAFT_START":
      return { ...state, status: "creating_draft", errorMessage: null };
    case "CREATE_DRAFT_SUCCESS":
      return { ...state, status: "idle", toolId: action.payload.toolId };
    case "CREATE_DRAFT_ERROR":
      return { ...state, status: "error", errorMessage: action.payload.error };
    case "FORM_CHANGE":
      return { ...state, status: "idle", [action.payload.field]: action.payload.value };
    case "IMAGE_ADD_START":
      const newImage: ImageUploadState = {
        id: action.payload.tempId,
        file: action.payload.file,
        status: "pending",
        progressPercent: 0,
      };
      return { ...state, images: [...state.images, newImage] };
    case "IMAGE_UPLOAD_PROGRESS":
      return {
        ...state,
        images: state.images.map((img) =>
          img.id === action.payload.tempId
            ? { ...img, status: action.payload.status, progressPercent: action.payload.progress ?? img.progressPercent }
            : img,
        ),
      };
    case "IMAGE_UPLOAD_SUCCESS":
      return {
        ...state,
        images: state.images.map((img) =>
          img.id === action.payload.tempId
            ? {
                ...img,
                status: "completed",
                progressPercent: 100,
                databaseId: action.payload.databaseId,
                storage_key: action.payload.storage_key,
              }
            : img,
        ),
      };
    case "IMAGE_UPLOAD_ERROR":
      return {
        ...state,
        images: state.images.map((img) =>
          img.id === action.payload.tempId
            ? { ...img, status: "error", errorMessage: action.payload.error }
            : img,
        ),
      };
    case "IMAGE_REMOVE_SUCCESS":
      return {
        ...state,
        images: state.images.filter((img) => img.id !== action.payload.tempId),
      };
    // Note: For simplicity, IMAGE_REMOVE_START and IMAGE_REMOVE_ERROR don't change the state here,
    // but could be used to show a loading/error state on the specific image.
    case "SAVE_DRAFT_START":
      return { ...state, status: "saving" };
    case "SAVE_DRAFT_SUCCESS":
      return { ...state, status: "idle" };
    case "SAVE_DRAFT_ERROR":
      // Non-blocking error
      console.error("Save draft error:", action.payload.error);
      return { ...state, status: "idle" }; // Revert to idle
    case "PUBLISH_START":
      return { ...state, status: "publishing", errorMessage: null };
    case "PUBLISH_SUCCESS":
      return { ...state, status: "success" };
    case "PUBLISH_ERROR":
      return { ...state, status: "error", errorMessage: action.payload.error };
    default:
      return state;
  }
}

export function useNewToolManager() {
  const [state, dispatch] = useReducer(reducer, initialState);

  const debouncedName = useDebouncedValue(state.name, 500);
  const debouncedDescription = useDebouncedValue(state.description, 500);
  const debouncedPrice = useDebouncedValue(state.suggested_price_tokens, 500);

  useEffect(() => {
    async function initializeDraft() {
      dispatch({ type: "CREATE_DRAFT_START" });
      try {
        const draftTool = await createDraftTool();
        dispatch({ type: "CREATE_DRAFT_SUCCESS", payload: { toolId: draftTool.id } });
      } catch (error) {
        const message = error instanceof Error ? error.message : "An unknown error occurred";
        dispatch({ type: "CREATE_DRAFT_ERROR", payload: { error: message } });
      }
    }

    initializeDraft();
  }, []);

  // Effect for autosaving the form
  useEffect(() => {
    if (!state.toolId || state.status === "creating_draft") return;

    const changedData: UpdateToolCommand = {
      name: debouncedName,
      description: debouncedDescription,
      suggested_price_tokens: debouncedPrice,
    };

    async function saveDraft() {
      dispatch({ type: "SAVE_DRAFT_START" });
      try {
        await updateDraftTool(state.toolId!, changedData);
        dispatch({ type: "SAVE_DRAFT_SUCCESS" });
      } catch (error) {
        const message = error instanceof Error ? error.message : "An unknown error occurred";
        dispatch({ type: "SAVE_DRAFT_ERROR", payload: { error: message } });
      }
    }

    saveDraft();
  }, [debouncedName, debouncedDescription, debouncedPrice, state.toolId, state.status]);

  const handleFormChange = (field: string, value: any) => {
    dispatch({ type: "FORM_CHANGE", payload: { field, value } });
  };

  const handleImageAdd = useCallback(
    async (file: File) => {
      if (!state.toolId) return;
      const tempId = uuidv4();
      dispatch({ type: "IMAGE_ADD_START", payload: { file, tempId } });

      try {
        // 1. Compress
        dispatch({ type: "IMAGE_UPLOAD_PROGRESS", payload: { tempId, status: "compressing" } });
        const compressedFile = await imageCompression(file, {
          maxSizeMB: 1,
          maxWidthOrHeight: 1920,
          useWebWorker: true,
        });

        // 2. Get Upload URL
        dispatch({ type: "IMAGE_UPLOAD_PROGRESS", payload: { tempId, status: "getting_url" } });
        const { upload_url, headers, storage_key } = await getUploadUrl(state.toolId, {
          content_type: compressedFile.type,
          size_bytes: compressedFile.size,
        });

        // 3. Upload file
        dispatch({ type: "IMAGE_UPLOAD_PROGRESS", payload: { tempId, status: "uploading", progress: 0 } });
        // NOTE: Real progress tracking would require XHR, fetch doesn't support it directly.
        // We will simulate it for now.
        await uploadFile(upload_url, compressedFile, headers);
        dispatch({ type: "IMAGE_UPLOAD_PROGRESS", payload: { tempId, status: "uploading", progress: 100 } });

        // 4. Save image record
        dispatch({ type: "IMAGE_UPLOAD_PROGRESS", payload: { tempId, status: "saving" } });
        const savedImage = await saveToolImage(state.toolId, {
          storage_key,
          position: state.images.length,
        });

        dispatch({
          type: "IMAGE_UPLOAD_SUCCESS",
          payload: { tempId, databaseId: savedImage.id, storage_key },
        });
      } catch (error) {
        const message = error instanceof Error ? error.message : "An unknown error occurred during upload";
        dispatch({ type: "IMAGE_UPLOAD_ERROR", payload: { tempId, error: message } });
      }
    },
    [state.toolId, state.images.length],
  );

  const handleImageRemove = useCallback(
    async (tempId: string) => {
      if (!state.toolId) return;

      const imageToRemove = state.images.find((img) => img.id === tempId);
      if (!imageToRemove?.databaseId) {
        // If it was never saved, just remove from state
        dispatch({ type: "IMAGE_REMOVE_SUCCESS", payload: { tempId } });
        return;
      }

      try {
        await deleteToolImage(state.toolId, imageToRemove.databaseId);
        dispatch({ type: "IMAGE_REMOVE_SUCCESS", payload: { tempId } });
      } catch (error) {
        const message = error instanceof Error ? error.message : "An unknown error occurred";
        dispatch({ type: "IMAGE_REMOVE_ERROR", payload: { tempId, error: message } });
      }
    },
    [state.toolId, state.images],
  );

  const canPublish =
    !!state.name.trim() &&
    state.suggested_price_tokens >= 1 &&
    state.suggested_price_tokens <= 5 &&
    state.images.some((img) => img.status === "completed");

  const handlePublish = useCallback(async () => {
    if (!canPublish || !state.toolId) return;

    dispatch({ type: "PUBLISH_START" });
    try {
      const publishedTool = await publishTool(state.toolId);
      dispatch({ type: "PUBLISH_SUCCESS" });
      // Redirect on success
      window.location.href = `/tools/${publishedTool.id}`;
    } catch (error) {
      const message = error instanceof Error ? error.message : "An unknown error occurred";
      dispatch({ type: "PUBLISH_ERROR", payload: { error: message } });
    }
  }, [state.toolId, canPublish]);

  return {
    state,
    canPublish,
    handleFormChange,
    handleImageAdd,
    handleImageRemove,
    handlePublish,
  };
}
