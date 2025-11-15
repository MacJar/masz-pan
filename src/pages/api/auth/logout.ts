import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../db/supabase.client';

export const POST: APIRoute = async ({ cookies, request }) => {
  const supabase = createSupabaseServerClient({ cookies, headers: request.headers });

  const { error } = await supabase.auth.signOut();

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
    });
  }

  return new Response(null, { status: 200 });
};
