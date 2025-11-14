import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import {
  getBalance,
  getLedger,
  getEligibleTools,
  claimSignupBonus,
  claimListingBonus,
  claimRescueBonus,
} from '@/lib/api/tokens.client';
import {
  TokenBalanceDto,
  TokenLedgerEntryViewModel,
  LedgerKind,
  BonusStateViewModel,
} from '@/components/tokens/tokens.types';

const transformLedgerEntry = (entry: any): TokenLedgerEntryViewModel => ({
  ...entry,
  formattedDate: new Date(entry.created_at).toLocaleString(),
  description: `Transakcja typu ${entry.kind} na kwotę ${entry.amount}`, // Placeholder
});

export const useTokensView = () => {
  const [balance, setBalance] = useState<TokenBalanceDto | null>(null);
  const [ledgerEntries, setLedgerEntries] = useState<TokenLedgerEntryViewModel[]>([]);
  const [ledgerCursor, setLedgerCursor] = useState<string | null>(null);
  const [ledgerFilter, setLedgerFilter] = useState<LedgerKind | null>(null);
  const [hasMore, setHasMore] = useState(true);

  const [bonusState, setBonusState] = useState<BonusStateViewModel>({
    signup: { isClaimed: true, isLoading: false }, // Assume claimed initially
    listing: { eligibleTools: [], claimsUsed: 3, isLoading: false }, // Assume used
    rescue: { isAvailable: false, isClaimedToday: true, isLoading: false }, // Assume unavailable
  });

  const [isLoading, setIsLoading] = useState({
    balance: true,
    ledger: true,
    bonusState: true,
  });
  const [error, setError] = useState<string | null>(null);

  const handleError = (err: unknown, defaultMessage: string) => {
    const message = err instanceof Error ? err.message : defaultMessage;
    setError(message);
    toast.error(message);
  };

  const fetchBalance = useCallback(async () => {
    try {
      setIsLoading((prev) => ({ ...prev, balance: true }));
      setError(null);
      const balanceData = await getBalance();
      setBalance(balanceData);
    } catch (err) {
      handleError(err, 'Nie udało się pobrać salda');
    } finally {
      setIsLoading((prev) => ({ ...prev, balance: false }));
    }
  }, []);

  const fetchLedger = useCallback(
    async (newFilter: LedgerKind | null = ledgerFilter, reset = false) => {
      if (!hasMore && !reset) return;

      setIsLoading((prev) => ({ ...prev, ledger: true }));
      if (reset) setError(null);
      try {
        const { entries, nextCursor } = await getLedger(reset ? null : ledgerCursor, newFilter);
        const transformedEntries = entries.map(transformLedgerEntry);
        setLedgerEntries((prev) => (reset ? transformedEntries : [...prev, ...transformedEntries]));
        setLedgerCursor(nextCursor);
        setHasMore(!!nextCursor);
      } catch (err) {
        handleError(err, 'Nie udało się pobrać historii transakcji');
      } finally {
        setIsLoading((prev) => ({ ...prev, ledger: false }));
      }
    },
    [ledgerFilter, hasMore, ledgerCursor]
  );
  
  const fetchBonusState = useCallback(async () => {
    // This function will be properly implemented once backend endpoints are ready.
    // For now, it simulates fetching state based on mocked data or initial assumptions.
    setIsLoading((prev) => ({ ...prev, bonusState: true }));
    setError(null);
    try {
      const tools = await getEligibleTools();
      // Mocked logic for bonus availability
      setBonusState({
        signup: { isClaimed: false, isLoading: false }, // Let's pretend it's available
        listing: { eligibleTools: tools, claimsUsed: 0, isLoading: false },
        rescue: {
          isAvailable: balance?.available === 0,
          isClaimedToday: false,
          isLoading: false,
        },
      });
    } catch (err) {
      handleError(err, 'Nie udało się pobrać stanu bonusów');
    } finally {
      setIsLoading((prev) => ({ ...prev, bonusState: false }));
    }
  }, [balance?.available]);


  useEffect(() => {
    fetchBalance();
    fetchLedger(ledgerFilter, true);
  }, []);

  useEffect(() => {
    // Fetch bonus state after balance is known
    if (balance !== null) {
        fetchBonusState();
    }
  }, [balance, fetchBonusState]);
  
  const refreshData = () => {
    fetchBalance();
    fetchLedger(ledgerFilter, true);
    fetchBonusState();
  };


  const loadMoreLedgerEntries = useCallback(async () => {
    if (!ledgerCursor || !hasMore || isLoading.ledger) return;
    fetchLedger(ledgerFilter, false);
  }, [ledgerCursor, hasMore, isLoading.ledger, fetchLedger, ledgerFilter]);

  const handleFilterChange = (newFilter: LedgerKind | null) => {
    const filter = newFilter === 'all' ? null : newFilter;
    setLedgerFilter(filter);
    setLedgerCursor(null);
    setHasMore(true);
    fetchLedger(filter, true);
  };

  const handleClaimSignupBonus = async () => {
    setBonusState((prev) => ({ ...prev, signup: { ...prev.signup, isLoading: true } }));
    try {
      const result = await claimSignupBonus();
      toast.success(`Przyznano ${result.amount} żetonów bonusu powitalnego!`);
      refreshData();
    } catch (error) {
      handleError(error, 'Nie udało się odebrać bonusu powitalnego.');
    } finally {
        // State will be updated on refreshData
    }
  };

  const handleClaimListingBonus = async (toolId: string) => {
    setBonusState((prev) => ({ ...prev, listing: { ...prev.listing, isLoading: true } }));
    try {
      const result = await claimListingBonus(toolId);
      toast.success(`Przyznano ${result.amount} żetonów za wystawienie narzędzia!`);
      refreshData();
    } catch (error) {
      handleError(error, 'Nie udało się odebrać bonusu za wystawienie.');
    } finally {
        // State will be updated on refreshData
    }
  };

  const handleClaimRescueBonus = async () => {
    setBonusState((prev) => ({ ...prev, rescue: { ...prev.rescue, isLoading: true } }));
    try {
      const result = await claimRescueBonus();
      toast.success(`Przyznano ${result.amount} żeton ratunkowy!`);
      refreshData();
    } catch (error) {
      handleError(error, 'Nie udało się odebrać bonusu ratunkowego.');
    } finally {
       // State will be updated on refreshData
    }
  };


  return {
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
  };
};
