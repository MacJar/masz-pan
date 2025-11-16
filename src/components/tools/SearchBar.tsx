import React, { useCallback } from "react";
import type { JSX } from "react";
import { Button } from "@/components/ui/button";

export interface SearchBarProps {
  value: string;
  onChange(value: string): void;
  onSubmit(): void;
  isPending: boolean;
}

export default function SearchBar(props: SearchBarProps): JSX.Element {
  const { value, onChange, onSubmit, isPending } = props;

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Enter") {
        e.preventDefault();
        onSubmit();
      }
    },
    [onSubmit]
  );

  const tooLong = value.length > 128;
  const tooShort = value.trim().length < 1;
  const invalid = tooShort || tooLong;

  return (
    <div className="flex items-center gap-2">
      <input
        aria-label="Szukaj narzędzi"
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Wpisz nazwę narzędzia…"
        className="flex-1 rounded-md border-2 border-primary/30 px-3 py-2 text-2xl outline-none focus:ring-2 focus:ring-primary focus:border-primary/60"
      />
      <Button
        variant="default"
        disabled={invalid || isPending}
        onClick={onSubmit}
        className="text-2xl h-[48px] px-6"
        style={{ minHeight: "48px" }}
      >
        {isPending ? "Szukam…" : "Szukaj"}
      </Button>
      {tooLong && (
        <p className="ml-2 text-xs text-destructive" role="status">
          Maksymalnie 128 znaków.
        </p>
      )}
    </div>
  );
}
