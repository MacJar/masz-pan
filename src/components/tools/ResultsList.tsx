import React from "react";
import type { ToolSearchItemVM } from "@/lib/api/tools.search.client";
import ToolCard from "./ToolCard";
import InfiniteScrollSentinel from "./InfiniteScrollSentinel";

export interface ResultsListProps {
  items: ToolSearchItemVM[];
  onLoadMore(): void;
  hasNext: boolean;
  isLoadingMore: boolean;
}

export default function ResultsList(props: ResultsListProps): JSX.Element {
  const { items, onLoadMore, hasNext, isLoadingMore } = props;
  return (
    <div className="space-y-3">
      <ul className="space-y-3">
        {items.map((item) => (
          <li key={item.id}>
            <ToolCard item={item} />
          </li>
        ))}
      </ul>
      {hasNext && <InfiniteScrollSentinel onIntersect={onLoadMore} disabled={isLoadingMore} />}
      {isLoadingMore && (
        <div className="text-center text-xs text-muted-foreground" role="status" aria-live="polite">
          Ładowanie…
        </div>
      )}
    </div>
  );
}


