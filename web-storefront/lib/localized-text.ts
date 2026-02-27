import type { Lang } from '@/lib/i18n';

export function localizedText(lang: Lang, primary?: string, arabic?: string): string {
  if (lang === 'ar') {
    return arabic?.trim() || primary?.trim() || '';
  }
  return primary?.trim() || arabic?.trim() || '';
}
