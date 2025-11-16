import { z } from 'zod';

export const CreateRatingSchema = z.object({
  reservation_id: z.string().uuid({ message: 'Invalid reservation ID format.' }),
  stars: z
    .number({ invalid_type_error: 'Stars must be a number.' })
    .int()
    .min(1, 'Rating must be at least 1.')
    .max(5, 'Rating must be at most 5.'),
});

export type CreateRatingDto = z.infer<typeof CreateRatingSchema>;


