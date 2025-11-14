import React from "react";

interface PublicProfileHeaderProps {
  username: string;
  locationText: string | null;
}

const PublicProfileHeader: React.FC<PublicProfileHeaderProps> = ({ username, locationText }) => {
  return (
    <header>
      <h1 className="text-4xl font-bold">{username}</h1>
      {locationText && <p className="text-lg text-muted-foreground mt-2">{locationText}</p>}
    </header>
  );
};

export default PublicProfileHeader;
