import lazy { collections } from "@kit.ArkTS";

const INVISIBLE_REGEX = /^[\p{White_Space}\p{Cf}]*$/u;

/**
 * Checks if a string is blank, considering Unicode whitespace and control characters.
 * @param str The string to check.
 * @returns True if the string is blank, false otherwise.
 */
export function isBlank(str: string | null | undefined): boolean {
  return str === null || str === undefined || INVISIBLE_REGEX.test(str);
}

/**
 * Compares two strings and returns a concise diff representation
 * in the format `old fragment → new fragment`.
 *
 * For long strings, only the differing parts are shown, surrounded by
 * up to 20 characters of surrounding context (trimmed with `...`).
 * Newline characters are escaped as `\n` to keep output on one line.
 *
 * @param oldStr - The original string.
 * @param newStr - The new string to compare against.
 * @returns A human-readable diff string.
 * @author DeepSeek @ May 4 2026.
 */
export function compareDiff(oldStr: string, newStr: string): string {
  // If identical, just return a simple escape (should rarely happen in practice)
  if (oldStr === newStr) {
    return `${oldStr.replaceAll('\n', '\\n')} → ${newStr.replaceAll('\n', '\\n')}`;
  }

  const MAX_CONTEXT = 20; // Max characters of unchanged context to keep on each side
  const MAX_TOTAL = 80; // Max total length for each side in the final output

  // 1. Find the length of the longest common prefix
  let i = 0;
  const minLen = Math.min(oldStr.length, newStr.length);
  while (i < minLen && oldStr[i] === newStr[i]) i++;

  // 2. Find the length of the longest common suffix (excluding the prefix)
  let j = 0;
  while (
    j < minLen - i &&
    oldStr[oldStr.length - 1 - j] === newStr[newStr.length - 1 - j]
  ) j++;

  // 3. Extract the differing parts
  const oldDiff = oldStr.substring(i, oldStr.length - j);
  const newDiff = newStr.substring(i, newStr.length - j);

  // 4. Helper: truncate a string if it exceeds the max length
  const truncate = (s: string, max: number): string =>
    s.length <= max ? s : s.substring(0, max) + '...';

  // 5. Build a display string with surrounding context for each side
  let buildDisplay: (base: string, diffPart: string) => string = (base: string, diffPart: string): string => {
    let display = '';
    // Leading context (before the diff)
    if (i > MAX_CONTEXT) {
      display = '...' + base.substring(i - MAX_CONTEXT, i) + diffPart;
    }
    else {
      display = base.substring(0, i) + diffPart;
    }
    // Trailing context (after the diff)
    if (j > MAX_CONTEXT) {
      display += base.substring(base.length - j, base.length - j + MAX_CONTEXT) + '...';
    }
    else {
      display += base.substring(base.length - j);
    }
    return display;
  };

  let oldDisplay = buildDisplay(oldStr, oldDiff);
  let newDisplay = buildDisplay(newStr, newDiff);

  // 6. Apply size truncation and escape newlines for single-line output
  oldDisplay = truncate(oldDisplay, MAX_TOTAL).replaceAll('\n', '\\n');
  newDisplay = truncate(newDisplay, MAX_TOTAL).replaceAll('\n', '\\n');

  return `${oldDisplay} → ${newDisplay}`;
}

/**
 * Fast single-pass match for lowercase keys. 
 * If the text contains minHitRate * 100% of the keys,
 * then this is considered true for a match.
 *
 * @param text   Lowercased text to search.
 * @param keys   Set of lowercased, regex-safe keys.
 * @param minHitRate Minimum hit rate (0–1).
 * @returns True if enough distinct keys were found.
 * @author DeepSeek @ Apr 29 2026.
 */
export function isMatchFast(text: string, keys: collections.Set<string>, minHitRate: number): boolean {
  // If the set is empty, consider it a match by default
  if (keys.size === 0) return true;

  // Pre-compute the required number of hits and the maximum allowed misses.
  // Note: we use keys.size instead of keys.length.
  const needHits = Math.ceil(minHitRate * keys.size);
  let maxMiss = keys.size - needHits;

  let hits = 0;
  let miss = 0;

  // Iterate over the Set using for...of
  for (const key of keys) {
    // Skip empty strings if any were added; adjust maxMiss to keep the math correct.
    if (!key) {
      maxMiss--;
      continue;
    }

    if (text.includes(key)) {
      hits++;
      // Early exit: we already have enough hits
      if (hits >= needHits) return true;
    } else {
      miss++;
      // Early exit: missed too many keys, impossible to reach the required hit rate
      if (miss > maxMiss) return false;
    }
  }

  return false;
}

// Promote regular expressions to constants and avoid repeated construction.
const CJK_RANGE = "\\u4e00-\\u9fff\\u3400-\\u4dbf\\uf900-\\ufaff";
const LATIN_RANGE = "A-Za-z\\u00C0-\\u024F";
const GREEK_RANGE = "\\u0370-\\u03FF";
const CYRILLIC_RANGE = "\\u0400-\\u04FF";
const ARABIC_RANGE = "\\u0600-\\u06FF";
const LETTER_RANGE = `${LATIN_RANGE}${GREEK_RANGE}${CYRILLIC_RANGE}${ARABIC_RANGE}`;
const TOKEN_REGEX = new RegExp(`[${CJK_RANGE}]|[${LETTER_RANGE}]+|\\d+`, "gu");

/**
 * Divides a segment of multi-language text into a collections.Set of tokens in lower case.
 * Compatible with environments that do not support escape (e.g., some ArkTS engines)
 * @param text The text to be tokenized.
 * @returns A collections.Set containing all the tokenized lowercase words.
 * @author DeepSeek @ Apr 2 2026, modified by awa_Liny.
 */
export function tokenize(text: string): collections.Set<string> {
  return new collections.Set(text.match(TOKEN_REGEX)?.map(s => s.toLowerCase()) ?? []);
}
