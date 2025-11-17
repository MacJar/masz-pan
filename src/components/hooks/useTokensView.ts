import { useState, useEffect, useCallback, useRef } from "react";
import { toast } from "sonner";
import {
  getBalance,
  getLedger,
  getBonusState,
  claimSignupBonus,
  claimListingBonus,
  claimRescueBonus,
} from "@/lib/api/tokens.client";
import type {
  TokenBalanceDto,
  TokenLedgerEntryDto,
  TokenLedgerEntryViewModel,
  TokenLedgerKind,
  BonusStateViewModel,
} from "@/types";

const formatLedgerDescription = (entry: TokenLedgerEntryDto): string => {
  const details = entry.details ?? {};

  if (entry.kind === "award") {
    const awardType = details.award;
    switch (awardType) {
      case "signup_bonus":
        return "Bonus powitalny";
      case "listing_bonus":
        return "Bonus za wystawienie narzędzia";
      case "rescue_claim":
        return "Bonus ratunkowy";
      default:
        return "Bonus żetonów";
    }
  }

  if (details.reason) {
    return details.reason as string;
  }

  if (details.description) {
    return details.description as string;
  }

  return `Transakcja typu ${entry.kind}`;
};

const dateFormatter = new Intl.DateTimeFormat("pl-PL", {
  dateStyle: "medium",
  timeStyle: "short",
});

const transformLedgerEntry = (entry: TokenLedgerEntryDto): TokenLedgerEntryViewModel => {
  let formattedDate = "—";
  if (entry.created_at) {
    const parsed = new Date(entry.created_at);
    formattedDate = Number.isNaN(parsed.valueOf()) ? "—" : dateFormatter.format(parsed);
  }

  return {
    ...entry,
    formattedDate,
    description: formatLedgerDescription(entry),
  };
};

type ActionFeedback = { type: "success" | "error"; message: string } | null;

