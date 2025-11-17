import React, { useState } from "react";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import type { ReservationAction } from "./reservations.types";

interface ActionConfirmationDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (payload?: { price_tokens?: number; reason?: string }) => void;
  action: ReservationAction;
  title: string;
  description: string;
  requiresReason?: boolean;
}

const ActionConfirmationDialog: React.FC<ActionConfirmationDialogProps> = ({
  isOpen,
  onClose,
  onConfirm,
  action,
  title,
  description,
  requiresReason = false,
}) => {
  const [price, setPrice] = useState<number | undefined>();
  const [reason, setReason] = useState("");
  const [error, setError] = useState("");

  const handleConfirmClick = () => {
    setError("");
    if (action.type === "accept" && action.requiresPrice) {
      if (!price || price <= 0) {
        setError("Cena musi być dodatnią liczbą całkowitą.");
        return;
      }
      onConfirm({ price_tokens: price });
    } else if (requiresReason) {
      if (!reason.trim()) {
        setError("Powód jest wymagany.");
        return;
      }
      onConfirm({ reason: reason });
    } else {
      onConfirm();
    }
    resetState();
  };

  const handleClose = () => {
    resetState();
    onClose();
  };

  const resetState = () => {
    setPrice(undefined);
    setReason("");
    setError("");
  };

  return (
    <AlertDialog open={isOpen} onOpenChange={handleClose}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>

        {action.type === "accept" && action.requiresPrice && (
          <div className="grid gap-2 py-4">
            <Label htmlFor="price">Cena w żetonach</Label>
            <Input
              id="price"
              type="number"
              value={price || ""}
              onChange={(e) => setPrice(parseInt(e.target.value, 10))}
              placeholder="np. 100"
              min="1"
            />
          </div>
        )}

        {requiresReason && (
          <div className="grid gap-2 py-4">
            <Label htmlFor="reason">Powód (opcjonalnie dla anulowania)</Label>
            <Textarea
              id="reason"
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="Podaj powód..."
            />
          </div>
        )}

        {error && <p className="text-sm text-red-500">{error}</p>}

        <AlertDialogFooter>
          <AlertDialogCancel onClick={handleClose}>Anuluj</AlertDialogCancel>
          <AlertDialogAction asChild>
            <Button onClick={handleConfirmClick}>Potwierdź</Button>
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};

export default ActionConfirmationDialog;
