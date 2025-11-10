import React, { useMemo } from "react";
import type { JSX } from "react";
import { useToolSearch } from "@/components/hooks/useToolSearch";
import SearchBar from "./SearchBar";
import LocationBanner from "./LocationBanner";
import SkeletonList from "./SkeletonList";
import ErrorState from "./ErrorState";
import EmptyState from "./EmptyState";
import ResultsList from "./ResultsList";

export interface ToolsSearchAppProps {
  initialQuery?: string;
}

export default function ToolsSearchApp(props: ToolsSearchAppProps): JSX.Element {
  const [state, actions] = useToolSearch(props.initialQuery);

  const showLocationBanner = useMemo(() => {
    if (state.errorCode === "profile_location_missing") return true;
    if (state.status === "ready" && state.items.length === 0 && state.query.trim().length > 0) return true;
    return false;
  }, [state.errorCode, state.items.length, state.query, state.status]);

  return (
    <div className="space-y-4">
      <SearchBar
        value={state.query}
        onChange={actions.setQuery}
        onSubmit={actions.submit}
        isPending={state.status === "loading"}
      />

      <LocationBanner
        visible={showLocationBanner}
        reason={state.errorCode === "profile_location_missing" ? "missing_location" : "no_results"}
      />

      {state.status === "loading" && <SkeletonList />}

      {state.status === "error" && (
        <ErrorState
          errorCode={state.errorCode ?? "internal_error"}
          details={state.errorDetails}
          onRetry={actions.retry}
        />
      )}

      {state.status === "ready" && state.items.length === 0 && <EmptyState query={state.query} />}

      {state.status === "ready" && state.items.length > 0 && (
        <ResultsList
          items={state.items}
          onLoadMore={actions.loadNext}
          hasNext={Boolean(state.nextCursor)}
          isLoadingMore={state.isLoadingMore}
        />
      )}
    </div>
  );
}