export const useTokensView = () => {
  const [balance, setBalance] = useState<TokenBalanceDto | null>(null);
  const [ledgerEntries, setLedgerEntries] = useState<TokenLedgerEntryViewModel[]>([]);
  const [ledgerCursor, setLedgerCursor] = useState<string | null>(null);
  const [ledgerFilter, setLedgerFilter] = useState<TokenLedgerKind | null>(null);
  const [hasMore, setHasMore] = useState(true);

  const [bonusState, setBonusState] = useState<BonusStateViewModel | null>(null);

  const [isLoading, setIsLoading] = useState({
    balance: true,
    ledger: true,
    bonusState: true,
  });
  const [error, setError] = useState<string | null>(null);
  const [actionFeedback, setActionFeedback] = useState<ActionFeedback>(null);
  const hasMountedRef = useRef(false);

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
      handleError(err, "Nie udało się pobrać salda");
    } finally {
      setIsLoading((prev) => ({ ...prev, balance: false }));
    }
  }, []);

  const fetchLedger = useCallback(
    async (newFilter: TokenLedgerKind | null = ledgerFilter, reset = false) => {
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
        handleError(err, "Nie udało się pobrać historii transakcji");
      } finally {
        setIsLoading((prev) => ({ ...prev, ledger: false }));
      }
    },
    [ledgerFilter, hasMore, ledgerCursor]
  );

  const fetchBonusState = useCallback(async () => {
    setIsLoading((prev) => ({ ...prev, bonusState: true }));
    setError(null);
    try {
      const state = await getBonusState();
      setBonusState(state);
    } catch (err) {
      handleError(err, "Nie udało się pobrać stanu bonusów");
    } finally {
      setIsLoading((prev) => ({ ...prev, bonusState: false }));
    }
  }, []);

  useEffect(() => {
    if (hasMountedRef.current) return;
    hasMountedRef.current = true;
    fetchBalance();
    fetchLedger(ledgerFilter, true);
    fetchBonusState();
  }, [fetchBalance, fetchLedger, fetchBonusState, ledgerFilter]);

  const refreshData = () => {
    fetchBalance();
    fetchLedger(ledgerFilter, true);
    fetchBonusState();
  };

  const loadMoreLedgerEntries = useCallback(async () => {
    if (!ledgerCursor || !hasMore || isLoading.ledger) return;
    fetchLedger(ledgerFilter, false);
  }, [ledgerCursor, hasMore, isLoading.ledger, fetchLedger, ledgerFilter]);

  const handleFilterChange = (newFilter: TokenLedgerKind | null) => {
    const filter = newFilter === "all" ? null : newFilter;
    setLedgerFilter(filter);
    setLedgerCursor(null);
    setHasMore(true);
    fetchLedger(filter, true);
  };

  const clearActionFeedback = () => setActionFeedback(null);

  const handleClaimSignupBonus = async () => {
    const fallbackMessage = "Nie udało się odebrać bonusu powitalnego.";
    setActionFeedback(null);
    setBonusState((prev) =>
      prev
        ? {
            ...prev,
            signup: { ...prev.signup, isLoading: true },
          }
        : prev
    );
    try {
      const result = await claimSignupBonus();
      const amount = result?.amount ?? 0;
      toast.success(`Przyznano ${amount} żetonów bonusu powitalnego!`);
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              signup: { isClaimed: true, isLoading: false },
            }
          : prev
      );
      setActionFeedback({
        type: "success",
        message: `Przyznano ${amount} żetonów bonusu powitalnego.`,
      });
      refreshData();
    } catch (err) {
      const message = err instanceof Error ? err.message : fallbackMessage;
      setActionFeedback({ type: "error", message });
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              signup: { ...prev.signup, isLoading: false },
            }
          : prev
      );
      handleError(err, fallbackMessage);
    }
  };

  const handleClaimListingBonus = async (toolId: string) => {
    const fallbackMessage = "Nie udało się odebrać bonusu za wystawienie.";
    setActionFeedback(null);
    setBonusState((prev) =>
      prev
        ? {
            ...prev,
            listing: { ...prev.listing, isLoading: true },
          }
        : prev
    );
    try {
      const result = await claimListingBonus(toolId);
      const amount = result?.amount ?? 0;
      toast.success(`Przyznano ${amount} żetonów za wystawienie narzędzia!`);
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              listing: {
                ...prev.listing,
                isLoading: false,
                claimsUsed: result?.count_used ?? prev.listing.claimsUsed,
              },
            }
          : prev
      );
      setActionFeedback({
        type: "success",
        message: `Przyznano ${amount} żetonów za wystawienie narzędzia.`,
      });
      refreshData();
    } catch (err) {
      const message = err instanceof Error ? err.message : fallbackMessage;
      setActionFeedback({ type: "error", message });
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              listing: { ...prev.listing, isLoading: false },
            }
          : prev
      );
      handleError(err, fallbackMessage);
    }
  };

  const handleClaimRescueBonus = async () => {
    const fallbackMessage = "Nie udało się odebrać bonusu ratunkowego.";
    setActionFeedback(null);
    setBonusState((prev) =>
      prev
        ? {
            ...prev,
            rescue: { ...prev.rescue, isLoading: true },
          }
        : prev
    );
    try {
      const result = await claimRescueBonus();
      const amount = result?.amount ?? 0;
      toast.success(`Przyznano ${amount} żeton ratunkowy!`);
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              rescue: {
                ...prev.rescue,
                isLoading: false,
                isClaimedToday: true,
                isAvailable: false,
              },
            }
          : prev
      );
      setActionFeedback({
        type: "success",
        message: `Przyznano ${amount} żeton ratunkowy.`,
      });
      refreshData();
    } catch (err) {
      const message = err instanceof Error ? err.message : fallbackMessage;
      setActionFeedback({ type: "error", message });
      setBonusState((prev) =>
        prev
          ? {
              ...prev,
              rescue: { ...prev.rescue, isLoading: false },
            }
          : prev
      );
      handleError(err, fallbackMessage);
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
    actionFeedback,
    clearActionFeedback,
  };
};
