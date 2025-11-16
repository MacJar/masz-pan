import React from "react";
import type { ReservationStatus } from "@/types";
import { cn } from "@/lib/utils";

interface ReservationStepperProps {
  status: ReservationStatus;
}

const STEPS: ReservationStatus[] = ["requested", "owner_accepted", "borrower_confirmed", "picked_up", "returned"];

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
        <span className="text-base font-semibold">{getStepLabel(status)}</span>
      </div>
    );
  }

  const getStepColor = (index: number, currentIndex: number) => {
    if (index > currentIndex) return "oklch(0.7 0.03 180)"; // gray-400 equivalent
    // Lightness decreases evenly from 0.6 to 0.3 across 5 steps
    // First step is lighter (weaker), last step is darker (stronger)
    const lightness = 0.6 - index * 0.075; // 0.6, 0.525, 0.45, 0.375, 0.3
    return `oklch(${lightness} 0.12 180)`;
  };

  return (
    <div className="w-full">
      <div className="flex justify-between">
        {STEPS.map((step, index) => {
          const isActive = index <= currentStepIndex;
          const color = getStepColor(index, currentStepIndex);
          return (
            <div key={step} className="flex-1 text-center">
              <div className="text-base font-semibold" style={{ color }}>
                {getStepLabel(step)}
              </div>
            </div>
          );
        })}
      </div>
      <div className="relative mt-2 h-2 bg-gray-200 rounded-full overflow-hidden">
        {STEPS.map((step, index) => {
          if (index > currentStepIndex) return null;
          const color = getStepColor(index, currentStepIndex);
          const segmentWidth = 100 / STEPS.length;
          return (
            <div
              key={step}
              className="absolute top-0 h-2 rounded-full transition-all duration-500"
              style={{
                left: `${index * segmentWidth}%`,
                width: `${segmentWidth}%`,
                backgroundColor: color,
              }}
            />
          );
        })}
      </div>
    </div>
  );
};

export default ReservationStepper;
