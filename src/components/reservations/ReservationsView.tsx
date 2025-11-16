import React from "react";
import { useReservationsManager } from "./useReservationsManager";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import ReservationList from "./ReservationList";
import { Toaster } from "@/components/ui/sonner";

const ReservationsView = () => {
  const { state, setActiveTab, transitionState, cancelReservation, rejectReservation, rateReservation } =
    useReservationsManager();

  const handleTabChange = (value: string) => {
    setActiveTab(value as "borrower" | "owner");
  };

  if (state.error) {
    return <div className="text-red-500 text-center">Wystąpił błąd: {state.error.message}</div>;
  }

  return (
    <>
      <Tabs defaultValue="borrower" className="w-full" onValueChange={handleTabChange}>
        <TabsList className="grid w-full grid-cols-2 h-[72px]">
          <TabsTrigger value="borrower" className="text-lg h-[72px]">
            Pożyczam
          </TabsTrigger>
          <TabsTrigger value="owner" className="text-lg h-[72px]">
            Użyczam
          </TabsTrigger>
        </TabsList>
        <TabsContent value="borrower">
          <ReservationList
            reservations={state.reservations.borrower}
            isLoading={state.isLoading && state.activeTab === "borrower"}
            userRole="borrower"
            onTransition={transitionState}
            onCancel={cancelReservation}
            onReject={rejectReservation}
            onRate={rateReservation}
          />
        </TabsContent>
        <TabsContent value="owner">
          <ReservationList
            reservations={state.reservations.owner}
            isLoading={state.isLoading && state.activeTab === "owner"}
            userRole="owner"
            onTransition={transitionState}
            onCancel={cancelReservation}
            onReject={rejectReservation}
            onRate={rateReservation}
          />
        </TabsContent>
      </Tabs>
      <Toaster />
    </>
  );
};

export default ReservationsView;
