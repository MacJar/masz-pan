import React, { useState } from "react";
import type { ReservationViewModel } from "./reservations.types";
import type { ReservationAction } from "./reservations.types";
import type { ReservationStatus } from "@/types";
import { Button } from "@/components/ui/button";
import ActionConfirmationDialog from "./ActionConfirmationDialog";
import { Check, ArrowRight, ThumbsUp, ThumbsDown, Ban, MoveUpRight, MoveDownLeft } from "lucide-react";

interface ActionButtonsProps {
  reservation: ReservationViewModel;
  userRole: "owner" | "borrower";
  onTransition: (id: string, status: ReservationStatus, payload?: { price_tokens?: number }) => void;
  onCancel: (id: string, reason: string) => void;
  onReject: (id: string, reason: string) => void;
}

const getActionDetails = (
  action: ReservationAction
): {
  label: string;
  Icon: React.ElementType;
  variant: "default" | "destructive" | "outline" | "secondary" | "ghost" | "link" | null | undefined;
  nextStatus?: ReservationStatus;
  dialogTitle: string;
  dialogDescription: string;
  requiresReason?: boolean;
} => {
  switch (action.type) {
    case "accept":
      return {
        label: "Akceptuj",
        Icon: ThumbsUp,
        variant: "default",
        nextStatus: "owner_accepted",
        dialogTitle: "Akceptacja rezerwacji",
        dialogDescription: "Aby zaakceptować, podaj proponowaną cenę w żetonach za cały okres wypożyczenia.",
      };
    case "reject":
      return {
        label: "Odrzuć",
        Icon: ThumbsDown,
        variant: "destructive",
        nextStatus: "rejected",
        dialogTitle: "Odrzucenie rezerwacji",
        dialogDescription: "Czy na pewno chcesz odrzucić tę prośbę o rezerwację?",
        requiresReason: true,
      };
    case "confirm":
      return {
        label: "Potwierdź",
        Icon: Check,
        variant: "default",
        nextStatus: "borrower_confirmed",
        dialogTitle: "Potwierdzenie warunków",
        dialogDescription:
          "Potwierdzasz rezerwację na uzgodnionych warunkach. Spowoduje to zablokowanie żetonów na Twoim koncie.",
      };
    case "markAsPickedUp":
      return {
        label: "Wydano",
        Icon: MoveUpRight,
        variant: "secondary",
        nextStatus: "picked_up",
        dialogTitle: "Potwierdzenie wydania",
        dialogDescription: "Potwierdzasz, że narzędzie zostało odebrane przez pożyczającego.",
      };
    case "markAsReturned":
      return {
        label: "Zwrócono",
        Icon: MoveDownLeft,
        variant: "secondary",
        nextStatus: "returned",
        dialogTitle: "Potwierdzenie zwrotu",
        dialogDescription:
          "Potwierdzasz, że narzędzie zostało zwrócone. Transakcja zostanie zakończona, a żetony przelane.",
      };
    case "cancel":
      return {
        label: "Anuluj",
        Icon: Ban,
        variant: "destructive",
        nextStatus: "cancelled",
        dialogTitle: "Anulowanie rezerwacji",
        dialogDescription: "Czy na pewno chcesz anulować tę rezerwację?",
        requiresReason: true,
      };
    default:
      return {
        label: "Akcja",
        Icon: ArrowRight,
        variant: "outline",
        dialogTitle: "Potwierdzenie akcji",
        dialogDescription: "Czy na pewno chcesz wykonać tę akcję?",
      };
  }
};

const ActionButtons: React.FC<ActionButtonsProps> = ({ reservation, onTransition, onCancel, onReject }) => {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [selectedAction, setSelectedAction] = useState<ReservationAction | null>(null);

  const handleActionClick = (action: ReservationAction) => {
    setSelectedAction(action);
    setDialogOpen(true);
  };

  const handleConfirm = (payload?: { price_tokens?: number; reason?: string }) => {
    if (!selectedAction) return;

    const details = getActionDetails(selectedAction);

    if (selectedAction.type === "cancel") {
      onCancel(reservation.id, payload?.reason || "Brak powodu");
    } else if (selectedAction.type === "reject") {
      onReject(reservation.id, payload?.reason || "Brak powodu");
    } else if (details.nextStatus) {
      onTransition(reservation.id, details.nextStatus, payload);
    }

    setDialogOpen(false);
    setSelectedAction(null);
  };

  if (reservation.availableActions.length === 0) {
    return null; // No actions available for the current state and user
  }

  const selectedActionDetails = selectedAction ? getActionDetails(selectedAction) : null;

  return (
    <div className="flex gap-2">
      {reservation.availableActions.map((action) => {
        const details = getActionDetails(action);
        return (
          <Button key={action.type} variant={details.variant} size="sm" onClick={() => handleActionClick(action)}>
            <details.Icon className="mr-2 h-4 w-4" />
            {details.label}
          </Button>
        );
      })}
      {selectedAction && selectedActionDetails && (
        <ActionConfirmationDialog
          isOpen={dialogOpen}
          onClose={() => setDialogOpen(false)}
          onConfirm={handleConfirm}
          action={selectedAction}
          title={selectedActionDetails.dialogTitle}
          description={selectedActionDetails.dialogDescription}
          requiresReason={selectedActionDetails.requiresReason}
        />
      )}
    </div>
  );
};

export default ActionButtons;
