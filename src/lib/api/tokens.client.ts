import type {
  TokenBalanceDto,
  TokenLedgerEntryDto,
  EligibleToolDto,
  TokenLedgerKind,
} from '@/types';
import { handleApiResponse } from './responses';

export const getBalance = async (): Promise<TokenBalanceDto> => {
  const response = await fetch('/api/tokens/balance');
  return handleApiResponse<TokenBalanceDto>(response);
};

export const getLedger = async (
  cursor: string | null = null,
  kind: TokenLedgerKind | null = null
): Promise<{ entries: TokenLedgerEntryDto[]; nextCursor: string | null }> => {
  const params = new URLSearchParams();
  if (cursor) {
    params.append('cursor', cursor);
  }
  if (kind) {
    params.append('kind', kind);
  }
  const response = await fetch(`/api/tokens/ledger?${params.toString()}`);
  return handleApiResponse<{ entries: TokenLedgerEntryDto[]; nextCursor: string | null }>(response);
};

export const getEligibleTools = async (): Promise<EligibleToolDto[]> => {
  // TODO: Backend implementation needed
  // This is a placeholder until the endpoint is ready.
  console.warn('API endpoint for eligible tools is not implemented. Returning mock data.');
  return Promise.resolve([
    { id: '1', name: 'Wiertarka udarowa' },
    { id: '2', name: 'Młot pneumatyczny' },
  ]);
  // const response = await fetch('/api/tools?bonus_eligible=true');
  // return handleApiResponse<EligibleToolDto[]>(response);
};

export const claimSignupBonus = async (): Promise<{ awarded: boolean; amount: number }> => {
  const response = await fetch('/api/tokens/award/signup', { method: 'POST' });
  return handleApiResponse(response);
};

export const claimListingBonus = async (
  toolId: string
): Promise<{ awarded: boolean; amount: number; count_used: number }> => {
  const response = await fetch('/api/tokens/award/listing', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tool_id: toolId }),
  });
  return handleApiResponse(response);
};

export const claimRescueBonus = async (): Promise<{
  awarded: boolean;
  amount: number;
  claim_date_cet: string;
}> => {
  const response = await fetch('/api/tokens/rescue', { method: 'POST' });
  return handleApiResponse(response);
};
