import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { getToolImagePublicUrl } from './utils';

describe('utils.ts', () => {
  describe('getToolImagePublicUrl', () => {
    const originalWindow = global.window;

    beforeEach(() => {
      // Reset mocks
      vi.resetModules();
      global.window = { ...originalWindow } as Window & typeof globalThis;
    });

    afterEach(() => {
      // Restore original values
      global.window = originalWindow;
      vi.unstubAllEnvs();
    });

    it('should return URL using window.__SUPABASE_URL when available', () => {
      const mockSupabaseUrl = 'https://test.supabase.co';
      // @ts-expect-error - adding custom property
      global.window.__SUPABASE_URL = mockSupabaseUrl;
      vi.stubEnv('SUPABASE_URL', undefined);

      const result = getToolImagePublicUrl('test-image.jpg');
      
      expect(result).toBe(`${mockSupabaseUrl}/storage/v1/object/public/tool_images/test-image.jpg`);
    });

    it('should return URL using import.meta.env.SUPABASE_URL when window.__SUPABASE_URL is not available', () => {
      const mockSupabaseUrl = 'https://env.supabase.co';
      // @ts-expect-error - clearing window property
      delete global.window.__SUPABASE_URL;
      vi.stubEnv('SUPABASE_URL', mockSupabaseUrl);

      const result = getToolImagePublicUrl('test-image.jpg');
      
      expect(result).toBe(`${mockSupabaseUrl}/storage/v1/object/public/tool_images/test-image.jpg`);
    });

    it('should normalize base URL by removing trailing slash', () => {
      const mockSupabaseUrl = 'https://test.supabase.co/';
      vi.stubEnv('SUPABASE_URL', mockSupabaseUrl);
      // @ts-expect-error - clearing window property
      delete global.window.__SUPABASE_URL;

      const result = getToolImagePublicUrl('test-image.jpg');
      
      expect(result).toBe('https://test.supabase.co/storage/v1/object/public/tool_images/test-image.jpg');
      // Should not have double slashes in the path (after https://)
      expect(result).not.toMatch(/https:\/\/[^/]+\/\//);
    });

    it('should normalize storage key by removing leading slash', () => {
      const mockSupabaseUrl = 'https://test.supabase.co';
      vi.stubEnv('SUPABASE_URL', mockSupabaseUrl);
      // @ts-expect-error - clearing window property
      delete global.window.__SUPABASE_URL;

      const result = getToolImagePublicUrl('/test-image.jpg');
      
      expect(result).toBe(`${mockSupabaseUrl}/storage/v1/object/public/tool_images/test-image.jpg`);
    });

    it('should return empty string and warn when Supabase URL is not defined', () => {
      const consoleSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
      // @ts-expect-error - clearing window property
      delete global.window.__SUPABASE_URL;
      vi.stubEnv('SUPABASE_URL', undefined);

      const result = getToolImagePublicUrl('test-image.jpg');
      
      expect(result).toBe('');
      expect(consoleSpy).toHaveBeenCalledWith(
        'Supabase URL is not defined, returning empty string for tool image URL.'
      );
      
      consoleSpy.mockRestore();
    });

    it('should handle storage keys without leading slash', () => {
      const mockSupabaseUrl = 'https://test.supabase.co';
      vi.stubEnv('SUPABASE_URL', mockSupabaseUrl);
      // @ts-expect-error - clearing window property
      delete global.window.__SUPABASE_URL;

      const result = getToolImagePublicUrl('folder/test-image.jpg');
      
      expect(result).toBe(`${mockSupabaseUrl}/storage/v1/object/public/tool_images/folder/test-image.jpg`);
    });
  });
});

