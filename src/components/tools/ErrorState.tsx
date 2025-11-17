import React from "react";

interface ErrorStateProps {
  message: string;
  cta?: React.ReactNode;
}

const ErrorState: React.FC<ErrorStateProps> = ({ message, cta }) => {
  return (
    <div className="flex flex-col items-center justify-center rounded-lg border border-dashed p-8 text-center">
      <div className="mb-4 text-2xl font-semibold">😕</div>
      <h3 className="text-xl font-semibold tracking-tight">Coś poszło nie tak</h3>
      <p className="mt-2 text-sm text-muted-foreground">
        {message || "Wystąpił nieoczekiwany błąd. Spróbuj ponownie później."}
      </p>
      {cta && <div className="mt-6">{cta}</div>}
    </div>
  );
};

export default ErrorState;
