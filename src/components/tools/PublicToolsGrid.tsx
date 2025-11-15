import React from "react";
import type { ToolSearchItemVM } from "@/lib/api/tools.search.client";
import PublicToolCard from "@/components/tools/PublicToolCard";
import InfiniteScrollSentinel from "./InfiniteScrollSentinel";

interface PublicToolsGridProps {
  items: ToolSearchItemVM[];
  onLoadMore: () => void;
  hasNext: boolean;
  isLoadingMore: boolean;
}

const PublicToolsGrid: React.FC<PublicToolsGridProps> = ({ items, onLoadMore, hasNext, isLoadingMore }) => {
  return (
    <section>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {items.map((item) => (
          <PublicToolCard
            key={item.id}
            tool={{
              id: item.id,
              name: item.name,
              imageUrl: item.mainImageUrl,
              href: `/tools/${item.id}`,
              description: "", // PublicToolCard requires description, but search results don't have it.
              distanceText: item.distanceText,
            }}
          />
        ))}
      </div>
      <InfiniteScrollSentinel onVisible={onLoadMore} enabled={hasNext && !isLoadingMore} />
    </section>
  );
};

export default PublicToolsGrid;
