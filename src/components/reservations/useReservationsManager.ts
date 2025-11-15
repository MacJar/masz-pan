import { useState, useEffect, useCallback } from "react";
import type { ReservationViewModel, ReservationAction } from "./reservations.types";
import {
  cancelReservationRequest,
  getMyReservations,
  transitionReservation,
} from "@/lib/api/reservations.client";
import { getProfile } from "@/lib/api/profile.client";
import type { ProfileDTO, ReservationWithToolDTO, ReservationStatus } from "@/types";
import { toast } from "sonner";

// Mock current user ID, in a real app this would come from an auth context
const MOCK_USER_ID = "00000000-0000-0000-0000-000000000001"; // Replace with actual user ID mechanism

type ReservationsState = {
  borrower: ReservationViewModel[];
  owner: ReservationViewModel[];
};

const mapDtoToViewModel = (dto: ReservationWithToolDTO, currentUserId: string): ReservationViewModel => {
  const currentUserRole = dto.owner_id === currentUserId ? "owner" : "borrower";
  const counterparty = currentUserRole === "owner" ? dto.borrower : dto.owner;

  const availableActions: ReservationAction[] = [];

  if (currentUserRole === "owner") {
    switch (dto.status) {
      case "requested":
        availableActions.push({ type: "accept", requiresPrice: true }, { type: "reject" });
        break;
      case "owner_accepted":
        availableActions.push({ type: "cancel" });
        break;
      // borrower can confirm pickup once owner confirms
      case "borrower_confirmed":
        availableActions.push({ type: "markAsPickedUp" });
        break;
    }
  } else {
    // Current user is borrower
    switch (dto.status) {
      case "requested":
        availableActions.push({ type: "cancel" });
        break;
      case "owner_accepted":
        availableActions.push({ type: "confirm" }, { type: "cancel" });
        break;
      case "picked_up":
        availableActions.push({ type: "markAsReturned" });
        break;
    }
  }

  return {
    ...dto,
    tool: dto.tool ?? { id: dto.tool_id, name: "N/A" },
    currentUserRole,
    counterparty: counterparty ?? { id: "unknown", username: "Nieznany" },
    availableActions,
  };
};

export const useReservationsManager = () => {
  const [activeTab, setActiveTab] = useState<"borrower" | "owner">("borrower");
  const [reservations, setReservations] = useState<ReservationsState>({ borrower: [], owner: [] });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [currentUser, setCurrentUser] = useState<ProfileDTO | null>(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const userProfile = await getProfile();
        setCurrentUser(userProfile);
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch user profile"));
      }
    };
    fetchUser();
  }, []);

  const fetchReservations = useCallback(async (role: "borrower" | "owner", userId: string) => {
    if (!userId) return;

    setIsLoading(true);
    setError(null);
    try {
      const data = await getMyReservations({ role });
      const viewModels = data.map(dto => mapDtoToViewModel(dto, userId));
      setReservations(prev => ({ ...prev, [role]: viewModels }));
    } catch (err) {
      setError(err instanceof Error ? err : new Error("An unknown error occurred"));
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (currentUser?.id) {
      fetchReservations(activeTab, currentUser.id);
    }
  }, [activeTab, currentUser?.id, fetchReservations]);

  const updateReservationState = (
    reservationId: string,
    role: "owner" | "borrower",
    updatedData: Partial<ReservationViewModel>
  ) => {
    setReservations(prev => {
      const list = prev[role];
      const index = list.findIndex(r => r.id === reservationId);
      if (index === -1) return prev;

      const newList = [...list];
      newList[index] = { ...newList[index], ...updatedData };
      return { ...prev, [role]: newList };
    });
  };

  const transitionState = async (
    id: string,
    newStatus: ReservationStatus,
    payload?: { price_tokens?: number }
  ) => {
    const role = activeTab;
    const originalReservations = [...reservations[role]];
    const reservationToUpdate = originalReservations.find(r => r.id === id);
    if (!reservationToUpdate || !currentUser) return;

    // Optimistic update
    const updatedViewModel = mapDtoToViewModel(
      { ...reservationToUpdate, status: newStatus, agreed_price_tokens: payload?.price_tokens ?? reservationToUpdate.agreed_price_tokens },
      currentUser.id
    );
    updateReservationState(id, role, updatedViewModel);

    try {
      toast.info(`Przetwarzanie akcji...`);
      await transitionReservation(id, newStatus, payload);
      toast.success(`Status rezerwacji został pomyślnie zmieniony na "${getStepLabel(newStatus)}".`);
    } catch (error) {
      // Revert state
      setReservations(prev => ({ ...prev, [role]: originalReservations }));
      toast.error((error as Error).message || "Wystąpił błąd podczas zmiany statusu.");
    }
  };

  const cancelReservation = async (id: string, reason: string) => {
    const role = activeTab;
    const originalReservations = [...reservations[role]];
    const reservationToUpdate = originalReservations.find(r => r.id === id);
    if (!reservationToUpdate || !currentUser) return;

    const newStatus = "cancelled";

    // Optimistic update
    const updatedViewModel = mapDtoToViewModel({ ...reservationToUpdate, status: newStatus }, currentUser.id);
    updateReservationState(id, role, updatedViewModel);

    try {
      toast.info(`Anulowanie rezerwacji...`);
      await cancelReservationRequest(id, reason);
      toast.success("Rezerwacja została pomyślnie anulowana.");
    } catch (error) {
       // Revert state
       setReservations(prev => ({ ...prev, [role]: originalReservations }));
       toast.error((error as Error).message || "Wystąpił błąd podczas anulowania rezerwacji.");
    }
  };

  const rejectReservation = async (id: string, reason: string) => {
    // This is essentially a state transition to "rejected"
    // In a real API, this might be a separate endpoint, but here we model it as a transition
    // The reason might be passed in the payload if the API supports it.
    await transitionState(id, 'rejected');
  }

  return {
    state: {
      activeTab,
      reservations,
      isLoading,
      error,
    },
    setActiveTab,
    transitionState,
    cancelReservation,
    rejectReservation,
  };
};

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
