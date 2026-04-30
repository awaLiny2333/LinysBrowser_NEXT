import lazy collections from "@arkts.collections";
import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { readArrayBufferConcurrent } from "../../../../catstypicalframework/utils/storage";
import lazy { meowHistoryEntry } from "../classes/meowHistoryEntry";

/**
 * Fetches the history entries from one chunk file on the disk.
 * @returns The history entries in a sendable collections.Array<meowHistoryEntry>.
 * @throws Errors that fastbuffer and collections.Array.push would throw.
*/
export async function loadChunkFromDisk(chunkPath: string) {
  const startTime = Date.now();

  //     const entries = fastbuffer.from(await readArrayBufferConcurrent(chunkPath)).toString().split('\n');
  //     // Parse the text entries into meowHistoryEntry objects
  //     let history: collections.Array<meowHistoryEntry> = new collections.Array<meowHistoryEntry>();
  //     for (let i = 0; i + 2 < entries.length; i += 3) {
  //       history.push(new meowHistoryEntry(entries[i], entries[i + 1], parseInt(entries[i + 2])));
  //     }

  // Optimized by ChatGLM @ Apr 6 2026, again fixed by DeepSeek @Apr 28 2026
  let history: collections.Array<meowHistoryEntry> = new collections.Array<meowHistoryEntry>();
  const buffer = await readArrayBufferConcurrent(chunkPath);

  if (!buffer || buffer.byteLength === 0) {
    return history;
  }

  const text = fastbuffer.from(buffer).toString();
  const len = text.length;
  let pos = 0;

  while (pos < len) {
    let fields: string[] = [];

    // Try to extract exactly three lines
    for (let i = 0; i < 3; i++) {
      let nextNl = text.indexOf('\n', pos);
      if (nextNl === -1) {
        // No more newlines; the rest of the text is the last line
        if (pos < len && i === 2) {
          // Only accept if we're on the third field and there is content
          fields.push(text.substring(pos));
          pos = len;
        }
        // In any other case, the entry is incomplete – stop.
        break;
      }
      fields.push(text.substring(pos, nextNl));
      // Skip the newline; if it's \r\n we might need to strip \r, but for now assume \n
      pos = nextNl + 1;
    }

    if (fields.length === 3) {
      const arg3 = parseInt(fields[2], 10);
      // Optional: validate arg3 is a finite number if needed
      history.push(new meowHistoryEntry(fields[0], fields[1], arg3));
    } else {
      // Incomplete last entry – break out of the main loop
      break;
    }
  }

  meow(`Fetched history chunk at [${chunkPath}] (${Date.now() - startTime} ms)`, 'helpers][loadChunkFromDisk', meowLevel.INFO);
  return history;
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

/**
 * Ultra-fast general ascending binary search
 * @param arr ordered array (supports native Array and collections.Array)
 * @param target target value
 * @param compare comparison function: returns < 0 if mid is too small, > 0 if too large, === 0 if a match is found
 * @returns The index of the hit, returns -1 if not hit
 * @author ChatGLM @ Apr 6 2026.
 */
export function binarySearch<T, K>(
  arr: Array<T> | collections.Array<T>,
  target: K,
  compare: (midItem: T, targetItem: K) => number
): number {
  let low = 0;
  let high = arr.length - 1;

  while (low <= high) {
    const mid = (low + high) >>> 1;
    const cmp = compare(arr[mid], target);

    if (cmp < 0) {
      low = mid + 1;
    } else if (cmp > 0) {
      high = mid - 1;
    } else {
      return mid;
    }
  }

  return -1;
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

/**
 * Group entries by their full UTC date (year, month, day).
 * @param entries - Array of history entries sorted in ascending order by time.
 * @returns An array of groups, each group containing entries with the same UTC date.
 * @author DeepSeek @ Apr 29 2026.
 */
export function groupByDates(entries: meowHistoryEntry[]): meowHistoryEntry[][] {
  const startTime = Date.now();
  
  if (!entries || entries.length === 0) return [];

  // Calculate a simple UTC day key directly from the timestamp to avoid Date objects.
  // This uses the fact that timestamps are in milliseconds.
  const DAY_MS = 86_400_000; // 24 * 60 * 60 * 1000
  const getDateKey = (entry: meowHistoryEntry): number => Math.floor(entry.time / DAY_MS);

  const groups: meowHistoryEntry[][] = [];
  let currentGroup: meowHistoryEntry[] = [entries[0]];
  let lastKey = getDateKey(entries[0]);

  for (let i = 1; i < entries.length; i++) {
    const entry = entries[i];
    const key = getDateKey(entry);

    if (key === lastKey) {
      currentGroup.push(entry);
    } else {
      groups.push(currentGroup);
      currentGroup = [entry];
      lastKey = key;
    }
  }

  groups.push(currentGroup);
  
  meow(`Grouped ${entries.length} entries into ${groups.length} groups (${Date.now() - startTime} ms)`, 'helpers][groupByDates', meowLevel.INFO);
  return groups;
}
