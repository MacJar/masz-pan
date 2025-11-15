// Typ do śledzenia statusu przesyłania pojedynczego zdjęcia
export type ImageUploadStatus =
  | "pending"
  | "compressing"
  | "getting_url"
  | "uploading"
  | "saving"
  | "completed"
  | "error";

// Interfejs reprezentujący stan pojedynczego zdjęcia w procesie przesyłania
export interface ImageUploadState {
  id: string; // Tymczasowe ID po stronie klienta
  file: File;
  status: ImageUploadStatus;
  progressPercent: number;
  storage_key?: string;
  errorMessage?: string;
  databaseId?: string; // ID z bazy danych po pomyślnym zapisie
}

// Główny ViewModel dla całego widoku dodawania narzędzia
export interface ToolFormViewModel {
  toolId: string | null;
  name: string;
  description: string;
  suggested_price_tokens: number;
  images: ImageUploadState[];
  status: "idle" | "creating_draft" | "saving" | "publishing" | "error" | "success";
  errorMessage: string | null;
}

