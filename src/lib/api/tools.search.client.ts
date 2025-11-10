import type { ToolSearchItemDTO, ToolSearchPageDTO, ApiErrorDTO } from "../../types.ts";

export interface FetchToolsParams {
  q: string;
  limit?: number;
  cursor?: string | null;
  signal?: AbortSignal;
}

export interface ToolSearchItemVM {
  id: string;
  name: string;
  distanceMeters: number;
  distanceText: string;
}

export interface ToolSearchPageVM {
  items: ToolSearchItemVM[];
  next_cursor: string | null;
}

const numberPl = new Intl.NumberFormat("pl-PL", { minimumFractionDigits: 1, maximumFractionDigits: 1 });

export function formatDistance(distanceMeters: number): string {
  if (!Number.isFinite(distanceMeters) || distanceMeters < 0) {
    return "—";
  }
  if (distanceMeters < 1000) {
    return `${Math.round(distanceMeters)} m`;
  }
  const km = distanceMeters / 1000;
  return `${numberPl.format(km)} km`;
}

export function mapItemToVM(dto: ToolSearchItemDTO): ToolSearchItemVM {
  const distanceMeters = dto.distance_m;
  return {
    id: dto.id,
    name: dto.name,
    distanceMeters,
    distanceText: formatDistance(distanceMeters),
  };
}

export function mapPageToVM(page: ToolSearchPageDTO): ToolSearchPageVM {
  return {
    items: page.items.map(mapItemToVM),
    next_cursor: page.next_cursor,
  };
}

/**
 * Fetch raw DTO page from backend.
 * Throws ApiErrorDTO on non-2xx responses.
 */
export async function fetchTools(params: FetchToolsParams): Promise<ToolSearchPageDTO> {
  const search = new URLSearchParams();
  search.set("q", params.q.trim());
  if (params.limit && Number.isFinite(params.limit)) {
    search.set("limit", String(params.limit));
  }
  if (params.cursor) {
    search.set("cursor", params.cursor);
  }

  const res = await fetch(`/api/tools/search?${search.toString()}`, {
    method: "GET",
    headers: { accept: "application/json" },
    signal: params.signal,
  });

  const text = await res.text();
  const isJson = res.headers.get("content-type")?.includes("application/json");
  const parsed = isJson && text ? (JSON.parse(text) as unknown) : null;

  if (!res.ok) {
    const err = (parsed as ApiErrorDTO | null)?.error ?? { code: "internal_error", message: "Unexpected error." };
    throw { error: err } satisfies ApiErrorDTO;
  }

  return (parsed ?? { items: [], next_cursor: null }) as ToolSearchPageDTO;
}
