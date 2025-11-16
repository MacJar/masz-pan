import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../db/supabase.client';
import { updatePasswordSchema } from '../../../lib/schemas/auth.schema';
import { ZodError } from 'zod';

export const prerender = false;

export const POST: APIRoute = async ({ request, cookies }) => {
  try {
    const body = await request.json();
    const { password } = updatePasswordSchema.parse(body);

    const supabase = createSupabaseServerClient({ cookies, headers: request.headers });

    const { data: { session }, } = await supabase.auth.getSession();

    // The user must be logged in to update their password.
    // The password reset link from email provides a temporary session.
    if (!session) {
      return new Response(JSON.stringify({ error: 'Brak autoryzacji. Sesja mogła wygasnąć.' }), {
        status: 401,
      });
    }

    const { error } = await supabase.auth.updateUser({ password });

    if (error) {
      console.error('Update password error:', error.message);
      return new Response(JSON.stringify({ error: 'Nie udało się zaktualizować hasła.' }), {
        status: 500,
      });
    }
    
    return new Response(JSON.stringify({ message: 'Hasło zostało pomyślnie zaktualizowane.' }), {
      status: 200,
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return new Response(JSON.stringify({ error: error.errors.map((e) => e.message).join(', ') }), {
        status: 400,
      });
    }
    console.error('Update password endpoint error:', error);
    return new Response(JSON.stringify({ error: 'Wystąpił wewnętrzny błąd serwera.' }), {
      status: 500,
    });
  }
};
