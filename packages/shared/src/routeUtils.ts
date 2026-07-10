/** Total stations = start + intermediate stops + end. */
export function totalStationCount(
  intermediateStops: number,
  options?: { hasFrom?: boolean; hasTo?: boolean }
): number {
  const hasFrom = options?.hasFrom ?? true;
  const hasTo = options?.hasTo ?? true;
  return (
    intermediateStops + (hasFrom ? 1 : 0) + (hasTo ? 1 : 0)
  );
}
