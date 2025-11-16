import type { ToolStatus } from "@/types";

type BadgeVariant = "default" | "secondary" | "destructive" | "outline";

export interface ToolStatusMeta {
  label: string;
  badgeVariant: BadgeVariant;
}

const TOOL_STATUS_META: Record<ToolStatus, ToolStatusMeta> = {
  draft: { label: "Szkic", badgeVariant: "secondary" },
  active: { label: "Aktywne", badgeVariant: "default" },
  inactive: { label: "Nieaktywne", badgeVariant: "outline" },
  archived: { label: "Zarchiwizowane", badgeVariant: "destructive" },
};

const FALLBACK_STATUS_META: ToolStatusMeta = {
  label: "Nieznany status",
  badgeVariant: "outline",
};

export function getToolStatusMeta(status: ToolStatus): ToolStatusMeta {
  return TOOL_STATUS_META[status] ?? FALLBACK_STATUS_META;
}
