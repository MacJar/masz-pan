import type {
  ToolDTO,
  CreateToolCommand,
  CreateToolImageUploadUrlCommand,
  ToolImageUploadUrlDto,
  CreateToolImageCommand,
  ToolImageWithUrlDTO,
  UpdateToolCommand,
  CursorPage,
  ToolStatus,
  ToolWithImagesDTO,
} from "@/types";

export async function reorderToolImages(toolId: string, imageIds: string[]): Promise<ToolImageWithUrlDTO[]> {
  const response = await fetch(`/api/tools/${toolId}/images/order`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ imageIds }),
  });
  if (!response.ok) {
    throw new Error("Failed to reorder tool images");
  }
  return response.json();
}

export async function archiveTool(toolId: string): Promise<{ archivedAt: string }> {
  const response = await fetch(`/api/tools/${toolId}/archive`, {
    method: "POST",
  });
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || "Failed to archive tool");
  }
  return response.json();
}

export async function getTool(toolId: string): Promise<ToolWithImagesDTO> {
  const response = await fetch(`/api/tools/${toolId}`);
  if (!response.ok) {
    if (response.status === 404) {
      throw new Error("Tool not found");
    }
    throw new Error("Failed to fetch tool");
  }
  return response.json();
}

export async function getMyTools(params: {
  status?: ToolStatus | 'all';
  limit?: number;
  cursor?: string;
}): Promise<CursorPage<ToolDTO>> {
  const query = new URLSearchParams();
  query.set('owner_id', 'me');
  if (params.status && params.status !== 'all') {
    query.set('status', params.status);
  }
  if (params.limit) {
    query.set('limit', String(params.limit));
  }
  if (params.cursor) {
    query.set('cursor', params.cursor);
  }

  const response = await fetch(`/api/tools?${query.toString()}`);

  if (!response.ok) {
    throw new Error('Failed to fetch user tools');
  }
  return response.json();
}

export async function updateTool(toolId: string, command: UpdateToolCommand): Promise<ToolDTO> {
  const response = await fetch(`/api/tools/${toolId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(command),
  });

  if (!response.ok) {
    throw new Error('Failed to update tool');
  }
  return response.json();
}

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

/**
 * @deprecated Use updateTool instead.
 */
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

export async function saveToolImage(toolId: string, command: CreateToolImageCommand): Promise<ToolImageWithUrlDTO> {
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

/**
 * @deprecated Use updateTool(toolId, { status: "active" }) instead.
 */
export async function publishTool(toolId: string): Promise<ToolDTO> {
  return updateDraftTool(toolId, { status: "active" });
}
