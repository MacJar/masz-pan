import React from "react";
import type { PublicProfileDTO } from "@/types";
import { Star } from "lucide-react";

interface StarRatingProps {
	rating: number | null;
	count: number | null;
}

const StarRating = ({ rating, count }: StarRatingProps) => {
	const avgRating = rating ?? 0;
	const numRatings = count ?? 0;

	return (
		<div className="flex items-center gap-1 text-sm text-muted-foreground">
			<Star className={`h-4 w-4 ${avgRating > 0 ? "text-primary fill-primary" : "text-muted-foreground"}`} />
			<span className="font-semibold">{avgRating.toFixed(1)}</span>
			<span>({numRatings} {numRatings === 1 ? "ocena" : "ocen"})</span>
		</div>
	);
};

interface OwnerBadgeProps {
	owner: PublicProfileDTO | null;
	isLoading: boolean;
	error: Error | null;
}

export default function OwnerBadge({ owner, isLoading, error }: OwnerBadgeProps) {
	if (isLoading) {
		// TODO: Replace with Skeleton component
		return <div className="h-10 w-full animate-pulse rounded-md bg-muted"></div>;
	}

	if (error || !owner) {
		return <div className="text-sm text-destructive">Nie udało się załadować danych właściciela.</div>;
	}

	return (
		<a href={`/u/${owner.id}`} className="block rounded-lg border p-4 transition-colors hover:bg-muted/50">
			<div className="flex items-center justify-between">
				<div>
					<p className="text-sm text-muted-foreground">Właściciel</p>
					<p className="font-semibold">{owner.username}</p>
				</div>
				<StarRating rating={owner.avg_rating} count={owner.ratings_count} />
			</div>
		</a>
	);
}
