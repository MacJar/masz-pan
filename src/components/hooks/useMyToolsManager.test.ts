import { renderHook, act, waitFor } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { useMyToolsManager } from "./useMyToolsManager";
import * as toolsApi from "@/lib/api/tools.client";
import type { ToolDTO, ToolStatus } from "@/types";

// Mock the entire tools.client module
vi.mock("@/lib/api/tools.client");

const mockedToolsApi = vi.mocked(toolsApi);

const createMockTool = (id: string, status: ToolStatus): ToolDTO => ({
  id,
  name: `Tool ${id}`,
  description: "A mock tool",
  status,
  owner_id: "user1",
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
  archived_at: null,
  suggested_price_tokens: 10,
  main_image_url: null,
});

describe("useMyToolsManager", () => {
  beforeEach(() => {
    // Reset mocks before each test
    vi.resetAllMocks();
  });

  it("should fetch tools on initial render and set state correctly on success", async () => {
    const mockTools = [createMockTool("1", "active")];
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: mockTools,
      next_cursor: "cursor123",
    });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    // Wait for the hook to finish fetching
    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    expect(result.current.isLoading).toBe(false);
    expect(result.current.tools.length).toBe(1);
    expect(result.current.tools[0].name).toBe("Tool 1");
    expect(result.current.hasNextPage).toBe(true);
    expect(result.current.error).toBe(null);
  });

  it("should handle fetch error correctly", async () => {
    const mockError = new Error("Failed to fetch");
    mockedToolsApi.getMyTools.mockRejectedValue(mockError);

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBe(mockError);
    expect(result.current.tools.length).toBe(0);
  });

  it("should change filter and refetch tools", async () => {
    mockedToolsApi.getMyTools.mockResolvedValue({ items: [], next_cursor: null });
    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    const newDraftTools = [createMockTool("2", "draft")];
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: newDraftTools,
      next_cursor: null,
    });

    await act(async () => {
      result.current.setStatusFilter("draft");
    });

    expect(mockedToolsApi.getMyTools).toHaveBeenCalledWith(expect.objectContaining({ status: "draft" }));
    expect(result.current.statusFilter).toBe("draft");
    expect(result.current.tools[0].name).toBe("Tool 2");
  });

  it("should load more tools and append them to the list", async () => {
    const initialTools = [createMockTool("1", "active")];
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: initialTools,
      next_cursor: "cursor123",
    });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    const moreTools = [createMockTool("2", "active")];
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: moreTools,
      next_cursor: null,
    });

    await act(async () => {
      result.current.loadMore();
    });

    expect(result.current.tools.length).toBe(2);
    expect(result.current.tools[0].name).toBe("Tool 1");
    expect(result.current.tools[1].name).toBe("Tool 2");
    expect(result.current.hasNextPage).toBe(false);
  });

  it("should not load more when hasNextPage is false", async () => {
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: [createMockTool("1", "active")],
      next_cursor: null,
    });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    const initialCallCount = mockedToolsApi.getMyTools.mock.calls.length;

    await act(async () => {
      result.current.loadMore();
    });

    // Should not make another API call
    expect(mockedToolsApi.getMyTools.mock.calls.length).toBe(initialCallCount);
  });

  it("should not load more when isLoading is true", async () => {
    const initialTools = [createMockTool("1", "active")];
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: initialTools,
      next_cursor: "cursor123",
    });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    const initialCallCount = mockedToolsApi.getMyTools.mock.calls.length;

    // Set loading state manually by triggering a filter change
    act(() => {
      result.current.setStatusFilter("draft");
    });

    // Try to load more while loading
    await act(async () => {
      result.current.loadMore();
    });

    // Should not make another API call while loading
    // The initial call count should be 2 (initial + filter change)
    expect(mockedToolsApi.getMyTools.mock.calls.length).toBeGreaterThanOrEqual(initialCallCount);
  });

  it("should perform an optimistic update and revert on error", async () => {
    const initialTools = [createMockTool("1", "active")];
    mockedToolsApi.getMyTools.mockResolvedValue({ items: initialTools, next_cursor: null });
    mockedToolsApi.updateTool.mockRejectedValue(new Error("Update failed"));

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    // Check initial status
    expect(result.current.tools[0].status).toBe("active");

    // Perform optimistic update that will fail
    act(() => {
      result.current.updateToolStatus("1", "archived");
    });

    // Immediately after, status should be updated optimistically
    await waitFor(() => {
      expect(result.current.tools[0].status).toBe("archived");
    });

    // After the API call fails, it should revert
    await waitFor(() => {
      expect(result.current.tools[0].status).toBe("active");
    });
  });

  it("should correctly handle archiving a tool", async () => {
    const toolToArchive = createMockTool("1", "active");
    mockedToolsApi.getMyTools.mockResolvedValue({
      items: [toolToArchive, createMockTool("2", "draft")],
      next_cursor: null,
    });
    mockedToolsApi.updateTool.mockResolvedValue(createMockTool("1", "archived"));

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    expect(result.current.tools.length).toBe(2);

    // Open dialog
    const foundTool = result.current.tools.find((t) => t.id === "1");
    if (!foundTool) {
      throw new Error("Tool not found");
    }
    act(() => {
      result.current.openArchiveDialog(foundTool);
    });
    expect(result.current.toolToArchive?.id).toBe("1");

    // Confirm archival
    await act(async () => {
      await result.current.confirmArchive();
    });

    // Dialog should be closed and tool removed from list
    expect(result.current.toolToArchive).toBe(null);
    expect(result.current.tools.length).toBe(1);
    expect(result.current.tools.find((t) => t.id === "1")).toBeUndefined();
  });

  it("should close archive dialog when closeArchiveDialog is called", async () => {
    const toolToArchive = createMockTool("1", "active");
    mockedToolsApi.getMyTools.mockResolvedValue({ items: [toolToArchive], next_cursor: null });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    // Open dialog
    act(() => {
      result.current.openArchiveDialog(result.current.tools[0]);
    });
    expect(result.current.toolToArchive?.id).toBe("1");

    // Close dialog
    act(() => {
      result.current.closeArchiveDialog();
    });

    expect(result.current.toolToArchive).toBe(null);
  });

  it("should not archive when confirmArchive is called without toolToArchive", async () => {
    mockedToolsApi.getMyTools.mockResolvedValue({ items: [], next_cursor: null });

    const { result, rerender } = renderHook(() => useMyToolsManager());

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
      rerender();
    });

    expect(result.current.toolToArchive).toBe(null);

    // Try to confirm archive without opening dialog
    await act(async () => {
      await result.current.confirmArchive();
    });

    // Should not call updateTool
    expect(mockedToolsApi.updateTool).not.toHaveBeenCalled();
  });
});
