import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email("Nieprawidłowy adres e-mail"),
  password: z.string().min(1, "Hasło jest wymagane"),
});

export const registerSchema = z.object({
  email: z.string().email("Nieprawidłowy adres e-mail"),
  password: z.string().min(8, "Hasło musi mieć co najmniej 8 znaków"),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email("Nieprawidłowy adres e-mail"),
});

export const updatePasswordSchema = z.object({
  password: z.string().min(8, "Hasło musi mieć co najmniej 8 znaków"),
});
