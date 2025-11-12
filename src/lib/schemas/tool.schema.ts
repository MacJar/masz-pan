import { z } from 'zod';

export const ToolIdParamSchema = z.object({
  id: z.string().uuid({ message: 'Tool ID must be a valid UUID' }),
});
