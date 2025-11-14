import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import type { BonusStateViewModel, TokenBalanceDto } from './tokens.types';

interface Props {
  bonusState: BonusStateViewModel | null;
  balance: TokenBalanceDto | null;
  isLoading: boolean;
  onClaimSignup: () => void;
  onClaimListing: (toolId: string) => void;
  onClaimRescue: () => void;
}

export const BonusActions = ({
  bonusState,
  balance,
  isLoading,
  onClaimSignup,
  onClaimListing,
  onClaimRescue,
}: Props) => {
  const [selectedToolId, setSelectedToolId] = useState<string>('');

  if (isLoading) {
    return (
        <div className="grid gap-4 md:grid-cols-3">
            <Skeleton className="h-48 w-full" />
            <Skeleton className="h-48 w-full" />
            <Skeleton className="h-48 w-full" />
        </div>
    )
  }

  if (!bonusState) return null;

  const { signup, listing, rescue } = bonusState;

  const handleListingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedToolId) {
      onClaimListing(selectedToolId);
    }
  };

  const isSignupDisabled = signup.isClaimed || signup.isLoading;
  const isRescueDisabled = rescue.isClaimedToday || !rescue.isAvailable || rescue.isLoading || (balance?.available ?? 1) > 0;
  const isListingDisabled = listing.claimsUsed >= 3 || listing.eligibleTools.length === 0 || listing.isLoading;


  return (
    <div>
      <h2 className="text-xl font-bold mb-4">Dostępne bonusy</h2>
      <div className="grid gap-4 md:grid-cols-3">
        {/* Signup Bonus */}
        <Card>
          <CardHeader>
            <CardTitle>Bonus powitalny</CardTitle>
            <CardDescription>Odbierz 10 żetonów za dołączenie do platformy.</CardDescription>
          </CardHeader>
          <CardContent>
            <Button onClick={onClaimSignup} disabled={isSignupDisabled} className="w-full">
              {signup.isLoading ? 'Przetwarzanie...' : signup.isClaimed ? 'Odebrano' : 'Odbierz 10 żetonów'}
            </Button>
          </CardContent>
        </Card>

        {/* Listing Bonus */}
        <Card>
          <CardHeader>
            <CardTitle>Bonus za wystawienie</CardTitle>
            <CardDescription>Zdobądź 2 żetony za każde z pierwszych 3 wystawionych narzędzi.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleListingSubmit} className="space-y-4">
              <Select
                onValueChange={setSelectedToolId}
                value={selectedToolId}
                disabled={isListingDisabled}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Wybierz narzędzie" />
                </SelectTrigger>
                <SelectContent>
                  {listing.eligibleTools.length > 0 ? (
                    listing.eligibleTools.map((tool) => (
                      <SelectItem key={tool.id} value={tool.id}>
                        {tool.name}
                      </SelectItem>
                    ))
                  ) : (
                    <div className="p-4 text-sm text-muted-foreground">Brak kwalifikujących się narzędzi</div>
                  )}
                </SelectContent>
              </Select>
              <Button type="submit" disabled={isListingDisabled || !selectedToolId} className="w-full">
                {listing.isLoading ? 'Przetwarzanie...' : `Odbierz bonus (${3 - listing.claimsUsed} pozostało)`}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Rescue Bonus */}
        <Card>
          <CardHeader>
            <CardTitle>Bonus ratunkowy</CardTitle>
            <CardDescription>Masz puste konto? Odbierz 1 żeton, aby móc dalej działać. Dostępny raz dziennie.</CardDescription>
          </CardHeader>
          <CardContent>
            <Button onClick={onClaimRescue} disabled={isRescueDisabled} className="w-full">
                {rescue.isLoading ? 'Przetwarzanie...' : rescue.isClaimedToday ? 'Odebrano dzisiaj' : 'Odbierz 1 żeton'}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
