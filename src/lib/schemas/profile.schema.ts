import { z } from "zod";

export const ProfileFormSchema = z.object({
  username: z.string().trim().min(1, { message: "Nazwa użytkownika jest wymagana." }),
  location_text: z.string().nullable().optional(),
  rodo_consent: z.literal(true, {
    errorMap: () => ({ message: "Zgoda RODO jest wymagana." }),
  }),
});

export type ProfileFormValues = z.infer<typeof ProfileFormSchema>;


