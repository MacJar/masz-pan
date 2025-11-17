import React, { useState } from "react";
import type { ToolWithImagesDTO } from "@/types";
import { useOwnerProfile } from "@/components/hooks/useOwnerProfile";
import { toast } from "sonner";

import ImageGallery from "./ImageGallery";
import ToolInfo from "./ToolInfo";
import OwnerBadge from "./OwnerBadge";
import ActionBar from "./ActionBar";
import { createReservation } from "../../lib/api/reservations";

interface ToolDetailsViewProps {
  initialToolData: ToolWithImagesDTO;
  currentUserId: string | null;
}

export default function ToolDetailsView({ initialToolData, currentUserId }: ToolDetailsViewProps) {
  const { owner, isLoading: isOwnerLoading, error: ownerError } = useOwnerProfile(initialToolData.owner_id);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleReservationRequest = async () => {
    setIsSubmitting(true);
    setError(null);
    try {
      await createReservation(initialToolData.id, initialToolData.owner_id);
      toast.success("Zapytanie o rezerwację zostało wysłane!");
      window.location.href = "/profile?tab=reservations";
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "Wystąpił nieznany błąd";
      setError(errorMessage);
      toast.error(`Błąd: ${errorMessage}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
      <div className="lg:col-span-2">
        <ImageGallery images={initialToolData.images} toolName={initialToolData.name} />
      </div>
      <div className="space-y-6 lg:col-span-1">
        <ToolInfo
          name={initialToolData.name}
          description={initialToolData.description}
          status={initialToolData.status}
          suggestedPrice={initialToolData.suggested_price_tokens}
        />
        <OwnerBadge owner={owner} isLoading={isOwnerLoading} error={ownerError} />
        <ActionBar
          ownerId={initialToolData.owner_id}
          currentUserId={currentUserId}
          toolStatus={initialToolData.status}
          isSubmitting={isSubmitting}
          onReservationRequest={handleReservationRequest}
        />
        {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
      </div>
    </div>
  );
}
