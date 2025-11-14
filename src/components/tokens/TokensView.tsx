import React from 'react';
import { useTokensView } from '@/components/hooks/useTokensView';
import { TokenBalanceCard } from './TokenBalanceCard';
import { LedgerList } from './LedgerList';
import { BonusActions } from './BonusActions';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Toaster } from '@/components/ui/sonner';
import { AlertCircle } from 'lucide-react';
import { Button } from '../ui/button';

const TokensView = () => {
  const {
    balance,
    ledgerEntries,
    bonusState,
    isLoading,
    error,
    hasMore,
    loadMoreLedgerEntries,
    handleFilterChange,
    handleClaimSignupBonus,
    handleClaimListingBonus,
    handleClaimRescueBonus,
    refreshData,
  } = useTokensView();

  if (error && !balance && ledgerEntries.length === 0) {
    return (
      <div className="container mx-auto py-8">
        <Alert variant="destructive" className="max-w-md mx-auto">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Wystąpił błąd</AlertTitle>
          <AlertDescription>
            <p>{error}</p>
            <Button onClick={refreshData} variant="secondary" className="mt-4">
              Spróbuj ponownie
            </Button>
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <Toaster richColors />
      <div>
        <h1 className="text-3xl font-bold mb-2">Moje żetony</h1>
        <p className="text-muted-foreground">
          Zarządzaj swoimi żetonami, przeglądaj historię i zdobywaj bonusy.
        </p>
      </div>

      <TokenBalanceCard balance={balance} isLoading={isLoading.balance} />

      <BonusActions
        bonusState={bonusState}
        balance={balance}
        isLoading={isLoading.bonusState}
        onClaimSignup={handleClaimSignupBonus}
        onClaimListing={handleClaimListingBonus}
        onClaimRescue={handleClaimRescueBonus}
      />

      <LedgerList
        entries={ledgerEntries}
        isLoading={isLoading.ledger}
        hasMore={hasMore}
        onLoadMore={loadMoreLedgerEntries}
        onFilterChange={handleFilterChange}
      />
    </div>
  );
};

export default TokensView;
