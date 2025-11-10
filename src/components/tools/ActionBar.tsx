import React from "react";
import type { ToolStatus } from "@/types";
import { Button } from "@/components/ui/button";

interface ActionBarProps {
	ownerId: string;
	currentUserId: string | null;
	toolStatus: ToolStatus;
	onReservationRequest: () => void;
}

export default function ActionBar({ ownerId, currentUserId, toolStatus, onReservationRequest }: ActionBarProps) {
	const isOwner = currentUserId === ownerId;

	if (isOwner) {
		return (
			<Button className="w-full" asChild>
				<a href={`/tools/${ownerId}/edit`}>Edytuj narzędzie</a>
			</Button>
		);
	}

	const isAvailable = toolStatus === "available";

	return (
		<Button onClick={onReservationRequest} disabled={!isAvailable} className="w-full">
			{isAvailable ? "Zgłoś zapytanie" : "Narzędzie niedostępne"}
		</Button>
	);
}
