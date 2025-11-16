import type { ReservationWithToolDTO } from "@/types";
import type { ReservationStatus } from "@/types";
import { toast } from "sonner";
import type { ReservationContactsDto } from "@/types";

export const getMyReservations = async (params: {
  role: "owner" | "borrower";
}): Promise<ReservationWithToolDTO[]> => {
  const queryParams = new URLSearchParams({ role: params.role });
  const response = await fetch(`/api/reservations?${queryParams.toString()}`);
  if (!response.ok) {
    throw new Error("Failed to fetch reservations");
  }
  const data = await response.json();
  return data.items;
};

export const transitionReservation = async (
  id: string,
  new_status: ReservationStatus,
  payload?: { price_tokens?: number; cancelled_reason?: string }
) => {
  const response = await fetch(`/api/reservations/${id}/transition`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ new_status, ...payload }),
  });
  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error?.message || "Failed to transition reservation state");
  }
  return response.json();
};

export const cancelReservationRequest = async (id: string, cancelled_reason: string) => {
  const response = await fetch(`/api/reservations/${id}/cancel`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ cancelled_reason }),
  });
  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error?.message || "Failed to cancel reservation");
  }
  return response.json();
};

export const getContactsForReservation = async (id: string): Promise<ReservationContactsDto> => {
  try {
    const response = await fetch(`/api/reservations/${id}/contacts`);
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error?.message || "Failed to get contacts for reservation");
    }
    return response.json();
  } catch (error) {
    toast.error("Nie udało się pobrać danych kontaktowych.");
    throw error;
  }
};

export const rateReservationRequest = async (id: string, rating: number) => {
  const response = await fetch(`/api/reservations/${id}/rate`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ rating }),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error || "Nie udało się zapisać oceny");
  }
};