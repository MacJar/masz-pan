import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../db/supabase.client';
import { forgotPasswordSchema } from '../../../lib/schemas/auth.schema';
import { ZodError } from 'zod';

export const prerender = false;

export const POST: APIRoute = async ({ request, cookies, url }) => {
  try {
    const body = await request.json();
    const { email } = forgotPasswordSchema.parse(body);

    const supabase = createSupabaseServerClient({ cookies, headers: request.headers });
    
    const correctedOrigin = url.origin.replace('127.0.0.1', 'localhost');
    
    // The redirect URL should point to the callback route.
    // The callback will exchange the code for a session and redirect to the 'next' URL.
    const redirectTo = new URL('/api/auth/callback?next=/auth/update-password', correctedOrigin).toString();

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo,
    });

    // For security reasons, do not reveal whether an email is registered.
    if (error) {
      console.error('Error sending password reset email:', error.message);
    }

    return new Response(
      JSON.stringify({
        message: 'Jeśli konto o podanym adresie e-mail istnieje, wysłano na nie instrukcję resetowania hasła.',
      }),
      { status: 200 },
    );
  } catch (error) {
    if (error instanceof ZodError) {
      return new Response(JSON.stringify({ error: 'Nieprawidłowy adres e-mail.' }), {
        status: 400,
      });
    }
    console.error('Forgot password endpoint error:', error);
    return new Response(JSON.stringify({ error: 'Wystąpił wewnętrzny błąd serwera.' }), {
      status: 500,
    });
  }
};
