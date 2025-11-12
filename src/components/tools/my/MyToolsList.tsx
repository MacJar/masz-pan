import React from 'react';
import type { MyToolListItemViewModel } from '@/components/hooks/useMyToolsManager';
import ToolRow from './ToolRow';
import InfiniteScrollSentinel from '@/components/tools/InfiniteScrollSentinel';
import type { ToolStatus } from '@/types';

type MyToolsListProps = {
  tools: MyToolListItemViewModel[];
  onLoadMore: () => void;
  onUpdateTool: (toolId: string, newStatus: ToolStatus) => Promise<void>;
  onArchiveTool: (tool: MyToolListItemViewModel) => void;
  hasNextPage: boolean;
};

const MyToolsList: React.FC<MyToolsListProps> = ({ tools, onLoadMore, onUpdateTool, onArchiveTool, hasNextPage }) => {
  return (
    <div>
      {tools.map(tool => (
        <ToolRow key={tool.id} tool={tool} onUpdate={onUpdateTool} onArchive={onArchiveTool} />
      ))}
      <InfiniteScrollSentinel hasNextPage={hasNextPage} onLoadMore={onLoadMore} />
    </div>
  );
};

export default MyToolsList;
