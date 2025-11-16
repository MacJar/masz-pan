import { z } from "zod";
import type { APIRoute } from "astro";
import { _Error, _Response } from "@/lib/api/responses";
import { getSupabase } from "@/db/supabase";
import { getToolImagePublicUrl } from "@/lib/utils";

export const prerender = false;

const ReorderImagesCommandSchema = z.object({
  imageIds: z.array(z.string().uuid()),
});

export const PATCH: APIRoute = async ({ params, request, locals }) => {
  const supabase = getSupabase(locals);
  const { id: toolId } = params;

  if (!toolId) {
    return _Error(400, "Tool ID is required");
  }

  const session = await locals.auth.getSession();
  if (!session) {
    return _Error(401, "Unauthorized");
  }

  const validation = ReorderImagesCommandSchema.safeParse(await request.json());
  if (!validation.success) {
    return _Error(400, "Invalid request body", validation.error);
  }

  const { imageIds } = validation.data;

  // Verify ownership
  const { data: tool, error: toolError } = await supabase
    .from("tools")
    .select("owner_id")
    .eq("id", toolId)
    .single();

  if (toolError || !tool) {
    return _Error(404, "Tool not found");
  }

  if (tool.owner_id !== session.user.id) {
    return _Error(403, "Forbidden");
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
    return _Error(500, "Failed to reorder images");
  }

  const { data: updatedImages, error: updatedImagesError } = await supabase
    .from("tool_images")
    .select("*")
    .eq("tool_id", toolId)
    .order("position", { ascending: true });

  if (updatedImagesError) {
    return _Error(500, "Failed to fetch updated images");
  }

  const imagesWithUrl = (updatedImages ?? []).map((image) => ({
    ...image,
    public_url: getToolImagePublicUrl(image.storage_key),
  }));

  return _Response(imagesWithUrl, 200);
};
