import React from "react";
import type { ToolStatus } from "@/types";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

interface ActionBarProps {
	ownerId: string;
	currentUserId: string | null;
	toolStatus: ToolStatus;
	isSubmitting: boolean;
	onReservationRequest: () => void;
}

export default function ActionBar({
	ownerId,
	currentUserId,
	toolStatus,
	isSubmitting,
	onReservationRequest,
}: ActionBarProps) {
	const isOwner = currentUserId === ownerId;

	if (isOwner) {
		return (
			<Button className="w-full" asChild>
				<a href={`/tools/${ownerId}/edit`}>Edytuj narzędzie</a>
			</Button>
		);
	}

	const isAvailable = toolStatus === "active";

	return (
		<Button onClick={onReservationRequest} disabled={!isAvailable || isSubmitting} className="w-full">
			{isSubmitting ? (
				<>
					<Loader2 className="mr-2 h-4 w-4 animate-spin" />
					<span>Wysyłanie...</span>
				</>
			) : isAvailable ? (
				"Zgłoś zapytanie"
			) : (
				"Narzędzie niedostępne"
			)}
		</Button>
	);
}
