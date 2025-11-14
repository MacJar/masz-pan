import React from "react";
import type { ToolSummaryViewModel } from "@/types";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

interface PublicToolCardProps {
  tool: ToolSummaryViewModel;
}

const PublicToolCard: React.FC<PublicToolCardProps> = ({ tool }) => {
  return (
    <a href={tool.href} className="block hover:shadow-lg transition-shadow duration-200">
      <Card>
        {tool.imageUrl && (
          <img src={tool.imageUrl} alt={tool.name} className="w-full h-48 object-cover rounded-t-md" />
        )}
        <CardHeader>
          <CardTitle>{tool.name}</CardTitle>
        </CardHeader>
        <CardContent>
          <CardDescription>{tool.description}</CardDescription>
        </CardContent>
      </Card>
    </a>
  );
};

export default PublicToolCard;
