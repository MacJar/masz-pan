import { AlertCircle, ArrowDownCircle, ArrowUpCircle, Award, Clock, HelpCircle } from 'lucide-react';
import type { TokenLedgerEntryViewModel, LedgerKind } from './tokens.types';

const kindIconMap: Record<LedgerKind, React.ElementType> = {
  credit: ArrowUpCircle,
  debit: ArrowDownCircle,
  hold: Clock,
  release: ArrowUpCircle,
  transfer: ArrowDownCircle, // Assuming transfer out
  award: Award,
};

const kindColorMap: Record<LedgerKind, string> = {
  credit: 'text-green-500',
  debit: 'text-red-500',
  hold: 'text-yellow-500',
  release: 'text-blue-500',
  transfer: 'text-purple-500',
  award: 'text-indigo-500',
};

interface Props {
  entry: TokenLedgerEntryViewModel;
}

export const LedgerEntryItem = ({ entry }: Props) => {
  const Icon = kindIconMap[entry.kind] || HelpCircle;
  const color = kindColorMap[entry.kind] || 'text-gray-500';

  return (
    <div className="flex items-center justify-between p-4 border-b">
      <div className="flex items-center gap-4">
        <Icon className={`w-6 h-6 ${color}`} />
        <div>
          <p className="font-semibold">{entry.description}</p>
          <p className="text-sm text-muted-foreground">{entry.formattedDate}</p>
        </div>
      </div>
      <div className={`font-bold text-lg ${color}`}>
        {entry.kind === 'debit' || entry.kind === 'hold' ? '-' : '+'}
        {entry.amount}
      </div>
    </div>
  );
};

