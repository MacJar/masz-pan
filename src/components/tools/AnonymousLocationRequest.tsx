import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Loader2, LocateFixed, Search } from "lucide-react";

export interface GeolocationCoordinates {
  latitude: number;
  longitude: number;
}

interface AnonymousLocationRequestProps {
  onLocationFound: (coords: GeolocationCoordinates) => void;
}

type Status = "idle" | "locating" | "geocoding" | "error";

export const AnonymousLocationRequest: React.FC<AnonymousLocationRequestProps> = ({ onLocationFound }) => {
  const [postalCode, setPostalCode] = useState("");
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState<string | null>(null);

  const isBusy = status === "locating" || status === "geocoding";

  const handleUseBrowserLocation = () => {
    setStatus("locating");
    setError(null);
    navigator.geolocation.getCurrentPosition(
      (position) => {
        onLocationFound(position.coords);
      },
      (err) => {
        setError(
          err.code === err.PERMISSION_DENIED
            ? "Brak pozwolenia na dostęp do lokalizacji."
            : "Nie udało się ustalić lokalizacji."
        );
        setStatus("error");
      }
    );
  };

  const handleGeocodePostalCode = async () => {
    const q = postalCode.trim();
    if (q.length < 3) {
      setError("Wprowadź poprawny kod pocztowy lub nazwę miejscowości.");
      setStatus("idle");
      return;
    }
    setStatus("geocoding");
    setError(null);

    try {
      const res = await fetch(`/api/geocode?q=${encodeURIComponent(q)}`);
      if (!res.ok) {
        throw new Error("Błąd serwera geokodowania.");
      }
      const data = await res.json();
      const coords = data?.coordinates;
      if (!coords || !Array.isArray(coords) || coords.length !== 2) {
        throw new Error("Nie znaleziono lokalizacji dla podanego zapytania.");
      }
      onLocationFound({ longitude: coords[0], latitude: coords[1] });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Wystąpił nieoczekiwany błąd.");
      setStatus("error");
    }
  };

  return (
    <Card className="max-w-md mx-auto">
      <CardHeader>
        <CardTitle>Znajdź narzędzia w pobliżu</CardTitle>
        <CardDescription>
          Aby zobaczyć narzędzia dostępne w Twojej okolicy, udostępnij swoją lokalizację lub podaj kod pocztowy.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <Button onClick={handleUseBrowserLocation} disabled={isBusy} className="w-full">
          {status === "locating" ? (
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          ) : (
            <LocateFixed className="mr-2 h-4 w-4" />
          )}
          Użyj mojej lokalizacji
        </Button>

        <div className="flex items-center space-x-2">
          <hr className="flex-grow" />
          <span className="text-muted-foreground text-sm">LUB</span>
          <hr className="flex-grow" />
        </div>

        <div className="flex w-full items-center space-x-2">
          <Input
            type="text"
            placeholder="Kod pocztowy lub miejscowość"
            value={postalCode}
            onChange={(e) => setPostalCode(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleGeocodePostalCode()}
            disabled={isBusy}
          />
          <Button type="submit" onClick={handleGeocodePostalCode} disabled={isBusy}>
            {status === "geocoding" ? <Loader2 className="h-4 w-4 animate-spin" /> : <Search className="h-4 w-4" />}
          </Button>
        </div>

        {error && <p className="text-sm text-destructive">{error}</p>}
      </CardContent>
    </Card>
  );
};

