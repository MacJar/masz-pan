import React from "react";
import { Button } from "@/components/ui/button";
import type { ToolStatus } from "@/types";

interface StatusFilterProps {
  activeFilter: ToolStatus | "all";
  onFilterChange: (status: ToolStatus | "all") => void;
}

const filters: { label: string; value: ToolStatus | "all" }[] = [
  { label: "Wszystkie", value: "all" },
  { label: "Szkice", value: "draft" },
  { label: "Aktywne", value: "active" },
  { label: "Zarchiwizowane", value: "archived" },
];

const StatusFilter: React.FC<StatusFilterProps> = ({ activeFilter, onFilterChange }) => {
  return (
    <div className="flex space-x-2 mb-6">
      {filters.map((filter) => (
        <Button
          key={filter.value}
          variant={activeFilter === filter.value ? "default" : "outline"}
          onClick={() => onFilterChange(filter.value)}
          className="text-lg"
        >
          {filter.label}
        </Button>
      ))}
    </div>
  );
};

export default StatusFilter;
