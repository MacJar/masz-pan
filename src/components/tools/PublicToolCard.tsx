import React from "react";
import type { ToolSummaryViewModel } from "@/types";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { MapPin } from "lucide-react";

interface PublicToolCardProps {
  tool: ToolSummaryViewModel & { distanceText?: string };
}

const PublicToolCard: React.FC<PublicToolCardProps> = ({ tool }) => {
  return (
    <a href={tool.href} className="block hover:shadow-lg transition-shadow duration-200 h-full">
      <Card className="flex flex-col h-full">
        {tool.imageUrl && <img src={tool.imageUrl} alt={tool.name} className="w-full h-48 object-cover rounded-t-md" />}
        <CardHeader className="flex-grow pb-2">
          <CardTitle>{tool.name}</CardTitle>
          {tool.description && <CardDescription>{tool.description}</CardDescription>}
        </CardHeader>
        <CardContent>
          {tool.distanceText && (
            <Badge variant="secondary">
              <MapPin className="mr-1 h-3 w-3" />
              {tool.distanceText}
            </Badge>
          )}
        </CardContent>
      </Card>
    </a>
  );
};

export default PublicToolCard;
