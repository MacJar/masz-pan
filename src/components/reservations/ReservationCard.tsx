import React, { useState } from "react";
import type { ReservationViewModel } from "./reservations.types";
import type { ReservationStatus } from "@/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import ReservationStepper from "./ReservationStepper";
import ActionButtons from "./ActionButtons";
import ContactDetails from "./ContactDetails";
import RateReservationDialog from "./RateReservationDialog";
import { Button } from "../ui/button";
import { Star } from "lucide-react";
import StarRating from "./StarRating";

interface ReservationCardProps {
  reservation: ReservationViewModel;
  userRole: "owner" | "borrower";
  onTransition: (id: string, status: ReservationStatus, payload?: any) => void;
  onCancel: (id: string, reason: string) => void;
  onReject: (id: string, reason: string) => void;
  onRate: (id: string, rating: number) => void;
}

const ReservationCard: React.FC<ReservationCardProps> = ({
  reservation,
  userRole,
  onTransition,
  onCancel,
  onReject,
  onRate,
}) => {
  const [isRatingDialogOpen, setRatingDialogOpen] = useState(false);
  const { tool, counterparty, status, currentUserRating } = reservation;
  const toolName = tool?.name || "Nazwa narzędzia niedostępna";
  const toolImageUrl = tool?.main_image_url || null;
  const showContactDetails = ["borrower_confirmed", "picked_up", "returned"].includes(status);

  const handleRateSubmit = (rating: number) => {
    onRate(reservation.id, rating);
    setRatingDialogOpen(false);
  };

  return (
    <>
      <Card>
        <CardHeader>
          <div className="flex justify-between items-start">
            <div>
              <CardTitle>{toolName}</CardTitle>
              <br />
              <CardDescription>
                {userRole === "owner"
                  ? `Rezerwacja od: ${counterparty.username}`
                  : `Właściciel: ${counterparty.username}`}
              </CardDescription>
              <br />
            </div>
            <div className="w-16 h-16 rounded-md overflow-hidden bg-gray-200 flex items-center justify-center">
              {toolImageUrl ? (
                <img
                  src={toolImageUrl}
                  alt={`Miniatura narzędzia ${toolName}`}
                  className="w-full h-full object-cover"
                  loading="lazy"
                />
              ) : (
                <span className="text-[10px] uppercase tracking-wide text-gray-500">Brak zdjęcia</span>
              )}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <ReservationStepper status={reservation.status} />
        </CardContent>
        <CardFooter className="flex justify-between items-center">
          {status === "returned" ? (
            <div className="text-sm text-muted-foreground">
              {currentUserRating ? (
                <div className="flex items-center gap-2">
                  <span>Twoja ocena:</span>
                  <StarRating rating={currentUserRating} setRating={() => {}} disabled />
                </div>
              ) : (
                "Transakcja zakończona. Dziękujemy!"
              )}
            </div>
          ) : showContactDetails ? (
            <ContactDetails reservationId={reservation.id} />
          ) : (
            <div className="text-sm text-gray-500">
              Utworzono: {new Date(reservation.created_at).toLocaleDateString()}
            </div>
          )}

          {status === "returned" && currentUserRating === null ? (
            <Button size="sm" onClick={() => setRatingDialogOpen(true)}>
              <Star className="mr-2 h-4 w-4" /> Wystaw ocenę
            </Button>
          ) : (
            <ActionButtons
              reservation={reservation}
              userRole={userRole}
              onTransition={onTransition}
              onCancel={onCancel}
              onReject={onReject}
            />
          )}
        </CardFooter>
      </Card>
      <RateReservationDialog
        isOpen={isRatingDialogOpen}
        onClose={() => setRatingDialogOpen(false)}
        onSubmit={handleRateSubmit}
        toolName={toolName}
        counterpartyName={counterparty.username || "użytkownik"}
      />
    </>
  );
};

export default ReservationCard;
