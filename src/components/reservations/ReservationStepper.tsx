import React from "react";
import type { ReservationStatus } from "@/types";
import { cn } from "@/lib/utils";

interface ReservationStepperProps {
  status: ReservationStatus;
}

const STEPS: ReservationStatus[] = [
  "requested",
  "owner_accepted",
  "borrower_confirmed",
  "picked_up",
  "returned",
];

const CANCELLED_STEPS: ReservationStatus[] = ["cancelled", "rejected"];

const getStepLabel = (status: ReservationStatus) => {
  const labels: Record<ReservationStatus, string> = {
    requested: "Zgłoszono",
    owner_accepted: "Zaakceptowano",
    borrower_confirmed: "Potwierdzono",
    picked_up: "Wydano",
    returned: "Zwrócono",
    cancelled: "Anulowano",
    rejected: "Odrzucono",
  };
  return labels[status];
};

const ReservationStepper: React.FC<ReservationStepperProps> = ({ status }) => {
  const isCancelled = CANCELLED_STEPS.includes(status);
  const currentStepIndex = STEPS.indexOf(status);

  if (isCancelled) {
    return (
      <div className="flex items-center justify-center p-4 bg-red-100 text-red-700 rounded-md">
        <span className="font-semibold">{getStepLabel(status)}</span>
      </div>
    );
  }

  return (
    <div className="w-full">
      <div className="flex justify-between">
        {STEPS.map((step, index) => (
          <div key={step} className="flex-1 text-center">
            <div
              className={cn(
                "text-xs font-semibold",
                index <= currentStepIndex ? "text-primary" : "text-gray-400"
              )}
            >
              {getStepLabel(step)}
            </div>
          </div>
        ))}
      </div>
      <div className="relative mt-2 h-2 bg-gray-200 rounded-full">
        <div
          className="absolute top-0 left-0 h-2 bg-primary rounded-full transition-all duration-500"
          style={{ width: `${(currentStepIndex / (STEPS.length - 1)) * 100}%` }}
        />
      </div>
    </div>
  );
};

export default ReservationStepper;
