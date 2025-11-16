import type { APIRoute } from 'astro';
import { jsonError, jsonOk } from '@/lib/api/responses';
import { tokensService } from '@/lib/services/tokens.service';
import { AppError } from '@/lib/services/errors.service';

export const prerender = false;

export const GET: APIRoute = async ({ locals }) => {
  const { user, supabase } = locals;

  if (!supabase) {
    return jsonError(500, 'INTERNAL_SERVER_ERROR', 'Unexpected server configuration error.');
  }

  if (!user) {
    return jsonError(401, 'UNAUTHORIZED', 'Authentication required.');
  }

  try {
    const bonusState = await tokensService.getBonusState(supabase, user.id);
    return jsonOk(bonusState);
  } catch (error) {
    if (error instanceof AppError) {
      return jsonError(error.status, error.code, error.message);
    }

    console.error('Failed to fetch bonus state:', error);
    return jsonError(500, 'INTERNAL_SERVER_ERROR', 'Internal Server Error');
  }
};

