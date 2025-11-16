import React from "react";
import type { PublicProfileViewModel } from "@/types";
import PublicProfileHeader from "@/components/profile/PublicProfileHeader";
import RatingSummary from "@/components/profile/RatingSummary";
import PublicToolCard from "@/components/tools/PublicToolCard";

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
        <section className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-semibold">Aktywne narzędzia</h2>
            <span className="text-muted-foreground text-sm">{activeTools.length}</span>
          </div>
          {activeTools.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {activeTools.map((tool) => (
                <PublicToolCard key={tool.id} tool={tool} />
              ))}
            </div>
          ) : (
            <p className="text-muted-foreground">Ten użytkownik nie udostępnił jeszcze żadnych narzędzi.</p>
          )}
        </section>
      </div>
    </div>
  );
};

export default PublicProfileView;
