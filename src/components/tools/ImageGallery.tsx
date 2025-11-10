import type { ToolImageDTO } from "@/types";
import React from "react";

interface ImageGalleryProps {
	images: ToolImageDTO[];
	toolName: string;
}

const ImagePlaceholder = () => (
	<div className="flex h-full min-h-[400px] w-full items-center justify-center bg-muted text-muted-foreground">
		<span>Brak zdjęcia</span>
	</div>
);

export default function ImageGallery({ images, toolName }: ImageGalleryProps) {
	if (!images || images.length === 0) {
		return <ImagePlaceholder />;
	}

	const sortedImages = [...images].sort((a, b) => a.position - b.position);
	const primaryImage = sortedImages[0];
	const secondaryImages = sortedImages.slice(1, 5); // Max 4 secondary images

	return (
		<div className="grid grid-cols-1 gap-2 md:grid-cols-2">
			<div className="md:col-span-1">
				<img
					src={`/api/storage/${primaryImage.storage_key}`}
					alt={`Główne zdjęcie narzędzia ${toolName}`}
					className="h-full w-full rounded-lg object-cover"
				/>
			</div>
			<div className="hidden grid-cols-2 grid-rows-2 gap-2 md:grid">
				{secondaryImages.map((image) => (
					<div key={image.storage_key}>
						<img
							src={`/api/storage/${image.storage_key}`}
							alt={`Zdjęcie narzędzia ${toolName} #${image.position}`}
							className="h-full w-full rounded-lg object-cover"
						/>
					</div>
				))}
				{/* Fill remaining grid cells if fewer than 4 secondary images */}
				{Array.from({ length: 4 - secondaryImages.length }).map((_, i) => (
					<div key={`placeholder-${i}`} className="rounded-lg bg-muted" />
				))}
			</div>
		</div>
	);
}
