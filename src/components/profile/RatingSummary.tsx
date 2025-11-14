import React from "react";

interface RatingSummaryProps {
  avgRating: number | null;
  ratingsCount: number;
}

const StarIcon: React.FC<{ filled: boolean }> = ({ filled }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill={filled ? "currentColor" : "none"}
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    className="w-6 h-6 text-yellow-400"
  >
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>
);

const RatingSummary: React.FC<RatingSummaryProps> = ({ avgRating, ratingsCount }) => {
  if (ratingsCount === 0) {
    return <p className="text-muted-foreground">Brak ocen</p>;
  }

  const roundedRating = avgRating ? Math.round(avgRating) : 0;

  return (
    <div className="flex items-center gap-4">
      <div className="flex items-center">
        {[...Array(5)].map((_, index) => (
          <StarIcon key={index} filled={index < roundedRating} />
        ))}
      </div>
      <div className="text-lg">
        <span className="font-bold">{avgRating?.toFixed(1) ?? "–"}</span>
        <span className="text-muted-foreground"> ({ratingsCount} ocen)</span>
      </div>
    </div>
  );
};

export default RatingSummary;
