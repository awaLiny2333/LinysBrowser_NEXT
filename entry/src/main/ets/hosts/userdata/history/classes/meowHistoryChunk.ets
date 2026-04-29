/**
 * A meowHistoryChunk is a bundle of data representing a chunk of history (a month).
 * Its components include the chunk file that contains all history entries in text [chunk], index of the chunk [index] and the index data [data].
 * It also holds caches of meowHistoryEntries and the meowHistoryIndexFileBundle loaded from the disk.
 *
 * Contains a deleteHistory function but no addHistory function.
 * Since addHistory should be manipulated by the meowHistorian itself
 * because there may be a case of adding a new history entry to a new chunk file (first of the month!).
 *
 * Theoratically clearing this.indexBundle or this.entries does no physical harm to the system.
 * Because all other parts in this system is expected to call this.loadEntriesFromDisk() before using this.entries
 * and call this.loadIndexFromDisk() before using this.indexBundle.
 * So they are considered cache instead of real data of a chunk.
 *
 * In NO case they should be cleared (reset to undefined) manually in any codes other than the aforementioned two this.load...FromDisk() functions and the .
 * Use this.loadEntriesFromDisk(true) and this.loadIndexFromDisk(true) instead.
 *
 * Relationships:
 * [HAS A] meowHistoryIndexFileBundle
 * [HAS A] meowHistoryEntry (in collections.Array<meowHistoryEntry>)
 */

