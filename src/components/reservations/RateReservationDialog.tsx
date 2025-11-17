import React, { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import StarRating from "./StarRating";

interface RateReservationDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (rating: number) => void;
  toolName: string;
  counterpartyName: string;
}

const RateReservationDialog: React.FC<RateReservationDialogProps> = ({
  isOpen,
  onClose,
  onSubmit,
  toolName,
  counterpartyName,
}) => {
  const [rating, setRating] = useState(0);

  const handleSubmit = () => {
    if (rating > 0) {
      onSubmit(rating);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Oceń transakcję</DialogTitle>
          <DialogDescription>
            Twoja opinia pomoże innym użytkownikom. Oceń współpracę z <strong>{counterpartyName}</strong> w związku z
            narzędziem <strong>{toolName}</strong>.
          </DialogDescription>
        </DialogHeader>
        <div className="py-4 flex justify-center">
          <StarRating rating={rating} setRating={setRating} />
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Anuluj
          </Button>
          <Button onClick={handleSubmit} disabled={rating === 0}>
            Wyślij ocenę
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export default RateReservationDialog;
