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
