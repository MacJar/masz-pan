import React from "react";
import type { ToolSearchItemVM } from "@/lib/api/tools.search.client";

export interface ToolCardProps {
  item: ToolSearchItemVM;
}

export default function ToolCard(props: ToolCardProps): JSX.Element {
  const { item } = props;
  return (
    <div className="rounded-md border p-4">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium">{item.name}</h3>
        <p className="text-xs text-muted-foreground">{item.distanceText}</p>
      </div>
    </div>
  );
}


