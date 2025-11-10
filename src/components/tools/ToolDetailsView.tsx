import React from "react";
import type { ToolWithImagesDTO } from "@/types";
import { useOwnerProfile } from "@/components/hooks/useOwnerProfile";

import ImageGallery from "./ImageGallery";
import ToolInfo from "./ToolInfo";
import OwnerBadge from "./OwnerBadge";
import ActionBar from "./ActionBar";

interface ToolDetailsViewProps {
	initialToolData: ToolWithImagesDTO;
	currentUserId: string | null;
}

export default function ToolDetailsView({ initialToolData, currentUserId }: ToolDetailsViewProps) {
	const { owner, isLoading: isOwnerLoading, error: ownerError } = useOwnerProfile(initialToolData.owner_id);

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
					onReservationRequest={() => {
						/* TODO: Implement reservation request logic */
					}}
				/>
			</div>
		</div>
	);
}
