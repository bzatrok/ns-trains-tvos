export const COLORS = {
  AMBER: 'yellow',
  ON_TIME: 'green',
  DELAYED: 'red',
  CANCELLED: 'yellow',
  PLATFORM_CHANGED: 'blue',
  DIM: 'gray',
} as const;

export type ColorName = typeof COLORS[keyof typeof COLORS];

export function getDelayColor(delayMinutes: number, cancelled: boolean): ColorName {
  if (cancelled) return COLORS.CANCELLED;
  if (delayMinutes === 0) return COLORS.ON_TIME;
  if (delayMinutes > 5) return COLORS.DELAYED;
  return COLORS.AMBER;
}

export function getStatusText(cancelled: boolean, delayMinutes: number): string {
  if (cancelled) return 'CANCELLED';
  if (delayMinutes === 0) return 'ON TIME';
  if (delayMinutes > 5) return 'DELAYED';
  return 'DELAYED';
}
