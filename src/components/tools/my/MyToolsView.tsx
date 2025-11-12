import React from 'react';
import { useMyToolsManager } from '@/components/hooks/useMyToolsManager';
import StatusFilter from './StatusFilter';
import MyToolsList from './MyToolsList';
import SkeletonList from '@/components/tools/SkeletonList';
import ErrorState from '@/components/tools/ErrorState';
import EmptyState from '@/components/tools/EmptyState';
import ActionConfirmationDialog from './ActionConfirmationDialog';

const MyToolsView = () => {
  const {
    tools,
    statusFilter,
    isLoading,
    error,
    hasNextPage,
    setStatusFilter,
    loadMore,
    updateToolStatus,
    toolToArchive,
    openArchiveDialog,
    closeArchiveDialog,
    confirmArchive,
  } = useMyToolsManager();

  const renderContent = () => {
    if (isLoading && tools.length === 0) {
      return <SkeletonList />;
    }
    if (error) {
      return <ErrorState message={error.message} onRetry={() => {}} />; // TODO: Implement onRetry
    }
    if (tools.length === 0) {
      return <EmptyState message="Nie znaleziono narzędzi." />;
    }
    return (
      <MyToolsList
        tools={tools}
        onLoadMore={loadMore}
        onUpdateTool={updateToolStatus}
        onArchiveTool={openArchiveDialog}
        hasNextPage={hasNextPage}
      />
    );
  };

  return (
    <div>
      <StatusFilter activeFilter={statusFilter} onFilterChange={setStatusFilter} />
      {renderContent()}
      
      {toolToArchive && (
        <ActionConfirmationDialog
          isOpen={!!toolToArchive}
          onOpenChange={(isOpen) => !isOpen && closeArchiveDialog()}
          onConfirm={confirmArchive}
          title={`Czy na pewno chcesz zarchiwizować "${toolToArchive.name}"?`}
          description="Tej operacji nie można cofnąć. Narzędzie zostanie usunięte z publicznej listy i nie będzie można go już edytować."
        />
      )}
    </div>
  );
};

export default MyToolsView;
