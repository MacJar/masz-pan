import type { SupabaseClient } from '@/db/supabase.client';
import type { LedgerEntriesResponseDto, LedgerEntryDto, TokenBalanceDto } from '@/types';
import { GetLedgerEntriesQuerySchema } from '../schemas/token.schema';
import { z } from 'zod';
import {
  AlreadyAwardedError,
  ConflictError,
  LimitReachedError,
  SupabaseQueryError,
  UnprocessableEntityError,
} from './errors.service';

type GetLedgerEntriesQuery = z.infer<typeof GetLedgerEntriesQuerySchema>;

const POSTGREST_UNIQUE_VIOLATION_CODE = '23505';
const POSTGREST_RAISE_EXCEPTION_CODE = 'P0001';

class TokensService {
  async getUserBalance(supabase: SupabaseClient, userId: string): Promise<TokenBalanceDto> {
    const { data, error } = await supabase
      .from('balances')
      .select('total, held, available')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') {
      // PGRST116: "The result contains 0 rows"
      throw new SupabaseQueryError('Could not fetch token balance.', error.code, error);
    }

    if (!data) {
      return {
        user_id: userId,
        total: 0,
        held: 0,
        available: 0,
      };
    }

    return {
      user_id: userId,
      total: data.total ?? 0,
      held: data.held ?? 0,
      available: data.available ?? 0,
    };
  }

  async getLedgerEntries(
    supabase: SupabaseClient,
    userId: string,
    query: GetLedgerEntriesQuery,
  ): Promise<LedgerEntriesResponseDto> {
    let queryBuilder = supabase
      .from('token_ledger')
      .select('id, kind, amount, details, created_at')
      .eq('user_id', userId);

    if (query.kind) {
      queryBuilder = queryBuilder.eq('kind', query.kind);
    }

    if (query.cursor) {
      try {
        const decodedCursor = Buffer.from(query.cursor, 'base64').toString('ascii');
        const [createdAt, id] = decodedCursor.split(',');
        if (createdAt && id) {
          queryBuilder = queryBuilder.lt('created_at', createdAt).or(`created_at.eq.${createdAt},id.lt.${id}`);
        }
      } catch (e) {
        // Invalid cursor, ignore it
        console.warn('Invalid cursor provided:', query.cursor);
      }
    }

    queryBuilder = queryBuilder.order('created_at', { ascending: false }).order('id', { ascending: false });

    const { data, error } = await queryBuilder.limit(query.limit + 1);

    if (error) {
      throw new SupabaseQueryError('Could not fetch token ledger.', error.code, error);
    }

    const hasNextPage = data.length > query.limit;
    const items = hasNextPage ? data.slice(0, query.limit) : data;

    const nextCursor = hasNextPage
      ? Buffer.from(`${items[items.length - 1].created_at},${items[items.length - 1].id}`).toString('base64')
      : null;

    const mappedItems: LedgerEntryDto[] = items.map(item => ({
      id: item.id,
      kind: item.kind,
      amount: item.amount,
      details: item.details as Record<string, any>,
      createdAt: item.created_at,
    }));

    return {
      items: mappedItems,
      nextCursor,
    };
  }

  async awardSignupBonus(supabase: SupabaseClient, userId: string): Promise<void> {
    const { error } = await supabase.rpc('award_signup_bonus', {
      p_user_id: userId,
    });

    if (error) {
      if (error.code === POSTGREST_UNIQUE_VIOLATION_CODE) {
        throw new AlreadyAwardedError('Signup bonus already awarded.');
      }
      throw new SupabaseQueryError('Could not award signup bonus.', error.code, error);
    }
  }

  async awardListingBonus(supabase: SupabaseClient, userId: string, toolId: string): Promise<void> {
    const { error } = await supabase.rpc('award_listing_bonus', {
      p_user_id: userId,
      p_tool_id: toolId,
    });

    if (error) {
      if (error.code === POSTGREST_UNIQUE_VIOLATION_CODE) {
        throw new AlreadyAwardedError('Bonus for this tool has already been awarded.');
      }
      if (error.code === POSTGREST_RAISE_EXCEPTION_CODE && error.message.includes('listing bonus limit reached')) {
        throw new LimitReachedError('You have reached the limit of 3 listing bonuses.');
      }
      throw new SupabaseQueryError('Could not award listing bonus.', error.code, error);
    }
  }

  /**
   * Claims a daily rescue token for a user if their available balance is zero.
   * This operation is restricted to once per calendar day (CET).
   * @param supabase The Supabase client instance.
   * @param userId The ID of the user claiming the token.
   * @throws {UnprocessableEntityError} If the user's balance is not zero.
   * @throws {ConflictError} If the user has already claimed a token today.
   * @throws {SupabaseQueryError} For other database-related errors.
   */
  async claimRescueToken(supabase: SupabaseClient, userId: string): Promise<void> {
    const { error } = await supabase.rpc('claim_rescue_token', { p_user_id: userId });

    if (error) {
      if (error.code === POSTGREST_UNIQUE_VIOLATION_CODE) {
        throw new ConflictError('Rescue token already claimed today.');
      }
      if (
        error.code === POSTGREST_RAISE_EXCEPTION_CODE &&
        error.message.includes('rescue token only when available = 0')
      ) {
        throw new UnprocessableEntityError('Rescue token is only available when your balance is zero.');
      }
      throw new SupabaseQueryError('Failed to claim rescue token', error.code, error);
    }
  }
}

export const tokensService = new TokensService();
