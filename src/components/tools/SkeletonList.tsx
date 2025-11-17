import React from "react";

export interface SkeletonListProps {
  count?: number;
}

export default function SkeletonList(props: SkeletonListProps): JSX.Element {
  const { count = 6 } = props;
  return (
    <ul className="space-y-3">
      {Array.from({ length: count }).map((_, idx) => (
        <li key={idx} className="animate-pulse rounded-md border p-4">
          <div className="h-4 w-40 rounded bg-muted" />
          <div className="mt-2 h-3 w-24 rounded bg-muted" />
        </li>
      ))}
    </ul>
  );
}
