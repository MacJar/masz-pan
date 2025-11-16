import React, { useState } from "react";
import { Star } from "lucide-react";
import { cn } from "@/lib/utils";

interface StarRatingProps {
  rating: number;
  setRating: (rating: number) => void;
  disabled?: boolean;
}

const StarRating: React.FC<StarRatingProps> = ({ rating, setRating, disabled = false }) => {
  const [hover, setHover] = useState(0);

  return (
    <div className="flex space-x-1">
      {[...Array(5)].map((_, index) => {
        const ratingValue = index + 1;
        return (
          <label key={ratingValue}>
            <input
              type="radio"
              name="rating"
              value={ratingValue}
              onClick={() => !disabled && setRating(ratingValue)}
              className="sr-only"
              disabled={disabled}
            />
            <Star
              className={cn(
                "h-8 w-8 cursor-pointer transition-colors",
                ratingValue <= (hover || rating) ? "text-yellow-400 fill-yellow-400" : "text-gray-300",
                disabled && "cursor-not-allowed"
              )}
              onMouseEnter={() => !disabled && setHover(ratingValue)}
              onMouseLeave={() => !disabled && setHover(0)}
            />
          </label>
        );
      })}
    </div>
  );
};

export default StarRating;
