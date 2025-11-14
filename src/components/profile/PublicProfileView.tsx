import React from "react";
import type { PublicProfileViewModel } from "@/types";
import PublicProfileHeader from "@/components/profile/PublicProfileHeader";
import RatingSummary from "@/components/profile/RatingSummary";
import PublicToolsGrid from "@/components/tools/PublicToolsGrid";

interface PublicProfileViewProps {
  initialData: PublicProfileViewModel;
}

const PublicProfileView: React.FC<PublicProfileViewProps> = ({ initialData }) => {
  const { username, locationText, avgRating, ratingsCount, activeTools } = initialData;

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex flex-col gap-8">
        <PublicProfileHeader username={username} locationText={locationText} />
        <RatingSummary avgRating={avgRating} ratingsCount={ratingsCount} />
        <PublicToolsGrid tools={activeTools} />
      </div>
    </div>
  );
};

export default PublicProfileView;
