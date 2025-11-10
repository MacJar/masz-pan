import { useEffect, useMemo, useRef, useState } from "react";

export function useDebouncedValue<TValue>(value: TValue, delayMs: number): TValue {
  const [debounced, setDebounced] = useState<TValue>(value);
  const timeoutRef = useRef<number | null>(null);

  const delay = useMemo(() => {
    return Number.isFinite(delayMs) && delayMs >= 0 ? Math.floor(delayMs) : 300;
  }, [delayMs]);

  useEffect(() => {
    if (timeoutRef.current !== null) {
      window.clearTimeout(timeoutRef.current);
    }
    timeoutRef.current = window.setTimeout(() => {
      setDebounced(value);
      timeoutRef.current = null;
    }, delay);

    return () => {
      if (timeoutRef.current !== null) {
        window.clearTimeout(timeoutRef.current);
        timeoutRef.current = null;
      }
    };
  }, [value, delay]);

  return debounced;
}
