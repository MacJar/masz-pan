import type { ReservationWithToolDTO } from "@/types";

// Definiuje możliwe akcje do wykonania na rezerwacji
export type ReservationAction =
  | { type: "accept"; requiresPrice: true }
  | { type: "confirm" }
  | { type: "markAsPickedUp" }
  | { type: "markAsReturned" }
  | { type: "cancel" }
  | { type: "reject" };

// Rozszerza DTO o dane potrzebne do logiki UI
export interface ReservationViewModel extends ReservationWithToolDTO {
  // Rola bieżącego użytkownika w kontekście tej rezerwacji
  currentUserRole: "owner" | "borrower";

  // Dane drugiej strony transakcji
  counterparty: {
    id: string;
    username: string | null;
  };

  // Lista akcji, które bieżący użytkownik może wykonać w danym stanie
  availableActions: ReservationAction[];
}
