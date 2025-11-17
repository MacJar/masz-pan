import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import type { ToolSearchPageDTO } from "@/types";
import {
  fetchNearbyTools,
  fetchTools,
  mapPageToVM,
  type ToolSearchItemVM,
  fetchPublicNearbyTools,
} from "@/lib/api/tools.search.client";
import { useDebouncedValue } from "./useDebouncedValue";
import type { GeolocationCoordinates } from "./AnonymousLocationRequest";

export type ToolSearchMode = "search" | "nearby";
export type ToolSearchStatus = "idle" | "loading" | "ready" | "error" | "anonymous";

export interface ToolSearchState {
  query: string;
  items: ToolSearchItemVM[];
  nextCursor: string | null;
  status: ToolSearchStatus;
  mode: ToolSearchMode;
  isLoadingMore: boolean;
  errorCode?: string;
  errorDetails?: unknown;
}

export interface ToolSearchActions {
  setQuery(q: string): void;
  submit(): void;
  loadNext(): void;
  retry(): void;
  startPublicNearby(coords: GeolocationCoordinates): void;
}

export function useToolSearch(initialQuery?: string): [ToolSearchState, ToolSearchActions] {
  const [query, setQuery] = useState<string>(initialQuery?.slice(0, 128) ?? "");
  const queryDebounced = useDebouncedValue(query, 400);

  const [items, setItems] = useState<ToolSearchItemVM[]>([]);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [status, setStatus] = useState<ToolSearchStatus>("idle");
  const [mode, setMode] = useState<ToolSearchMode>("search");
  const [isLoadingMore, setIsLoadingMore] = useState<boolean>(false);
  const [errorCode, setErrorCode] = useState<string | undefined>(undefined);
  const [errorDetails, setErrorDetails] = useState<unknown | undefined>(undefined);

  const abortRef = useRef<AbortController | null>(null);
  const lastOpRef = useRef<"first" | "next" | null>(null);
  const lastQueryRef = useRef<string>(query);
  const lastCoordsRef = useRef<GeolocationCoordinates | null>(null);

  const resetError = useCallback(() => {
    setErrorCode(undefined);
    setErrorDetails(undefined);
  }, []);

  const startFirstPage = useCallback(
    (q: string) => {
      // Cancel any previous request
      abortRef.current?.abort();
      abortRef.current = new AbortController();
      lastOpRef.current = "first";
      lastQueryRef.current = q;

      setStatus("loading");
      setIsLoadingMore(false);
      setItems([]);
      setNextCursor(null);
      resetError();

      fetchTools({ q, limit: 20, signal: abortRef.current.signal })
        .then((page: ToolSearchPageDTO) => {
          const vm = mapPageToVM(page);
          setItems(vm.items);
          setNextCursor(vm.next_cursor);
          setStatus("ready");
        })
        .catch((err: unknown) => {
          // Ignore abort noise
          if (abortRef.current?.signal.aborted) {
            return;
          }
          const code = (err as { error?: { code?: string; details?: unknown } })?.error?.code ?? "internal_error";
          const details = (err as { error?: { details?: unknown } })?.error?.details;
          setErrorCode(code);
          setErrorDetails(details);
          setStatus("error");
        });
    },
    [resetError]
  );

  const startNearby = useCallback(() => {
    // Cancel any previous request
    abortRef.current?.abort();
    abortRef.current = new AbortController();
    lastOpRef.current = "first";
    lastQueryRef.current = "";

    setStatus("loading");
    setMode("nearby");
    setIsLoadingMore(false);
    setItems([]);
    setNextCursor(null);
    resetError();

    fetchNearbyTools({ limit: 20, signal: abortRef.current.signal })
      .then((page: ToolSearchPageDTO) => {
        const vm = mapPageToVM(page);
        setItems(vm.items);
        setNextCursor(vm.next_cursor);
        setStatus("ready");
      })
      .catch((err: unknown) => {
        // Ignore abort noise
        if (abortRef.current?.signal.aborted) {
          return;
        }
        const code = (err as { error?: { code?: string; details?: unknown } })?.error?.code ?? "internal_error";
        const details = (err as { error?: { details?: unknown } })?.error?.details;
        setErrorCode(code);
        setErrorDetails(details);
        if (code === "auth_required") {
          setStatus("anonymous");
        } else {
          setStatus("error");
        }
      });
  }, [resetError]);

  const startPublicNearby = useCallback(
    (coords: GeolocationCoordinates) => {
      // Cancel any previous request
      abortRef.current?.abort();
      abortRef.current = new AbortController();
      lastOpRef.current = "first";
      lastQueryRef.current = "";
      lastCoordsRef.current = coords;

      setStatus("loading");
      setMode("nearby");
      setIsLoadingMore(false);
      setItems([]);
      setNextCursor(null);
      resetError();

      fetchPublicNearbyTools({
        limit: 20,
        signal: abortRef.current.signal,
        lat: coords.latitude,
        lon: coords.longitude,
      })
        .then((page: ToolSearchPageDTO) => {
          const vm = mapPageToVM(page);
          setItems(vm.items);
          setNextCursor(vm.next_cursor);
          setStatus("ready");
        })
        .catch((err: unknown) => {
          // Ignore abort noise
          if (abortRef.current?.signal.aborted) {
            return;
          }
          const code = (err as { error?: { code?: string; details?: unknown } })?.error?.code ?? "internal_error";
          const details = (err as { error?: { details?: unknown } })?.error?.details;
          setErrorCode(code);
          setErrorDetails(details);
          setStatus("error");
        });
    },
    [resetError]
  );

  const loadNext = useCallback(() => {
    if (!nextCursor || isLoadingMore || status === "loading") {
      return;
    }
    const q = lastQueryRef.current;
    abortRef.current?.abort();
    abortRef.current = new AbortController();
    lastOpRef.current = "next";

    setIsLoadingMore(true);
    resetError();

    let promise: Promise<ToolSearchPageDTO>;
    if (mode === "search") {
      promise = fetchTools({ q, limit: 20, cursor: nextCursor, signal: abortRef.current.signal });
    } else if (status === "anonymous" && lastCoordsRef.current) {
      promise = fetchPublicNearbyTools({
        limit: 20,
        cursor: nextCursor,
        signal: abortRef.current.signal,
        lat: lastCoordsRef.current.latitude,
        lon: lastCoordsRef.current.longitude,
      });
    } else {
      promise = fetchNearbyTools({ limit: 20, cursor: nextCursor, signal: abortRef.current.signal });
    }

    promise
      .then((page: ToolSearchPageDTO) => {
        const vm = mapPageToVM(page);
        setItems((prev) => prev.concat(vm.items));
        setNextCursor(vm.next_cursor);
        setIsLoadingMore(false);
      })
      .catch((err: unknown) => {
        // Ignore abort noise
        if (abortRef.current?.signal.aborted) {
          return;
        }
        const code = (err as { error?: { code?: string; details?: unknown } })?.error?.code ?? "internal_error";
        const details = (err as { error?: { details?: unknown } })?.error?.details;
        // Special-case invalid cursor: reset pagination but keep current items
        if (code === "validation_error") {
          setNextCursor(null);
          setIsLoadingMore(false);
          return;
        }
        setErrorCode(code);
        setErrorDetails(details);
        setIsLoadingMore(false);
      });
  }, [isLoadingMore, nextCursor, resetError, status, mode]);

  const submit = useCallback(() => {
    const q = query.trim();
    if (q.length < 1 || q.length > 128) {
      return;
    }
    startFirstPage(q);
  }, [query, startFirstPage]);

  const retry = useCallback(() => {
    if (lastOpRef.current === "next") {
      // On next-page failure we prefer retrying the first page to simplify state
      if (mode === "search") {
        startFirstPage(lastQueryRef.current.trim());
      } else if (status === "anonymous" && lastCoordsRef.current) {
        startPublicNearby(lastCoordsRef.current);
      } else {
        startNearby();
      }
      return;
    }
    if (mode === "search") {
      startFirstPage(lastQueryRef.current.trim());
    } else if (status === "anonymous" && lastCoordsRef.current) {
      startPublicNearby(lastCoordsRef.current);
    } else {
      startNearby();
    }
  }, [startFirstPage, startNearby, startPublicNearby, mode, status]);

  // Trigger on debounced query change
  useEffect(() => {
    const q = queryDebounced.trim();
    if (q.length < 1 || q.length > 128) {
      // invalid – reset loading flags, keep items as-is, set idle if nothing loaded
      if (status === "loading") {
        setStatus("idle");
      }
      return;
    }
    startFirstPage(q);
  }, [queryDebounced, startFirstPage]); // eslint-disable-line react-hooks/exhaustive-deps

  // Initial load
  useEffect(() => {
    if (initialQuery) {
      startFirstPage(initialQuery);
    } else {
      startNearby();
    }
  }, [initialQuery, startFirstPage, startNearby]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      abortRef.current?.abort();
    };
  }, []);

  const state: ToolSearchState = useMemo(
    () => ({
      query,
      items,
      nextCursor,
      status,
      mode,
      isLoadingMore,
      errorCode,
      errorDetails,
    }),
    [errorCode, errorDetails, isLoadingMore, items, nextCursor, query, status, mode]
  );

  const actions: ToolSearchActions = useMemo(
    () => ({
      setQuery,
      submit,
      loadNext,
      retry,
      startPublicNearby,
    }),
    [loadNext, retry, submit, startPublicNearby]
  );

  return [state, actions];
}
