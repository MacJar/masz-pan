import type { APIRoute } from 'astro';
import { z } from 'zod';
import { toolsService } from '../../../../../lib/services/tools.service';
import { handleServiceCall } from '../../../../../lib/services/errors.service';
import { badRequest, forbidden, notFound, unauthorized } from '../../../../../lib/api/responses';

export const prerender = false;

export const DeleteToolImageParamsSchema = z.object({
  id: z.string().uuid({ message: 'Invalid tool ID format' }),
  imageId: z.string().uuid({ message: 'Invalid image ID format' }),
});

export const DELETE: APIRoute = async ({ params, locals }) => {
  const { user } = locals;

  if (!user) {
    return unauthorized();
  }

  const result = DeleteToolImageParamsSchema.safeParse(params);

  if (!result.success) {
    return badRequest('Invalid request params', result.error.flatten());
  }

  const { id: toolId, imageId } = result.data;

  return await handleServiceCall(
    () =>
      toolsService.deleteToolImage({
        toolId,
        imageId,
        userId: user.id,
      }),
    () => new Response(JSON.stringify({ deleted: true }), { status: 200 })
  );
};
