import { describe, it, expect } from 'vitest';
import {
  loginSchema,
  registerSchema,
  forgotPasswordSchema,
  updatePasswordSchema,
} from './auth.schema';

describe('auth.schema.ts', () => {
  describe('loginSchema', () => {
    it('should successfully validate correct data', () => {
      const result = loginSchema.safeParse({
        email: 'test@example.com',
        password: 'password123',
      });
      expect(result.success).toBe(true);
    });

    it('should fail validation for an invalid email', () => {
      const result = loginSchema.safeParse({
        email: 'not-an-email',
        password: 'password123',
      });
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].message).toBe('Nieprawidłowy adres e-mail');
      }
    });

    it('should fail validation for an empty password', () => {
      const result = loginSchema.safeParse({
        email: 'test@example.com',
        password: '',
      });
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].message).toBe('Hasło jest wymagane');
      }
    });
  });

  describe('registerSchema', () => {
    it('should successfully validate correct data', () => {
      const result = registerSchema.safeParse({
        email: 'newuser@example.com',
        password: 'strongpassword',
      });
      expect(result.success).toBe(true);
    });

    it('should fail validation for an invalid email', () => {
        const result = registerSchema.safeParse({
            email: 'invalid-email',
            password: 'strongpassword',
        });
        expect(result.success).toBe(false);
        if (!result.success) {
            expect(result.error.issues[0].message).toBe('Nieprawidłowy adres e-mail');
        }
    });

    it('should fail validation for a password that is too short', () => {
      const result = registerSchema.safeParse({
        email: 'newuser@example.com',
        password: 'short',
      });
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].message).toBe('Hasło musi mieć co najmniej 8 znaków');
      }
    });
  });

    describe('forgotPasswordSchema', () => {
        it('should successfully validate a correct email', () => {
            const result = forgotPasswordSchema.safeParse({
                email: 'user@example.com',
            });
            expect(result.success).toBe(true);
        });

        it('should fail validation for an invalid email', () => {
            const result = forgotPasswordSchema.safeParse({
                email: 'not-a-valid-email',
            });
            expect(result.success).toBe(false);
            if (!result.success) {
                expect(result.error.issues[0].message).toBe('Nieprawidłowy adres e-mail');
            }
        });
    });

    describe('updatePasswordSchema', () => {
        it('should successfully validate a password with sufficient length', () => {
            const result = updatePasswordSchema.safeParse({
                password: 'newStrongPassword123',
            });
            expect(result.success).toBe(true);
        });

        it('should fail validation for a password that is too short', () => {
            const result = updatePasswordSchema.safeParse({
                password: 'short',
            });
            expect(result.success).toBe(false);
            if (!result.success) {
                expect(result.error.issues[0].message).toBe('Hasło musi mieć co najmniej 8 znaków');
            }
        });
    });
});

