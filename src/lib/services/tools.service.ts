import type { SupabaseClient } from "../../db/supabase.client.ts";
import type {
  CreateToolImageCommand,
  CreateToolImageUploadUrlCommand,
  ToolDTO,
  ToolImageDTO,
  ToolImageUploadUrlDto,
  ToolSearchPageDTO,
  ToolStatus,
  ToolWithImagesDTO,
  UpdateToolCommand,
} from "../../types.ts";
import { fetchProfileById } from "./profile.service.ts";
import {
  ConflictError,
  ForbiddenError,
  InternalServerError,
  NotFoundError,
  SupabaseQueryError,
  ToolHasActiveReservationsError,
  UnprocessableEntityError,
} from "./errors.service.ts";
import mime from "mime";

export interface GetToolsByOwnerParams {
  ownerId: string;
  status?: ToolStatus | "all";
  limit: number;
  cursor?: string;
}

export interface ToolSearchParams {
  q: string;
  limit: number;
  cursor?: string | null;
}

export interface DeleteToolImageCommand {
  toolId: string;
  imageId: string;
  userId: string;
}

export class ValidationError extends Error {
  readonly details?: unknown;
  constructor(message: string, details?: unknown) {
    super(message);
    this.name = "ValidationError";
    this.details = details;
  }
}

export class MissingLocationError extends Error {
  constructor() {
    super("Profile location is required");
    this.name = "MissingLocationError";
  }
}

export class ToolsService {
  private supabase: SupabaseClient;

  constructor(supabase: SupabaseClient) {
    this.supabase = supabase;
  }

  async getToolsByOwner(params: GetToolsByOwnerParams) {
    let query = this.supabase
      .from("tools")
      .select(
        `
        *,
        main_image_url:tool_images(storage_key)
      `
      )
      .eq("owner_id", params.ownerId)
      .eq("tool_images.position", 0)
      .limit(params.limit);

    if (params.status && params.status !== "all") {
      query = query.eq("status", params.status);
    }

    if (params.cursor) {
      // For cursor-based pagination, we need a stable sort order.
      // We'll sort by `created_at` descending as a primary key.
      // The cursor will be the `created_at` value of the last item.
      query = query.lt("created_at", params.cursor);
    }

    query = query.order("created_at", { ascending: false });

    const { data, error } = await query;

    if (error) {
      throw new SupabaseQueryError("Failed to fetch tools by owner", error.code, error);
    }

    const { data: storagePublicUrlData } = this.supabase.storage.from("tool_images").getPublicUrl("dummy_path");
    const storageUrl = storagePublicUrlData.publicUrl.replace("/dummy_path", "");

    const items = data.map((tool) => ({
      ...tool,
      main_image_url: tool.main_image_url[0] ? `${storageUrl}/${tool.main_image_url[0].storage_key}` : null,
    }));

    const next_cursor = items.length === params.limit ? items[items.length - 1].created_at : null;

    return {
      items: items as ToolDTO[],
      next_cursor,
    };
  }

