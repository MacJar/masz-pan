import React from "react";

export interface EmptyStateProps {
  query: string;
}

export default function EmptyState(props: EmptyStateProps): JSX.Element {
  const { query } = props;
  return (
    <div className="rounded-md border p-6 text-center">
      <p className="text-sm">
        Brak wyników dla zapytania <span className="font-medium">“{query}”</span>. Spróbuj użyć innej frazy lub sprawdź
        później.
      </p>
    </div>
  );
}




