import { createSupabaseServerClient } from '../db/supabase.client';
import { defineMiddleware } from 'astro:middleware';
import type { User } from '@supabase/supabase-js';

const PUBLIC_PATHS = [
  '/tools',
  '/auth/login',
  '/auth/register',
  '/auth/forgot-password',
  '/auth/update-password',
  '/api/auth/login',
  '/api/auth/register',
  '/api/auth/forgot-password',
  '/api/auth/update-password',
  '/api/auth/callback',
  '/api/auth/logout',
  '/api/profile/geocode', // Public for address search in profile form
];

export const onRequest = defineMiddleware(
  async ({ locals, cookies, url, request, redirect }, next) => {
    const isPublicPath = PUBLIC_PATHS.some((path) => url.pathname.startsWith(path));

    const isDevAuthBypass =
      import.meta.env.AUTH_BYPASS === 'true' &&
      import.meta.env.AUTH_BYPASS_USER_ID &&
      import.meta.env.DEV;

    let user: User | null = null;
    
    if (isDevAuthBypass) {
      user = {
        id: import.meta.env.AUTH_BYPASS_USER_ID,
        app_metadata: { provider: 'email', providers: ['email'] },
        user_metadata: { name: 'Dev User' },
        aud: 'authenticated',
        created_at: new Date().toISOString(),
      } as User;
    }

    const supabase = createSupabaseServerClient({
      cookies,
      headers: request.headers,
    });

    locals.supabase = supabase;

    if (!isDevAuthBypass) {
      const { data } = await supabase.auth.getUser();
      user = data.user;
    }

    if (user) {
      locals.user = {
        email: user.email,
        id: user.id,
      };
    }

    if (isPublicPath) {
      return next();
    }

    if (!user) {
      if (url.pathname.startsWith('/api/')) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { 'Content-Type': 'application/json' },
        });
      }
      return redirect('/auth/login');
    }

    const allowedPathsIncompleteProfile = ['/profile', '/api/profile', '/api/auth/logout'];
    const isAllowedPathForIncompleteProfile = allowedPathsIncompleteProfile.some((p) =>
      url.pathname.startsWith(p),
    );

    if (!isAllowedPathForIncompleteProfile) {
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('is_complete')
        .eq('id', user.id)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Middleware profile fetch error:', error.message);
      } else {
        const isProfileComplete = profile?.is_complete ?? false;
        if (!isProfileComplete) {
          return redirect('/profile');
        }
      }
    }

    return next();
  },
);
