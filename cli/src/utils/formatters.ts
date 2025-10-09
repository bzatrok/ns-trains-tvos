import { format, parseISO } from 'date-fns';

export function formatTime(isoString: string): string {
  try {
    return format(parseISO(isoString), 'HH:mm');
  } catch {
    return '??:??';
  }
}

export function formatDelay(delayMinutes: number): string {
  if (delayMinutes === 0) return '-';
  if (delayMinutes > 0) return `+${delayMinutes} MIN`;
  return `${delayMinutes} MIN`;
}

export function formatPlatform(platform: string, changed: boolean): string {
  const formattedPlatform = platform.toUpperCase();
  return changed ? `!${formattedPlatform}` : formattedPlatform;
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength - 3) + '...';
}
