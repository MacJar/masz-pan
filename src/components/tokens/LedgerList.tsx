import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { LedgerEntryItem } from "./LedgerEntryItem";
import type { TokenLedgerEntryViewModel, LedgerKind } from "./tokens.types";
import { Alert, AlertDescription, AlertTitle } from "../ui/alert";
import { AlertCircle } from "lucide-react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";

interface Props {
  entries: TokenLedgerEntryViewModel[];
  hasMore: boolean;
  isLoading: boolean;
  onFilterChange: (kind: LedgerKind | null) => void;
  onLoadMore: () => void;
}

const ledgerKindOptions: { value: LedgerKind; label: string }[] = [
  { value: "credit", label: "Wpływy" },
  { value: "debit", label: "Obciążenia" },
  { value: "hold", label: "Blokady" },
  { value: "release", label: "Zwolnienia" },
  { value: "transfer", label: "Transfery" },
  { value: "award", label: "Bonusy" },
];

const SkeletonLoader = () => (
  <div className="space-y-4">
    {[...Array(5)].map((_, i) => (
      <div key={i} className="flex items-center justify-between p-4 border-b">
        <div className="flex items-center gap-4">
          <Skeleton className="w-6 h-6 rounded-full" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-48" />
            <Skeleton className="h-3 w-32" />
          </div>
        </div>
        <Skeleton className="h-6 w-16" />
      </div>
    ))}
  </div>
);

export const LedgerList = ({ entries, hasMore, isLoading, onFilterChange, onLoadMore }: Props) => {
  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Historia transakcji</h2>
        <Select onValueChange={(value) => onFilterChange(value as LedgerKind | null)}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filtruj po typie" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Wszystkie</SelectItem>
            {ledgerKindOptions.map((option) => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
      <div className="border rounded-md">
        {isLoading && entries.length === 0 ? (
          <SkeletonLoader />
        ) : entries.length > 0 ? (
          entries.map((entry) => <LedgerEntryItem key={entry.id} entry={entry} />)
        ) : (
          <Alert>
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Brak transakcji</AlertTitle>
            <AlertDescription>Nie znaleziono żadnych wpisów w historii.</AlertDescription>
          </Alert>
        )}
      </div>
      {hasMore && (
        <div className="text-center mt-4">
          <Button onClick={onLoadMore} disabled={isLoading}>
            {isLoading ? "Ładowanie..." : "Załaduj więcej"}
          </Button>
        </div>
      )}
    </div>
  );
};
