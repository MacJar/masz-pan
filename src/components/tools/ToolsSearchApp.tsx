import React, { useMemo } from "react";
import type { JSX } from "react";
import { useToolSearch } from "@/components/hooks/useToolSearch";
import SearchBar from "./SearchBar";
import LocationBanner from "./LocationBanner";
import SkeletonList from "./SkeletonList";
import ErrorState from "./ErrorState";
import EmptyState from "./EmptyState";
import ResultsList from "./ResultsList";
import PublicToolsGrid from "./PublicToolsGrid";
import { AnonymousLocationRequest } from "./AnonymousLocationRequest";

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

      {state.status === "anonymous" && <AnonymousLocationRequest onLocationFound={actions.startPublicNearby} />}

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
        <>
          {state.mode === "nearby" && (
            <h2 className="my-6 text-center text-xl font-semibold">Narzędzia w pobliżu (do 50 km)</h2>
          )}
          {state.mode === "search" && state.query.length > 0 && <h2 className="text-xl font-semibold">Wyniki wyszukiwania</h2>}
          {state.mode === "nearby" ? (
            <PublicToolsGrid
              items={state.items}
              onLoadMore={actions.loadNext}
              hasNext={Boolean(state.nextCursor)}
              isLoadingMore={state.isLoadingMore}
            />
          ) : (
            <ResultsList
              items={state.items}
              onLoadMore={actions.loadNext}
              hasNext={Boolean(state.nextCursor)}
              isLoadingMore={state.isLoadingMore}
            />
          )}
        </>
      )}
    </div>
  );
}
