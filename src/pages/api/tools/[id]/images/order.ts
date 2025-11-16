import { z } from "zod";
import type { APIRoute } from "astro";
import { jsonError, jsonOk } from "@/lib/api/responses";
import { getToolImagePublicUrl } from "@/lib/utils";

export const prerender = false;

const ReorderImagesCommandSchema = z.object({
  imageIds: z.array(z.string().uuid()),
});

export const PATCH: APIRoute = async ({ params, request, locals }) => {
  const { supabase } = locals;
  if (!supabase) {
    return jsonError(500, "INTERNAL_SERVER_ERROR", "Supabase client is not available");
  }
  const { id: toolId } = params;

  if (!toolId) {
    return jsonError(400, "INVALID_TOOL_ID", "Tool ID is required");
  }

  const session = await locals.auth.getSession();
  if (!session) {
    return jsonError(401, "UNAUTHORIZED", "Unauthorized");
  }

  const validation = ReorderImagesCommandSchema.safeParse(await request.json());
  if (!validation.success) {
    return jsonError(400, "INVALID_REQUEST", "Invalid request body", validation.error);
  }

  const { imageIds } = validation.data;

  // Verify ownership
  const { data: tool, error: toolError } = await supabase
    .from("tools")
    .select("owner_id")
    .eq("id", toolId)
    .single();

  if (toolError || !tool) {
    return jsonError(404, "NOT_FOUND", "Tool not found");
  }

  if (tool.owner_id !== session.user.id) {
    return jsonError(403, "FORBIDDEN", "Forbidden");
  }

  try {
    const updates = imageIds.map((id, index) =>
      supabase.from("tool_images").update({ position: index }).eq("id", id).eq("tool_id", toolId)
    );

    const results = await Promise.all(updates);
    const firstError = results.find(r => r.error);

    if (firstError) {
      throw firstError.error;
    }

  } catch (error) {
    console.error("Error reordering images:", error);
    return jsonError(500, "REORDER_FAILED", "Failed to reorder images");
  }

  const { data: updatedImages, error: updatedImagesError } = await supabase
    .from("tool_images")
    .select("*")
    .eq("tool_id", toolId)
    .order("position", { ascending: true });

  if (updatedImagesError) {
    return jsonError(500, "FETCH_FAILED", "Failed to fetch updated images");
  }

  const imagesWithUrl = (updatedImages ?? []).map((image) => ({
    ...image,
    public_url: getToolImagePublicUrl(image.storage_key),
  }));

  return jsonOk(imagesWithUrl);
};
