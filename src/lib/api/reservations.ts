import type { Reservation } from "../../types";

export async function createReservation(toolId: string, ownerId: string): Promise<Reservation> {
  const response = await fetch(`/api/reservations`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ tool_id: toolId, owner_id: ownerId }),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.message || "Failed to create reservation");
  }

  return response.json();
}
