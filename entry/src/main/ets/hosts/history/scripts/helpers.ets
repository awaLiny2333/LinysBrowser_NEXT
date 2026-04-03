import { readArrayBufferConcurrent } from "../../../catstypicalframework/utils/storage";
import { fastbuffer } from "@kit.ArkTS";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowHistoryEntry } from "../classes/meowHistoryEntry";
import collections from "@arkts.collections";

/**
 * Fetches the history entries from one chunk file on the disk.
 * @returns The history entries in a sendable collections.Array<meowHistoryEntry>.
 */
export async function loadChunkFromDisk(chunkPath: string) {
  const startTime = Date.now();
  try {
    const entries = fastbuffer.from(await readArrayBufferConcurrent(chunkPath)).toString().split('\n');

    // Parse the text entries into meowHistoryEntry objects
    let history: collections.Array<meowHistoryEntry> = new collections.Array<meowHistoryEntry>();
    for (let i = 0; i + 2 < entries.length; i += 3) {
      history.push(new meowHistoryEntry(entries[i], entries[i + 1], parseInt(entries[i + 2])));
    }

    meow(`Fetched history chunk at [${chunkPath}] (${Date.now() - startTime} ms)`, 'helpers][loadChunkFromDisk', meowLevel.INFO);
    return history;

  } catch (e) {
    meow(`Error reading file [${chunkPath}]: ${e}, returning an empty list. This happens to an empty history file. Relax if this is the case :)`, 'helpers][loadChunkFromDisk', meowLevel.ERROR);
    return new collections.Array<meowHistoryEntry>();
  }
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
 * Divides a segment of multi-language text into a collections.Set of tokens.
 * Compatible with environments that do not support escape (e.g., some ArkTS engines)
 * @param text The text to be tokenized.
 * @returns A collections.Set containing all the tokenized lowercase words.
 * @author DeepSeek @ Apr 2 2026, modified by awa_Liny.
 */
export function tokenize(text: string): collections.Set<string> {
  return new collections.Set(text.match(TOKEN_REGEX)?.map(s => s.toLowerCase()) ?? []);
}
