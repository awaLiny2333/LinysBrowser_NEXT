
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
