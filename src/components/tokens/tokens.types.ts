// DTOs (from API)

// GET /api/tokens/balance
export interface TokenBalanceDto {
  user_id: string;
  total: number;
  held: number;
  available: number;
}

// GET /api/tokens/ledger
export type LedgerKind = 'debit' | 'credit' | 'hold' | 'release' | 'transfer' | 'award';

export interface TokenLedgerEntryDto {
  id: string;
  kind: LedgerKind;
  amount: number;
  details: Record<string, any>;
  created_at: string; // ISO 8601
}

// GET /api/tools?bonus_eligible=true
export interface EligibleToolDto {
  id: string;
  name: string;
}

// ViewModels (for UI)

// Type used by components to store bonus state
export interface BonusStateViewModel {
  signup: {
    isClaimed: boolean;
    isLoading: boolean;
  };
  listing: {
    eligibleTools: EligibleToolDto[];
    claimsUsed: number;
    isLoading: boolean;
  };
  rescue: {
    isAvailable: boolean; // Dostępne saldo == 0
    isClaimedToday: boolean;
    isLoading: boolean;
  };
}

// Enriched ledger entry type for easier display
export interface TokenLedgerEntryViewModel extends TokenLedgerEntryDto {
  formattedDate: string;
  description: string;
}