import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { readArrayBufferConcurrent, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import { collections, fastbuffer } from "@kit.ArkTS";
import lazy { buildIndexToDisk, loadIndexFromDisk } from "../scripts/indexing";
import lazy { binarySearch, loadChunkFromDisk, tokenize } from "../scripts/helpers";
import { meowHistoryEntry } from "./meowHistoryEntry";
import { meowHistoryIndexFileBundle } from "./meowHistoryIndexFileBundle";

@Sendable
export class meowHistoryChunk {
  indexBasePath: string; // The base path of the histories. E.g. ".../history".
  chunkBasePath: string; // The base path of the indices. E.g. ".../history-index".
  chunkName: string; // The name of the chunk. Expected "history_YYYY_MM.txt".
  // Generated ↓
  chunkPath: string;
  indexPath: string;
  dataPath: string;
  month: number;
  year: number;
  // Cache ↓
  entries: collections.Array<meowHistoryEntry> | undefined;
  indexBundle: meowHistoryIndexFileBundle | undefined;

  /**
   * Constructor for meowHistoryChunk.
   * @param chunkBasePath The base path of the histories. E.g. ".../history".
   * @param indexBasePath The base path of the indices. E.g. ".../history-index".
   * @param chunkName The name of the chunk. Expected "history_YYYY_MM.txt".
   * @author Assisted by DeepSeek @ 2026 Mar 31
   */
  constructor(chunkBasePath: string, indexBasePath: string, chunkName: string) {
    this.indexBasePath = indexBasePath;
    this.chunkBasePath = chunkBasePath;
    this.chunkName = chunkName;
    // Derive the file paths of this chunk according to given chunkName.
    this.chunkPath = `${chunkBasePath}/${chunkName}`;
    this.indexPath = `${indexBasePath}/${chunkName}.v2.index`;
    this.dataPath = `${indexBasePath}/${chunkName}.v2.data`;

    // Match against the expected pattern: history_YYYY_MM.txt
    const match = chunkName.match(/^history_(\d{4})_(\d{2})\.txt$/);
    if (!match) {
      throw new Error(`Invalid filename format: ${chunkName}. Expected "history_YYYY_MM.txt".`);
    }

    this.year = parseInt(match[1], 10);
    this.month = parseInt(match[2], 10);
  }

  /**
   * Loads and initializes the full history entries of the chunk from the local disk. Does nothing if the entries are already there (already initialized) and force is false.
   */
  async loadEntriesFromDisk(force: boolean = false) {
    if (this.entries && !force) {
      return;
    }
    try {
      this.entries = await loadChunkFromDisk(this.chunkPath); // Entries are monotonically in increasing order of timestamp.
    } catch (e) {
      meow(`Failed to load entries from disk for chunk ${this.chunkPath}: ${e}`, 'meowHistoryChunk][loadEntriesFromDisk', meowLevel.ERROR);
    }
  }

  /**
   * Loads and initializes the index bundle of the chunk from the local disk. Does nothing if indexBundle is already there (already initialized) and force is false.
   */
  async loadIndexFromDisk(force: boolean = false) {
    if (this.indexBundle && !force) {
      return;
    }
    this.indexBundle = await loadIndexFromDisk(this.indexPath, this.dataPath);
  }

  /**
   * Looks up history entries for a given query. Would load index and entries from disk.
   * @param query Any query word(s) / string.
   * @param maxResults The maximum number of results to return.
   * @returns A promise that resolves to an array of meowHistory objects.
   */
  async lookUpHistoryEntries(query: string, maxResults: number = 20): Promise<meowHistoryEntry[]> {
    // const startTime = Date.now();

    // Get index bundles.
    await this.loadIndexFromDisk();
    if (!this.indexBundle) {
      meow(`this.initIndexBundleFromDisk() failed to do its mission! Query of key ${query} @ ${this.indexPath}`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.ERROR);
      return [];
    }

    // Get history entries.
    await this.loadEntriesFromDisk();
    if (!this.entries) {
      meow(`this.getEntries() failed to do its mission! Query of key ${query} @ ${this.indexPath}`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.ERROR);
      return [];
    }
    
    if (query === '') {
      return Array.from(this.entries);
    }

    // Tokenize query
    const queryTokens = tokenize(query);

    // Find intersection of all timestamp arrays
    // CodeGenie in DevEco Studio Preview wrote this @ April 1 2026. Let's trust her... for now. :)
    let firstFilled = false;
    let intersectionOfEntries = new collections.Set<number>();
    for (const token of queryTokens) {
      const numberArray = await this.indexBundle.getEntriesForKey(token);
      if (!numberArray) continue;
      if (!firstFilled) {
        // Be the 火锅底料 of the set.
        intersectionOfEntries = new collections.Set<number>(numberArray);
        firstFilled = true;
      } else {
        try {
          intersectionOfEntries = new collections.Set<number>(numberArray.filter(x => intersectionOfEntries.has(x)));
        } catch (e) {
          meow(`Failed to intersect timestamps for query "${query}", token = ${token} in chunk ${this.indexPath}: ${e}`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.ERROR);
        }
      } // Calculate intersection.
      if (intersectionOfEntries.size == 0) {
        // This is printing too many stuffs into the console.
        // meow(`No intersection found for query "${query}", token = ${token} in chunk ${this.indexPath}. Early broken.`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.WARN);
        return [];
      } // No intersection. Early break. Return empty array.
    }

    // Fetch history entries for the intersection
    const fetchedHistories: meowHistoryEntry[] = [];
    for (const timestamp of intersectionOfEntries) {
      try {
        // Clearly tell the compiler:
        // T is meowHistoryEntry (the thing in the array)
        // K is number (what you are looking for)
        const index = binarySearch<meowHistoryEntry, number>(
          this.entries,
          timestamp, // ✅ Now the types match perfectly
          (entry, ts) => entry.time - ts
        );
        if (index !== -1) fetchedHistories.push(this.entries[index]);
      } catch (e) {
        meow(`Failed to fetch history entry for timestamp ${timestamp} in chunk ${this.indexPath}: ${e}`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.ERROR);
      }
      if (fetchedHistories.length >= maxResults) break; // Reach limit. Break earlier.
    }

    // meow(`Looked up history entries for query "${query}" in chunk ${this.indexPath} (${Date.now() - startTime} ms)`, 'meowHistoryChunk][lookUpHistoryEntries', meowLevel.INFO);
    return fetchedHistories;
  }

  /**
   * Delete the entries corresponding to the specified timestamp DIRECTLY from the chunk file, and then overwrite the file. Also updates this.entries and the index.
   * @param filePath The history chunk file path.
   * @param timestampsToDelete The timestamps to delete.
   * @author ChatGLM @ 2026 Mar 31, modified by awa_Liny.
   */
  async deleteHistory(timestampsToDelete: Set<string>) {
    const startTime = Date.now();
    meow(`Starts now: chunk ${this.chunkPath} (${Date.now() - startTime} ms))`, 'meowHistoryChunk][deleteHistory', meowLevel.INFO);

    // Read full text.
    let text = '';
    try {
      text = fastbuffer.from(await readArrayBufferConcurrent(this.chunkPath)).toString();
    } catch (e) {
      meow(`Error reading file: ${e}`, 'meowHistoryChunk][deleteHistory', meowLevel.ERROR);
      return false;
    }

    meow(`About to filter chunk ${this.chunkPath} (${Date.now() - startTime} ms))`, 'meowHistoryChunk][deleteHistory', meowLevel.INFO);

    // FILTER, fixed by DeepSeek @ Apr 28 2026
    const lines = text.split('\n');
    const kept: string[] = [];
    const indicesToDelete: number[] = []; // Collect indices to be deleted

    for (let i = 0; i + 2 < lines.length; i += 3) {
      const tsLine = lines[i + 2];
      if (timestampsToDelete.has(tsLine)) {
        // Record the original index (i/3) for later unified deletion.
        indicesToDelete.push(i / 3);
        // meow(`Deleted entry for timestamp ${tsLine} in chunk ${this.chunkPath}`, 'meowHistoryChunk][deleteHistory', meowLevel.WARN);
      } else {
        // Keep
        kept.push(lines[i], lines[i + 1], lines[i + 2]);
      }
    }

    meow(`Filter OK in chunk ${this.chunkPath} (${Date.now() - startTime} ms))`, 'meowHistoryChunk][deleteHistory', meowLevel.INFO);

    // Sort from largest to smallest and delete to avoid index offset.
    if (this.entries && indicesToDelete.length > 0) {
      indicesToDelete.sort((a, b) => b - a);
      for (const idx of indicesToDelete) {
        try {
          this.entries.splice(idx, 1);
        } catch (e) {
          meow(`Failed to delete history entry at index ${idx} in chunk ${this.chunkPath}: ${e}`, 'meowHistoryChunk][deleteHistory', meowLevel.ERROR);
        }
      }
    }

    // Write.
    const saveResult = await saveHybrid(this.chunkPath, kept.join('\n'), true) || true; // In fact this line won't return undefined in any case. Because we have set overwrite to true.

    // Index
    await buildIndexToDisk(this.indexBasePath, this, false);
    await this.loadIndexFromDisk(true); // Load built index.
    meow(`Deleted ${timestampsToDelete.size} items in [${this.chunkPath}] (${Date.now() - startTime} ms)`, 'meowHistoryChunk][deleteHistory', meowLevel.INFO);
    return saveResult;
  }
}
