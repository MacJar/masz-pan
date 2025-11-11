import type { SupabaseClient } from "../../db/supabase.client.ts";
import type { CreateToolImageDto } from "../pages/api/tools/[id]/images.ts";
import type { ToolImageDTO, ToolSearchPageDTO, ToolWithImagesDTO } from "../../types.ts";
import { fetchProfileById } from "./profile.service.ts";
import { ConflictError, ForbiddenError, NotFoundError, SupabaseQueryError } from "./errors.service.ts";

export interface ToolSearchParams {
  q: string;
  limit: number;
  cursor?: string | null;
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

export class NotFoundError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "NotFoundError";
  }
}

export class ForbiddenError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ForbiddenError";
  }
}

export class ToolsService {
  private supabase: SupabaseClient;

  constructor(supabase: SupabaseClient) {
    this.supabase = supabase;
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
      .select("*, tool_images(*)")
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

  async createToolImage(toolId: string, ownerId: string, data: CreateToolImageDto): Promise<ToolImageDTO> {
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
}

interface RpcRow {
  id: string;
  name: string;
  distance_m: number;
  cursor_key?: { lastDistance: number; lastId: string } | null;
}
