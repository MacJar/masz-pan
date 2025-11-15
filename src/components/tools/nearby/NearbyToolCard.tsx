import React from "react";
import type { ToolSearchItemVM } from "@/lib/api/tools.search.client";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { cn } from "@/lib/utils";

export interface NearbyToolCardProps {
  tool: ToolSearchItemVM;
}

export default function NearbyToolCard({ tool }: NearbyToolCardProps) {
  return (
    <a href={`/tools/${tool.id}`} className="block">
      <Card className="overflow-hidden">
        <CardContent className="p-0">
          <div className="aspect-h-1 aspect-w-1 w-full overflow-hidden xl:aspect-h-8 xl:aspect-w-7">
            {tool.mainImageUrl ? (
              <img
                src={tool.mainImageUrl}
                alt={tool.name}
                className="h-full w-full object-cover object-center group-hover:opacity-75"
              />
            ) : (
              <div className="flex h-full w-full items-center justify-center bg-muted">
                <span className="text-sm text-muted-foreground">Brak zdjęcia</span>
              </div>
            )}
          </div>
        </CardContent>
        <CardFooter className="p-4">
          <div>
            <h3 className="text-md font-semibold text-gray-900">{tool.name}</h3>
            <p className={cn("text-sm", tool.distanceMeters > 20000 ? "text-amber-600" : "text-gray-500")}>
              {tool.distanceText}
            </p>
          </div>
        </CardFooter>
      </Card>
    </a>
  );
}
