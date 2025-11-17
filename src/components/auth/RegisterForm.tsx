import React, { useState } from "react";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Label } from "../ui/label";
import { Card, CardContent, CardHeader, CardTitle, CardFooter } from "../ui/card";

export function RegisterForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    const response = await fetch("/api/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });

    setLoading(false);

    if (response.ok) {
      setSuccess(true);
    } else {
      const data = await response.json();
      setError(data.error || "Rejestracja nie powiodła się");
    }
  };

  if (success) {
    return (
      <Card className="w-[350px]">
        <CardHeader>
          <CardTitle className="text-2xl">Rejestracja udana</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Sprawdź swoją skrzynkę mailową, aby potwierdzić rejestrację.</p>
        </CardContent>
        <CardFooter>
          <a href="/auth/login" className="underline">
            Powrót do logowania
          </a>
        </CardFooter>
      </Card>
    );
  }

  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle className="text-2xl">Zarejestruj się</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit}>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="Twój email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="password">Hasło</Label>
              <Input
                id="password"
                type="password"
                placeholder="Twoje hasło"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>
          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
          <Button type="submit" className="w-full mt-4" disabled={loading}>
            {loading ? "Rejestrowanie..." : "Zarejestruj się"}
          </Button>
        </form>
      </CardContent>
      <CardFooter>
        <p className="text-sm">
          Masz już konto?{" "}
          <a href="/auth/login" className="underline">
            Zaloguj się
          </a>
        </p>
      </CardFooter>
    </Card>
  );
}
