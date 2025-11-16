import React, { useState } from "react";
import { useProfileManager } from "@/components/hooks/useProfileManager";
import type { ProfileDTO } from "@/types";
import { SkeletonLoader } from "./SkeletonLoader";
import { ErrorDisplay } from "./ErrorDisplay";
import { ProfileForm } from "./ProfileForm";
import { LocationStatus, type GeocodingStatus } from "./LocationStatus";
import { QuickActions } from "./QuickActions";
import { Card, CardContent } from "../ui/card";
import { Button } from "../ui/button";
import { UpdatePasswordDialog } from "./UpdatePasswordDialog";
import { Toaster } from "../ui/sonner";

function deriveGeocodingStatus(profile: ProfileDTO | null): GeocodingStatus {
  if (!profile || !profile.location_text) {
    return "NOT_SET";
  }
  if (profile.location_geog) {
    return "SUCCESS";
  }
  if (profile.last_geocoded_at) {
    // Attempted but failed
    return "ERROR";
  }
  // Has text, but no geocoding attempt yet
  return "PENDING";
}

export function ProfileView() {
  const { profile, isLoading, isSubmitting, error, fieldErrors, saveProfile, setFieldErrors } = useProfileManager();
  const [isPasswordDialogOpen, setIsPasswordDialogOpen] = useState(false);

  if (isLoading) {
    return <SkeletonLoader />;
  }

  if (error) {
    return <ErrorDisplay message={error} />;
  }

  const geocodingStatus = deriveGeocodingStatus(profile);

  const handleClearFieldErrors = (fieldName: keyof typeof fieldErrors) => {
    setFieldErrors((prev) => {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { [fieldName]: _, ...rest } = prev;
      return rest;
    });
  };

  return (
    <>
      <Toaster position="top-center" richColors />
      <div className="max-w-2xl mx-auto">
        <div className="bg-card p-6 rounded-lg shadow-sm">
          <div className="flex justify-between items-start mb-4">
            <h2 className="text-xl font-semibold">Dane profilowe</h2>
            <LocationStatus status={geocodingStatus} />
          </div>
          <ProfileForm
            profile={profile}
            isSubmitting={isSubmitting}
            onSubmit={saveProfile}
            fieldErrors={fieldErrors}
            onClearFieldErrors={handleClearFieldErrors}
          />
        </div>

        {profile && (
          <div className="mt-6 text-center">
            <a
              href={`/u/${profile.id}`}
              className="inline-block bg-primary text-primary-foreground hover:bg-primary/90 px-4 py-2 rounded-md transition-colors text-sm font-medium"
            >
              Zobacz jak wygląda mój profil publiczny
            </a>
          </div>
        )}

        <Card className="mt-8">
          <CardContent className="pt-6">
            <div className="flex justify-between items-center">
              <div>
                <h3 className="text-lg font-semibold">Zmień hasło</h3>
                <p className="text-sm text-muted-foreground">Zalecamy regularną zmianę hasła w celu ochrony konta.</p>
              </div>
              <Button variant="outline" onClick={() => setIsPasswordDialogOpen(true)}>
                Zmień hasło
              </Button>
            </div>
          </CardContent>
        </Card>
        <UpdatePasswordDialog isOpen={isPasswordDialogOpen} onClose={() => setIsPasswordDialogOpen(false)} />
        <QuickActions />
      </div>
    </>
  );
}
