import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import type { TokenBalanceDto } from "./tokens.types";

interface Props {
  balance: TokenBalanceDto | null;
  isLoading: boolean;
}

const StatCard = ({ title, value, isLoading }: { title: string; value: number | null; isLoading: boolean }) => (
  <Card>
    <CardHeader>
      <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
    </CardHeader>
    <CardContent>
      {isLoading ? <Skeleton className="h-8 w-24" /> : <p className="text-2xl font-bold">{value ?? "N/A"}</p>}
    </CardContent>
  </Card>
);

export const TokenBalanceCard = ({ balance, isLoading }: Props) => {
  return (
    <div className="grid gap-4 md:grid-cols-3 mb-8">
      <StatCard title="Dostępne" value={balance?.available ?? null} isLoading={isLoading} />
      <StatCard title="Zablokowane" value={balance?.held ?? null} isLoading={isLoading} />
      <StatCard title="Całkowite" value={balance?.total ?? null} isLoading={isLoading} />
    </div>
  );
};
