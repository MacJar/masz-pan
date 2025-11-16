import React, { useState } from 'react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '../ui/card';
import { Alert, AlertDescription, AlertTitle } from '../ui/alert';

export function ForgotPasswordForm() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);

    const response = await fetch('/api/auth/forgot-password', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email }),
    });

    setLoading(false);

    if (response.ok) {
      setMessage('Jeśli konto istnieje, wysłaliśmy link do resetowania hasła na podany adres e-mail.');
    } else {
      const data = await response.json();
      setError(data.error || 'Wystąpił błąd. Spróbuj ponownie.');
    }
  };

  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Zresetuj hasło</CardTitle>
        <CardDescription>
          Podaj swój adres e-mail, a wyślemy Ci link do zresetowania hasła.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {message ? (
          <Alert>
            <AlertTitle>Sprawdź swoją skrzynkę!</AlertTitle>
            <AlertDescription>{message}</AlertDescription>
          </Alert>
        ) : (
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
            </div>
            {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
            <Button type="submit" className="w-full mt-4" disabled={loading}>
              {loading ? 'Wysyłanie...' : 'Wyślij link do resetowania'}
            </Button>
          </form>
        )}
      </CardContent>
      <CardFooter>
        <a href="/auth/login" className="text-sm underline">
          Wróć do logowania
        </a>
      </CardFooter>
    </Card>
  );
}
