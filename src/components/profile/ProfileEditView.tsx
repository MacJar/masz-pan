import React from "react";
import { useProfileEditor } from "@/components/hooks/useProfileEditor";
import { SkeletonLoader } from "@/components/profile/SkeletonLoader";
import { ErrorDisplay } from "@/components/profile/ErrorDisplay";
import { ProfileForm } from "@/components/profile/ProfileForm";
import { Toaster } from "@/components/ui/sonner";

export function ProfileEditView() {
  const {
    formData,
    isLoading,
    isSubmitting,
    error,
    handleFieldChange,
    handleSubmit,
  } = useProfileEditor();

  if (isLoading) {
    return <SkeletonLoader />;
  }

  if (error) {
    return <ErrorDisplay message={error} />;
  }

  return (
    <>
      <Toaster position="top-center" richColors />
      <ProfileForm
        profile={formData}
        isSubmitting={isSubmitting}
        onSubmit={handleSubmit}
        fieldErrors={formData.errors}
        onClearFieldErrors={(fieldName) => handleFieldChange(fieldName, formData[fieldName as keyof typeof formData])}
      />
    </>
  );
}

export default ProfileEditView;