  async createSignedImageUploadUrl(
    toolId: string,
    userId: string,
    command: CreateToolImageUploadUrlCommand
  ): Promise<ToolImageUploadUrlDto> {
    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("owner_id")
      .eq("id", toolId)
      .single();

    if (toolError) {
      if (toolError.code === "PGRST116") {
        throw new NotFoundError("Tool not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool by ID.", toolError.code, toolError);
    }

    if (tool.owner_id !== userId) {
      throw new ForbiddenError("You do not have permission to upload images for this tool.");
    }

    const extension = mime.getExtension(command.content_type);
    if (!extension) {
      throw new ValidationError("Invalid content type provided.");
    }

    const fileId = crypto.randomUUID();
    const storageKey = `tools/${toolId}/${fileId}.${extension}`;

    const { data, error } = await this.supabase.storage.from("tool_images").createSignedUploadUrl(storageKey, 60, {
      upsert: true,
    });

    if (error) {
      throw new InternalServerError(`Failed to create signed upload URL: ${error.message}`);
    }

    return {
      upload_url: data.signedUrl,
      storage_key: storageKey,
      headers: {
        "x-upsert": "true",
      },
    };
  }

  async getToolImagesForTool(toolId: string, currentUserId?: string) {
    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("status, owner_id")
      .eq("id", toolId)
      .single();

    if (toolError) {
      if (toolError.code === "PGRST116") {
        throw new NotFoundError("Tool not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool by ID.", toolError.code, toolError);
    }

    if (tool.status !== "active" && tool.owner_id !== currentUserId) {
      throw new ForbiddenError("You do not have permission to view images for this tool.");
    }

    const { data: images, error: imagesError } = await this.supabase
      .from("tool_images")
      .select("*")
      .eq("tool_id", toolId)
      .order("position", { ascending: true });

    if (imagesError) {
      throw new SupabaseQueryError("Failed to fetch tool images.", imagesError.code, imagesError);
    }

    return images;
  }

  async findToolWithImagesById(toolId: string): Promise<ToolWithImagesDTO | null> {
    const { data, error } = await this.supabase
      .from("tools")
      .select("*, images:tool_images(*)")
      .eq("id", toolId)
      .order("position", { foreignTable: "tool_images", ascending: true })
      .single();

    if (error) {
      // Supabase returns PGRST116 when no rows are found, which is not a "real" error.
      // We'll treat it as a "not found" case and return null.
      if (error.code === "PGRST116") {
        return null;
      }
      throw new SupabaseQueryError("Failed to fetch tool by ID.", error.code, error);
    }

    return data as ToolWithImagesDTO | null;
  }

  async updateTool(toolId: string, ownerId: string, command: UpdateToolCommand) {
    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("owner_id")
      .eq("id", toolId)
      .single();

    if (toolError) {
      if (toolError.code === "PGRST116") {
        throw new NotFoundError("Tool not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool.", toolError.code, toolError);
    }

    if (tool.owner_id !== ownerId) {
      throw new ForbiddenError("You are not the owner of this tool.");
    }

    const { data: updatedTool, error: updateError } = await this.supabase
      .from("tools")
      .update(command)
      .eq("id", toolId)
      .select()
      .single();

    if (updateError) {
      throw new SupabaseQueryError("Failed to update tool.", updateError.code, updateError);
    }

    return updatedTool;
  }

  async createToolImage(toolId: string, ownerId: string, data: CreateToolImageCommand): Promise<ToolImageDTO> {
    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("owner_id")
      .eq("id", toolId)
      .single();

    if (toolError) {
      if (toolError.code === "PGRST116") {
        throw new NotFoundError("Tool not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool.", toolError.code, toolError);
    }

    if (tool.owner_id !== ownerId) {
      throw new ForbiddenError("You are not the owner of this tool.");
    }

    const { data: newImage, error: insertError } = await this.supabase
      .from("tool_images")
      .insert({
        tool_id: toolId,
        storage_key: data.storage_key,
        position: data.position,
      })
      .select()
      .single();

    if (insertError) {
      if (insertError.code === "23505") {
        throw new ConflictError("An image already exists at this position.");
      }
      throw new SupabaseQueryError("Failed to create tool image.", insertError.code, insertError);
    }

    return newImage;
  }

  async deleteToolImage(command: DeleteToolImageCommand): Promise<void> {
    const { data: image, error: imageError } = await this.supabase
      .from("tool_images")
      .select(
        `
        tool_id,
        storage_key,
        tool:tools (
          owner_id
        )
      `
      )
      .eq("id", command.imageId)
      .single();

    if (imageError) {
      if (imageError.code === "PGRST116") {
        throw new NotFoundError("Image not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool image for deletion.", imageError.code, imageError);
    }

    if (!image.tool) {
      // This should not happen due to foreign key constraints, but it's a good safeguard.
      throw new NotFoundError("Image is not associated with any tool.");
    }

    if (image.tool.owner_id !== command.userId) {
      throw new ForbiddenError("You are not the owner of this tool.");
    }

    if (image.tool_id !== command.toolId) {
      // The image does not belong to the tool specified in the URL.
      // This is a form of authorization check.
      throw new NotFoundError("Image does not belong to the specified tool.");
    }

    const { error: storageError } = await this.supabase.storage.from("tool_images").remove([image.storage_key]);

    if (storageError) {
      // It's better to log this error but not fail the whole operation,
      // as the database record is the source of truth.
      // We can have a cleanup job for orphaned storage files later.
      console.error("Failed to delete image from storage:", storageError);
    }

    const { error: dbError } = await this.supabase.from("tool_images").delete().eq("id", command.imageId);

    if (dbError) {
      throw new SupabaseQueryError("Failed to delete tool image from database.", dbError.code, dbError);
    }
  }

  async createDraftTool(ownerId: string) {
    const { data: newTool, error: insertError } = await this.supabase
      .from("tools")
      .insert({
        owner_id: ownerId,
        status: "draft",
        name: "", // Provide an empty string to satisfy the NOT NULL constraint
        suggested_price_tokens: 1, // Provide a default value
      })
      .select()
      .single();

    if (insertError) {
      throw new SupabaseQueryError("Failed to create draft tool.", insertError.code, insertError);
    }

    return newTool;
  }

  async searchActiveToolsNearProfile(userId: string, params: ToolSearchParams): Promise<ToolSearchPageDTO> {
    // 1) Ensure profile has geocoded location
    const profile = await fetchProfileById(this.supabase, userId);
    if (!profile || !profile.location_geog) {
      throw new MissingLocationError();
    }

    // 2) Decode cursor (if any)
    const after = this.decodeCursor(params.cursor);

    // 3) Query DB via RPC
    const { data, error } = await this.supabase.rpc("search_tools", {
      p_user_id: userId,
      p_q: params.q,
      p_limit: params.limit,
      p_after: after,
    });
    if (error) {
      throw new SupabaseQueryError("Failed to search tools.", error.code, error);
    }

    const rows = (Array.isArray(data) ? data : []) as RpcRow[];
    const items = rows.map((r) => ({
      id: r.id,
      name: r.name,
      distance_m: r.distance_m,
    }));

    // 4) Build next cursor
    const last = rows.length > 0 ? rows[rows.length - 1] : null;
    const next_cursor = last?.cursor_key ? this.encodeCursor(last.cursor_key) : null;

    return { items, next_cursor };
  }

  private decodeCursor(encoded?: string | null): { lastDistance: number; lastId: string } | null {
    if (!encoded || typeof encoded !== "string") {
      return null;
    }
    try {
      const json = Buffer.from(encoded, "base64").toString("utf8");
      const parsed = JSON.parse(json) as { lastDistance: unknown; lastId: unknown };
      if (
        typeof parsed !== "object" ||
        parsed === null ||
        typeof parsed.lastDistance !== "number" ||
        typeof parsed.lastId !== "string"
      ) {
        throw new Error("Invalid cursor shape");
      }
      return { lastDistance: parsed.lastDistance, lastId: parsed.lastId };
    } catch (err) {
      throw new ValidationError("Invalid cursor", { issue: "invalid_cursor" });
    }
  }

  private encodeCursor(obj: { lastDistance: number; lastId: string }): string {
    const json = JSON.stringify(obj);
    return Buffer.from(json, "utf8").toString("base64");
  }

  async publishTool(toolId: string, userId: string): Promise<ToolWithImagesDTO> {
    const { data, error } = await this.supabase.rpc("publish_tool", {
      tool_id_to_publish: toolId,
    });

    if (error) {
      switch (error.code) {
        case "PGRST001":
          throw new NotFoundError("Tool not found");
        case "PGRST002":
          throw new ForbiddenError("You are not the owner of this tool.");
        case "PGRST003":
          throw new UnprocessableEntityError("Tool is not a draft and cannot be published.");
        case "PGRST004":
          throw new ConflictError("Tool must have at least one image to be published.");
        default:
          throw new SupabaseQueryError("Failed to publish tool.", error.code, error);
      }
    }

    if (!data || data.length === 0) {
      throw new InternalServerError("Publishing the tool failed to return the updated tool.");
    }

    const tool = data[0];

    return {
      id: tool.id,
      owner_id: tool.owner_id,
      name: tool.name,
      description: tool.description,
      suggested_price_tokens: tool.suggested_price_tokens,
      status: tool.status,
      created_at: tool.created_at,
      updated_at: tool.updated_at,
      archived_at: tool.archived_at,
      images: tool.images ? (tool.images as ToolImageDTO[]) : [],
    };
  }

  async archiveTool(toolId: string, userId: string): Promise<{ archivedAt: Date }> {
    const { data: tool, error: toolError } = await this.supabase
      .from("tools")
      .select("status, owner_id, archived_at")
      .eq("id", toolId)
      .single();

    if (toolError) {
      if (toolError.code === "PGRST116") {
        throw new NotFoundError("Tool not found");
      }
      throw new SupabaseQueryError("Failed to fetch tool for archiving.", toolError.code, toolError);
    }

    if (tool.owner_id !== userId) {
      throw new ForbiddenError("You are not the owner of this tool.");
    }

    if (tool.status === "archived" && tool.archived_at) {
      return { archivedAt: new Date(tool.archived_at) };
    }

    const { data: rpcData, error: rpcError } = await this.supabase
      .rpc("archive_tool", {
        p_tool_id: toolId,
        p_user_id: userId,
      })
      .single();

    if (rpcError) {
      throw new SupabaseQueryError("Failed to execute archive_tool RPC.", rpcError.code, rpcError);
    }

    if (!rpcData.success) {
      switch (rpcData.code) {
        case "FORBIDDEN":
          throw new ForbiddenError(rpcData.message);
        case "TOOL_HAS_ACTIVE_RESERVATIONS":
          throw new ToolHasActiveReservationsError(rpcData.message);
        default:
          throw new InternalServerError(`RPC call failed with code: ${rpcData.code} and message: ${rpcData.message}`);
      }
    }

    if (!rpcData.archived_at) {
      throw new InternalServerError("RPC call succeeded but did not return an archived_at date.");
    }

    return { archivedAt: new Date(rpcData.archived_at) };
  }
}

interface RpcRow {
  id: string;
  name: string;
  distance_m: number;
  cursor_key?: { lastDistance: number; lastId: string } | null;
}
