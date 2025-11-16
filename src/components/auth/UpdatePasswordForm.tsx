import React, { useState, useEffect } from 'react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '../ui/card';
import { Alert, AlertDescription, AlertTitle } from '../ui/alert';

export function UpdatePasswordForm() {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);

    const response = await fetch('/api/auth/update-password', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ password }),
    });

    setLoading(false);

    if (response.ok) {
      setMessage('Twoje hasło zostało pomyślnie zaktualizowane. Zostaniesz przekierowany na stronę główną.');
      setTimeout(() => {
        window.location.href = '/';
      }, 3000);
    } else {
      const data = await response.json();
      setError(data.error || 'Nie udało się zaktualizować hasła. Link mógł wygasnąć.');
    }
  };

  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle className="text-2xl">Ustaw nowe hasło</CardTitle>
        <CardDescription>
          Wprowadź swoje nowe hasło poniżej.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {message ? (
          <Alert>
            <AlertTitle>Sukces!</AlertTitle>
            <AlertDescription>{message}</AlertDescription>
          </Alert>
        ) : (
          <form onSubmit={handleSubmit}>
            <div className="grid w-full items-center gap-4">
              <div className="flex flex-col space-y-1.5">
                <Label htmlFor="password">Nowe hasło</Label>
                <Input
                  id="password"
                  type="password"
                  placeholder="********"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
            </div>
            {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
            <Button type="submit" className="w-full mt-4" disabled={loading}>
              {loading ? 'Aktualizowanie...' : 'Zaktualizuj hasło'}
            </Button>
          </form>
        )}
      </CardContent>
      { !message && (
        <CardFooter>
            <a href="/auth/login" className="text-sm underline">
            Wróć do logowania
            </a>
        </CardFooter>
      )}
    </Card>
  );
}
