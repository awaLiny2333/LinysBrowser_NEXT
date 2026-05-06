import lazy { url } from '@kit.ArkTS';
import lazy { meow, meowLevel } from './catsLogger';

/**
 * Get keyword entries from a URL.
 * @param source the url.
 * @returns the keyword entries.
 */
export function getKeywordEntries(source: string): [string, string][] {
  try {
    const theUrl = url.URL.parseURL(source);
    const iterator = theUrl.params.entries();
    return Array.from(iterator);
  } catch (e) {
    meow(`Failed to parse URL: ${source}`, 'getKeywordEntries', meowLevel.WARN);
    return []
  }
}
