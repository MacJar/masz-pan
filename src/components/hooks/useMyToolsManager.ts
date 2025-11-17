import { useState, useCallback, useEffect } from "react";
import type { ToolStatus, ToolDTO } from "@/types";
import { getMyTools, updateTool } from "@/lib/api/tools.client";

// Step 6: Define MyToolListItemViewModel and mapping logic
export interface MyToolListItemViewModel {
  id: string;
  name: string;
  status: ToolStatus;
  createdAt: string;
  updatedAt: string;
  canPublish: boolean;
  canUnpublish: boolean;
  canArchive: boolean;
  canEdit: boolean;
  imageUrl: string | null;
}

const mapToolDTOToViewModel = (tool: ToolDTO): MyToolListItemViewModel => ({
  id: tool.id,
  name: tool.name,
  status: tool.status,
  createdAt: new Date(tool.created_at).toLocaleDateString("pl-PL"),
  updatedAt: new Date(tool.updated_at).toLocaleDateString("pl-PL"),
  canPublish: tool.status === "draft",
  canUnpublish: tool.status === "active",
  canArchive: tool.status !== "archived",
  canEdit: tool.status !== "archived",
  imageUrl: tool.main_image_url,
});

const PAGE_LIMIT = 10;

export const useMyToolsManager = () => {
  const [tools, setTools] = useState<MyToolListItemViewModel[]>([]);
  const [statusFilter, setStatusFilter] = useState<ToolStatus | "all">("all");
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<Error | null>(null);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [hasNextPage, setHasNextPage] = useState<boolean>(false);
  const [toolToArchive, setToolToArchive] = useState<MyToolListItemViewModel | null>(null);

  const fetchTools = useCallback(async (filter: ToolStatus | "all", cursor: string | null) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await getMyTools({
        status: filter,
        limit: PAGE_LIMIT,
        cursor: cursor ?? undefined,
      });

      const viewModels = result.items.map(mapToolDTOToViewModel);

      setTools((prevTools) => (cursor ? [...prevTools, ...viewModels] : viewModels));
      setNextCursor(result.next_cursor);
      setHasNextPage(!!result.next_cursor);
    } catch (e) {
      setError(e as Error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleSetStatusFilter = useCallback(
    (newStatus: ToolStatus | "all") => {
      setStatusFilter(newStatus);
      setTools([]);
      setNextCursor(null);
      fetchTools(newStatus, null);
    },
    [fetchTools]
  );

  const loadMore = useCallback(() => {
    if (hasNextPage && !isLoading) {
      fetchTools(statusFilter, nextCursor);
    }
  }, [hasNextPage, isLoading, statusFilter, nextCursor, fetchTools]);

  const updateToolStatus = useCallback(
    async (toolId: string, newStatus: ToolStatus) => {
      // Save previous state for rollback
      const previousTools = tools;
      // Optimistic update
      setTools((prevTools) =>
        prevTools.map((tool) => {
          if (tool.id === toolId) {
            return {
              ...tool,
              status: newStatus,
              canPublish: newStatus === "draft",
              canUnpublish: newStatus === "active",
              canArchive: newStatus !== "archived",
              canEdit: newStatus !== "archived",
            };
          }
          return tool;
        })
      );
      try {
        await updateTool(toolId, { status: newStatus });
      } catch {
        // Revert optimistic update on error
        setTools(previousTools);
        // TODO: Show toast notification with error
      }
    },
    [tools]
  );

  const openArchiveDialog = useCallback((tool: MyToolListItemViewModel) => {
    setToolToArchive(tool);
  }, []);

  const closeArchiveDialog = useCallback(() => {
    setToolToArchive(null);
  }, []);

  const confirmArchive = useCallback(async () => {
    if (toolToArchive) {
      await updateToolStatus(toolToArchive.id, "archived");
      setToolToArchive(null);
      // Optional: refetch or filter out locally
      setTools((prev) => prev.filter((t) => t.id !== toolToArchive.id));
    }
  }, [toolToArchive, updateToolStatus]);

  // Initial fetch
  useEffect(() => {
    fetchTools(statusFilter, null);
  }, [fetchTools, statusFilter]);

  return {
    tools,
    statusFilter,
    isLoading,
    error,
    hasNextPage,
    setStatusFilter: handleSetStatusFilter,
    loadMore,
    updateToolStatus,
    toolToArchive,
    openArchiveDialog,
    closeArchiveDialog,
    confirmArchive,
  };
};
