import React from "react";
import type { ReservationViewModel } from "./reservations.types";
import type { ReservationStatus } from "@/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import ReservationStepper from "./ReservationStepper";
import ActionButtons from "./ActionButtons";
import ContactDetails from "./ContactDetails";

interface ReservationCardProps {
  reservation: ReservationViewModel;
  userRole: "owner" | "borrower";
  onTransition: (
    id: string,
    status: ReservationStatus,
    payload?: any
  ) => void;
  onCancel: (id: string, reason: string) => void;
  onReject: (id: string, reason: string) => void;
}

const ReservationCard: React.FC<ReservationCardProps> = ({
  reservation,
  userRole,
  onTransition,
  onCancel,
  onReject,
}) => {
  const { tool, counterparty, status } = reservation;
  const toolName = tool?.name || "Nazwa narzędzia niedostępna";
  const toolImageUrl = tool?.main_image_url || null;
  const showContactDetails = ['borrower_confirmed', 'picked_up', 'returned'].includes(status);

  return (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-start">
          <div>
            <CardTitle>{toolName}</CardTitle>
            <CardDescription>
              {userRole === "owner" ? `Rezerwacja od: ${counterparty.username}` : `Właściciel: ${counterparty.username}`}
            </CardDescription>
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
        {showContactDetails ? (
            <ContactDetails reservationId={reservation.id} />
        ) : (
            <div className="text-sm text-gray-500">
                Utworzono: {new Date(reservation.created_at).toLocaleDateString()}
            </div>
        )}
        <ActionButtons
          reservation={reservation}
          userRole={userRole}
          onTransition={onTransition}
          onCancel={onCancel}
          onReject={onReject}
        />
      </CardFooter>
    </Card>
  );
};

export default ReservationCard;
