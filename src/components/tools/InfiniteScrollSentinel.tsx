import React, { useMemo } from "react";
import { useIntersection } from "@/components/hooks/useIntersection";

export interface InfiniteScrollSentinelProps {
  onIntersect(): void;
  disabled: boolean;
}

export default function InfiniteScrollSentinel(props: InfiniteScrollSentinelProps): JSX.Element {
  const { onIntersect, disabled } = props;
  const { ref } = useIntersection(
    useMemo(
      () => ({
        threshold: 0.1,
        disabled,
        onIntersect,
      }),
      [disabled, onIntersect]
    )
  );

  return <div ref={ref as unknown as React.RefObject<HTMLDivElement> as any} className="h-6 w-full" />;
}



