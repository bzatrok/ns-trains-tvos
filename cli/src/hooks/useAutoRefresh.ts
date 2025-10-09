import { useEffect } from 'react';

export function useAutoRefresh(callback: () => void, intervalSeconds: number = 10) {
  useEffect(() => {
    // Call immediately on mount
    callback();

    // Then set up interval
    const intervalMs = intervalSeconds * 1000;
    const timer = setInterval(callback, intervalMs);

    // Cleanup on unmount
    return () => clearInterval(timer);
  }, [callback, intervalSeconds]);
}
