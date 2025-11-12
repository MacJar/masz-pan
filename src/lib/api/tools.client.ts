import type {
  ToolDTO,
  CreateToolCommand,
  CreateToolImageUploadUrlCommand,
  ToolImageUploadUrlDto,
  CreateToolImageCommand,
  ToolImageDTO,
  UpdateToolCommand,
} from "@/types";

export async function createDraftTool(): Promise<ToolDTO> {
  const response = await fetch("/api/tools", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    // Zgodnie z planem, na początku wysyłamy puste body,
    // aby zainicjować wersję roboczą
    body: JSON.stringify({} as CreateToolCommand),
  });

  if (!response.ok) {
    throw new Error("Failed to create draft tool");
  }

  return response.json();
}

export async function updateDraftTool(toolId: string, command: UpdateToolCommand): Promise<ToolDTO> {
  const response = await fetch(`/api/tools/${toolId}`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    throw new Error("Failed to update draft tool");
  }

  return response.json();
}

export async function getUploadUrl(
  toolId: string,
  command: CreateToolImageUploadUrlCommand,
): Promise<ToolImageUploadUrlDto> {
  const response = await fetch(`/api/tools/${toolId}/images/upload-url`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    throw new Error("Failed to get upload URL");
  }

  return response.json();
}

export async function uploadFile(uploadUrl: string, file: File, headers: Record<string, string>): Promise<void> {
  const response = await fetch(uploadUrl, {
    method: "PUT",
    headers: headers,
    body: file,
  });

  if (!response.ok) {
    throw new Error(`Failed to upload file. Status: ${response.statusText}`);
  }
}

export async function saveToolImage(toolId: string, command: CreateToolImageCommand): Promise<ToolImageDTO> {
  const response = await fetch(`/api/tools/${toolId}/images`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    throw new Error("Failed to save tool image");
  }

  return response.json();
}

export async function deleteToolImage(toolId: string, imageId: string): Promise<void> {
  const response = await fetch(`/api/tools/${toolId}/images/${imageId}`, {
    method: "DELETE",
  });

  if (!response.ok) {
    throw new Error("Failed to delete tool image");
  }
}

export async function publishTool(toolId: string): Promise<ToolDTO> {
  return updateDraftTool(toolId, { status: "active" });
}
