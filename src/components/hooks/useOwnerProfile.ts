import { useState, useEffect } from "react";
import type { PublicProfileDTO } from "@/types";

export function useOwnerProfile(ownerId: string | null) {
  const [owner, setOwner] = useState<PublicProfileDTO | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!ownerId) {
      setIsLoading(false);
      return;
    }

    const fetchOwnerProfile = async () => {
      setIsLoading(true);
      setError(null);
      try {
        // TODO: This endpoint does not exist yet. It needs to be created.
        // Based on the plan: GET /api/users/:id/profile
        const response = await fetch(`/api/users/${ownerId}/profile`);
        if (!response.ok) {
          throw new Error("Nie udało się pobrać profilu właściciela");
        }
        const data: PublicProfileDTO = await response.json();
        setOwner(data);
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Wystąpił nieznany błąd"));
      } finally {
        setIsLoading(false);
      }
    };

    fetchOwnerProfile();
  }, [ownerId]);

  return { owner, isLoading, error };
}
