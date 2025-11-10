import { useCallback, useEffect, useRef, useState } from "react";

export interface UseIntersectionOptions extends Omit<IntersectionObserverInit, "threshold"> {
  threshold?: number | number[];
  disabled?: boolean;
  onIntersect?: () => void;
}

/**
 * Minimal IntersectionObserver hook suitable for infinite scroll sentinels.
 * Attaches to a single DOM element; invokes `onIntersect` when crossing threshold.
 */
export function useIntersection(options: UseIntersectionOptions = {}) {
  const { root = null, rootMargin = "0px", threshold = 0.1, disabled = false, onIntersect } = options;
  const nodeRef = useRef<Element | null>(null);
  const observerRef = useRef<IntersectionObserver | null>(null);
  const [isIntersecting, setIsIntersecting] = useState(false);

  const setRef = useCallback((node: Element | null) => {
    nodeRef.current = node;
  }, []);

  useEffect(() => {
    if (disabled || !nodeRef.current) {
      setIsIntersecting(false);
      return;
    }

    observerRef.current = new IntersectionObserver(
      (entries) => {
        const entry = entries[0];
        const intersecting = Boolean(entry?.isIntersecting);
        setIsIntersecting(intersecting);
        if (intersecting && typeof onIntersect === "function") {
          onIntersect();
        }
      },
      { root, rootMargin, threshold }
    );

    observerRef.current.observe(nodeRef.current);

    return () => {
      observerRef.current?.disconnect();
      observerRef.current = null;
    };
  }, [root, rootMargin, threshold, disabled, onIntersect]);

  return { ref: setRef, isIntersecting };
}
