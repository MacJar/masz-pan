import React, { useState } from "react";
import { getContactsForReservation } from "@/lib/api/reservations.client";
import type { ReservationContactsDto } from "@/types";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Terminal, Mail } from "lucide-react";

interface ContactDetailsProps {
  reservationId: string;
}

const ContactDetails: React.FC<ContactDetailsProps> = ({ reservationId }) => {
  const [contacts, setContacts] = useState<ReservationContactsDto | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleFetchContacts = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await getContactsForReservation(reservationId);
      setContacts(data);
    } catch (err) {
      setError("Nie udało się pobrać danych kontaktowych.");
    } finally {
      setIsLoading(false);
    }
  };

  if (contacts) {
    return (
      <Alert>
        <Mail className="h-4 w-4" />
        <AlertTitle>Dane kontaktowe</AlertTitle>
        <AlertDescription>
            <p>Właściciel: {contacts.owner_email}</p>
            <p>Pożyczający: {contacts.borrower_email}</p>
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={handleFetchContacts}
      disabled={isLoading}
    >
      {isLoading ? "Ładowanie..." : "Pokaż kontakt"}
    </Button>
  );
};

export default ContactDetails;
