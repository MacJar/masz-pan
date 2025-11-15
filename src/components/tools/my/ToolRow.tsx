import React from 'react';
import type { MyToolListItemViewModel } from '@/components/hooks/useMyToolsManager';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import type { ToolStatus } from '@/types';

type ToolRowProps = {
  tool: MyToolListItemViewModel;
  onUpdate: (toolId: string, newStatus: ToolStatus) => Promise<void>;
  onArchive: (tool: MyToolListItemViewModel) => void;
};

const ToolRow: React.FC<ToolRowProps> = ({ tool, onUpdate, onArchive }) => {
  return (
    <div className="flex items-center justify-between p-4 border-b">
      <div className="flex items-center space-x-4">
        {tool.imageUrl && (
          <img
            src={tool.imageUrl}
            alt={tool.name}
            className="w-16 h-16 object-cover rounded-md"
          />
        )}
        <div className="flex flex-col">
          <span className="font-semibold">{tool.name}</span>
          <span className="text-sm text-gray-500">
            Utworzono: {tool.createdAt} | Ostatnia zmiana: {tool.updatedAt}
          </span>
        </div>
      </div>
      <div className="flex items-center space-x-4">
        <Badge variant={tool.status === 'active' ? 'default' : 'secondary'}>
          {tool.status}
        </Badge>
        <div className="flex space-x-2">
          {tool.canEdit && <Button variant="outline" size="sm" onClick={() => window.location.href = `/tools/${tool.id}/edit`}>Edytuj</Button>}
          {tool.canPublish && <Button size="sm" onClick={() => onUpdate(tool.id, 'active')}>Publikuj</Button>}
          {tool.canUnpublish && <Button variant="outline" size="sm" onClick={() => onUpdate(tool.id, 'draft')}>Cofnij publikację</Button>}
          {tool.canArchive && <Button variant="destructive" size="sm" onClick={() => onArchive(tool)}>Archiwizuj</Button>}
        </div>
      </div>
    </div>
  );
};

export default ToolRow;
