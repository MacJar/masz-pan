import React from "react";
import type { ToolSearchItemVM } from "@/lib/api/tools.search.client";
import NearbyToolCard from "./NearbyToolCard";
import InfiniteScrollSentinel from "../InfiniteScrollSentinel";

export interface NearbyToolsGridProps {
  items: ToolSearchItemVM[];
  onLoadMore?: () => void;
  hasNext?: boolean;
  isLoadingMore?: boolean;
}

export default function NearbyToolsGrid(props: NearbyToolsGridProps) {
  const { items, onLoadMore, hasNext, isLoadingMore } = props;
  return (
    <div>
      <div className="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 xl:gap-x-8">
        {items.map((item) => (
          <NearbyToolCard key={item.id} tool={item} />
        ))}
      </div>
      {hasNext && <InfiniteScrollSentinel onLoadMore={onLoadMore} isLoading={isLoadingMore} />}
    </div>
  );
}
