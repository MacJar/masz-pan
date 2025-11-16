import React from "react";
import type { ReservationViewModel } from "./reservations.types";
import SkeletonList from "./SkeletonList";
import EmptyState from "./EmptyState";
import ReservationCard from "./ReservationCard";
import type { ReservationStatus } from "@/types";

interface ReservationListProps {
  reservations: ReservationViewModel[];
  isLoading: boolean;
  userRole: "owner" | "borrower";
  onTransition: (id: string, status: ReservationStatus, payload?: any) => void;
  onCancel: (id: string, reason: string) => void;
  onReject: (id: string, reason: string) => void;
  onRate: (id: string, rating: number) => void;
}

const ReservationList: React.FC<ReservationListProps> = ({
  reservations,
  isLoading,
  userRole,
  onTransition,
  onCancel,
  onReject,
  onRate,
}) => {
  if (isLoading) {
    return <SkeletonList />;
  }

  if (reservations.length === 0) {
    return <EmptyState />;
  }

  return (
    <div className="space-y-4">
      {reservations.map((reservation) => (
        <ReservationCard
          key={reservation.id}
          reservation={reservation}
          userRole={userRole}
          onTransition={onTransition}
          onCancel={onCancel}
          onReject={onReject}
          onRate={onRate}
        />
      ))}
    </div>
  );
};

export default ReservationList;
