import type { SupabaseClient } from "../../db/supabase.client.ts";
import type { ToolSearchPageDTO } from "../../types.ts";
import { fetchProfileById, SupabaseQueryError } from "./profile.service.ts";

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

type RpcRow = {
	id: string;
	name: string;
	distance_m: number;
	cursor_key?: { lastDistance: number; lastId: string } | null;
};

export async function searchActiveToolsNearProfile(
	supabase: SupabaseClient,
	userId: string,
	params: ToolSearchParams
): Promise<ToolSearchPageDTO> {
	// 1) Ensure profile has geocoded location
	const profile = await fetchProfileById(supabase, userId);
	if (!profile || !profile.location_geog) {
		throw new MissingLocationError();
	}

	// 2) Decode cursor (if any)
	const after = decodeCursor(params.cursor);

	// 3) Query DB via RPC
	const { data, error } = await supabase.rpc("search_tools", {
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
	const next_cursor = last?.cursor_key ? encodeCursor(last.cursor_key) : null;

	return { items, next_cursor };
}

function decodeCursor(encoded?: string | null): { lastDistance: number; lastId: string } | null {
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

function encodeCursor(obj: { lastDistance: number; lastId: string }): string {
	const json = JSON.stringify(obj);
	return Buffer.from(json, "utf8").toString("base64");
}


