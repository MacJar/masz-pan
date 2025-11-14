import React from "react";
import type { ToolSummaryViewModel } from "@/types";
import PublicToolCard from "@/components/tools/PublicToolCard";

interface PublicToolsGridProps {
  tools: ToolSummaryViewModel[];
}

const PublicToolsGrid: React.FC<PublicToolsGridProps> = ({ tools }) => {
  if (tools.length === 0) {
    return (
      <section>
        <h2 className="text-2xl font-semibold mb-4">Narzędzia</h2>
        <p className="text-muted-foreground">Użytkownik nie udostępnia obecnie żadnych narzędzi.</p>
      </section>
    );
  }

  return (
    <section>
      <h2 className="text-2xl font-semibold mb-4">Narzędzia</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {tools.map((tool) => (
          <PublicToolCard key={tool.id} tool={tool} />
        ))}
      </div>
    </section>
  );
};

export default PublicToolsGrid;
