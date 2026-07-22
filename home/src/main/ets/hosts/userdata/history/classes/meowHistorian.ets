/**
 * The Historian.
 * Manages the history chunks in the given path.
 * Accepts a basePath (of the sandbox, usaully) on construction.
 * It would seek chunks in "${basePath}/history" and index & data in "${basePath}/history-index".
 *
 * Note that the indexer no longer cares about "${basePath}/last_indexer_version.txt" as this is useless and reading it costs time.
 *
 * Relationships:
 * [HAS A] meowHistoryChunk (in meowHistoryChunk[])
 */

import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { fileIo } from "@kit.CoreFileKit";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { appendTextToEndOfFile, clearDirectory, listFilesUnderDir, readArrayBufferConcurrent, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import lazy { buildAllIndexToDisk, buildIndexToDisk } from "../scripts/indexing";
import { meowHistoryChunk } from "./meowHistoryChunk";
import lazy { meowHistoryEntry } from "./meowHistoryEntry";

@ObservedV2
export class meowHistorian {
  basePath: string;
  chunkBasePath: string;
  indexBasePath: string;
  @Trace lastUpdate: number = Date.now(); // Would be overwritten if init() succeeded.
  @Trace busy: boolean = true; // Initially true, Would be set to false after init().
  @Trace isRebuilding: boolean = false;
  @Trace private chunks: meowHistoryChunk[] = [];

  /**
   * Constructor for meowHistorian.
   * @param basePath The base path of the history, usually the base path of the app sandbox.
   * The historian would seek chunks in "${basePath}/history" and index & data in "${basePath}/history-index".
   */
  constructor(basePath: string) {
    this.basePath = basePath;
    this.chunkBasePath = `${basePath}/history`;
    this.indexBasePath = `${basePath}/history-index`;
  }

  /**
   * Initializes the Historian. Reads the lastUpdate time, the history chunks list and record them.
   */
  async init() {
    // List all files
    let chunkNames = await listFilesUnderDir(this.chunkBasePath);

    // Jump out
    if (!chunkNames || chunkNames.length == 0) {
      meow(`No history files found in ${this.chunkBasePath}`, 'meowHistorian][init', meowLevel.WARN);
      this.busy = false;
      return;
    }

    // Load chunks. Sort it to be in reversed order:
    chunkNames.sort((a, b) => b.localeCompare(a));
    for (const chunkName of chunkNames) {
      this.chunks.push(new meowHistoryChunk(this.chunkBasePath, this.indexBasePath, chunkName));
    }
    meow(`Found history chunks: ${chunkNames.join(', ')}`, 'meowHistorian][init', meowLevel.INFO);

    // Load latest file to determine lastUpdate.
    const latestChunkName = chunkNames[0]!;
    const latestArrayBuffer = await readArrayBufferConcurrent(`${this.chunkBasePath}/${latestChunkName}`);
    try {
      const latestContent = fastbuffer.from(latestArrayBuffer).toString();

      // Look for the last \n and pick the contents after. If there is no \n then we pick the entire file.
      const lastNewline = latestContent.lastIndexOf('\n');
      const rawTsString = lastNewline >= 0 ? latestContent.slice(lastNewline + 1).trim() : latestContent;
      const timeStampNum = parseInt(rawTsString, 10);

      // timeStampNum must > 1000000000000 (about 2001) to prevent NaN and values too small.
      if (!Number.isNaN(timeStampNum) && timeStampNum > 1000000000000) {
        this.lastUpdate = timeStampNum;
        meow(`Last update: ${this.lastUpdate} in file ${latestChunkName}, and in human readable time, that is ${new Date(this.lastUpdate).toLocaleString()}`, 'meowHistorian][init', meowLevel.INFO);
      } else {
        meow(`No valid last update found in ${latestChunkName}. rawTs = [${rawTsString}], num = [${timeStampNum}]`, 'meowHistorian][init', meowLevel.WARN);
      }

    } catch (e) {
      meow(`Error loading latest file: ${e}`, 'meowHistorian][init', meowLevel.ERROR);
    }
    this.busy = false;
  }

  // Operations

  /**
   * Pushes a history entry to the Historian.
   * @param newHistoryEntry The meowHistoryEntry.
   * @returns Whether the history entry was accepted and successfully added.
   */
  async pushHistory(newHistoryEntry: meowHistoryEntry) {
    if (!this.tryLock()) {
      meow(`Busy. Rejected history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}]`, 'meowHistorian][pushHistory', meowLevel.WARN);
      return false;
    }
    try {
      // Only accept newer history entries.
      if (newHistoryEntry.time <= this.lastUpdate) {
        meow(`Time. Rejected history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}]`, 'meowHistorian][pushHistory', meowLevel.WARN);
        return false;
      }

      const startTime = Date.now();

      // Check existence of target chunk file
      const chunkFilePath = `${this.chunkBasePath}/${this.historyChunkName(newHistoryEntry.time)}`;
      let chunkFileExist: boolean = false;
      try {
        chunkFileExist = await fileIo.access(chunkFilePath);
      } catch (error) {
        meow(`Error checking file existence: ${error}`, 'meowHistorian][pushHistory', meowLevel.ERROR);
        return false;
      }

      // Directly append to file. Avoid loading anything from the disk again.
      let result = true;
      let newChunkCreated = false;
      if (chunkFileExist) {
        result = await appendTextToEndOfFile(chunkFilePath, `\n${newHistoryEntry.title}\n${newHistoryEntry.url}\n${newHistoryEntry.time}`); // Append to file.
      } else {
        let createResult = await saveHybrid(chunkFilePath, `${newHistoryEntry.title}\n${newHistoryEntry.url}\n${newHistoryEntry.time}`, true); // Create file.
        if (createResult == undefined) {
          // File already exist, but this is not really gonna happen. Because we already asks the saveHybrid to overwrite.
          // What's more, overwriting in fact WON'T ever happen because chunkFileExist == FALSE in this branch!
          createResult = true;
        }
        result = createResult;
        if (result) {
          newChunkCreated = true;
        }
      }

      // File write failed.
      if (!result) {
        meow(`Failed to push history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}] One of the storing methods failed.`, 'meowHistorian][pushHistory', meowLevel.ERROR);
        return false;
      }

      // Sign up the new chunk in this.chunks.s
      if (newChunkCreated) {
        this.chunks.unshift(new meowHistoryChunk(this.chunkBasePath, this.indexBasePath, this.historyChunkName(newHistoryEntry.time))); // Record it to the head of the list (latest).
      }

      // (Re) Build index of this chunk.
      let affectedChunk = this.chunks[0]; // Because the latest chunk is always the 0th chunk in list. And no matter what there must be >= 1 element in this.chunks as long as we can get here.
      try {
        affectedChunk.entries?.push(newHistoryEntry);
        await buildIndexToDisk(this.indexBasePath, affectedChunk, false); // Would utilize existing entries and won't read from disk.
      } catch (e) {
        meow(`Error pushing history ${newHistoryEntry}: ${e}`, 'meowHistorian][pushHistory', meowLevel.ERROR);
        await buildIndexToDisk(this.indexBasePath, affectedChunk, true); // File write OK, but entries push failed.
        // We use clean rebuild to load histories (naturally including the new entry added in the former codes) and build the index again.
        // This is low efficient but this would only happen in really extreme cases.
      }
      await affectedChunk.loadIndexFromDisk(true); // Load built index.
      meow(`Built index of chunk #${0} (${Date.now() - startTime} ms)`, 'meowHistorian][pushHistory', meowLevel.INFO);

      // Fin.
      meow(`Pushed history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}] (${Date.now() - startTime} ms)`, 'meowHistorian][pushHistory', meowLevel.INFO);
      this.lastUpdate = newHistoryEntry.time;
      return true;
    } finally {
      this.busy = false;
    }
  }

  /**
   * Delete all entries with matching timestamps from the corresponding chunk file, then save the file. Orders doesn't matter.
   * @param timestamps Set of timestamps of historical records to be deleted.
   * @author ChatGLM @ 2026 Mar 31
   */
  async deleteHistory(timestamps: Set<number>): Promise<boolean> {
    if (!this.tryLock()) {
      meow(`Busy. Rejected.`, 'meowHistorian][deleteHistory', meowLevel.WARN);
      return false;
    }
    try {
      if (timestamps.size === 0) {
        meow(`Empty. Rejected.`, 'meowHistorian][deleteHistory', meowLevel.WARN);
        return false;
      }

      const startTime = Date.now();

      // 1. Build map of filePaths to timestamps
      const pathTsMap = new Map<string, Set<string>>();
      for (const ts of timestamps) {
        const filePath = `${this.chunkBasePath}/${this.historyChunkName(ts)}`;
        let tsSet = pathTsMap.get(filePath);
        if (!tsSet) {
          tsSet = new Set<string>();
          pathTsMap.set(filePath, tsSet);
        }
        tsSet.add(String(ts));
      }

      // 2. Request delete for each affected chunk.
      const tasks: Promise<boolean>[] = [];
      pathTsMap.forEach((tsSet: Set<string>, filePath: string) => {
        let chunkIndex: number = this.chunks.findIndex(ck => ck.chunkPath == filePath);
        if (chunkIndex >= 0) {
          let theChunk = this.chunks[chunkIndex]; // Find the object of that chunk.
          tasks.push(theChunk.deleteHistory(tsSet));
        } else {
          // No chunk is of this path... Is this really gonna happen?
        }
      });
      await Promise.all(tasks);

      // 3. Fin.
      meow(`Deleted history. (${Date.now() - startTime} ms)`, 'meowHistorian][deleteHistory', meowLevel.INFO);
      return true;
    } finally {
      this.busy = false;
    }
  }

  // Accessors

  getChunk(index: number) {
    return this.chunks[index];
  }

  getChunks() {
    return this.chunks;
  }

  /**
   * Reads the chunk of history of a specific month from disk into meowHistoryEntry[] and return.
   * @param index The index of chunk in Historian's attributes.
   */
  async getHistoryEntries(index: number) {
    if (!this.tryLock()) {
      meow(`Busy. Rejected history: ["${index}"]`, 'meowHistorian][getHistoryEntries', meowLevel.WARN);
      return [];
    }
    try {
      if (index < 0 || index >= this.chunks.length) return []; // Illegal range.
      await this.chunks[index].loadEntriesFromDisk();
      return Array.from(this.chunks[index].entries || []);
    } finally {
      this.busy = false;
    }
  }

  // Index

  /**
   * Rebuilds the index of all chunks.
   */
  async rebuildIndex() {
    if (this.isRebuilding) {
      meow(`Rebuilding. Rejected rebuild`, 'meowHistorian][rebuildIndex', meowLevel.WARN);
      return false;
    }
    if (!this.tryLock()) {
      meow(`Busy. Rejected rebuild`, 'meowHistorian][rebuildIndex', meowLevel.WARN);
      return false;
    }
    this.isRebuilding = true;
    try {
      await clearDirectory(`${this.indexBasePath}`); // Clear all built index files.
      await buildAllIndexToDisk(`${this.indexBasePath}`, this.chunks, true); // BUILD!
      return true;
    } finally {
      this.isRebuilding = false;
      this.busy = false;
    }
  }

  /**
   * Look up the query in all chunks in time order, and return query results.
   * @param query The query.
   * @param maxResults The maximum number of results to return.
   * @param bruteForce To use brute force or not.
   * @param minHitRate The minimum keyword hit rate for brute force.
   * @param unique Whether to return unique results only.
   * @returns The query results.
   */
  async lookUpHistoryEntries(query: string, maxResults: number, bruteForce: boolean, minHitRate = 0.8, unique = false) {
    if (!this.tryLock()) {
      meow(`Busy. Rejected history: ["${query}", ${maxResults}]`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);
      return [];
    }
    try {
      console.log(' ');
      meow(`Looking up history: ["${query}", ${maxResults}]`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);

      const startTime = Date.now();
      const result: meowHistoryEntry[] = [];

      const addedKeys = new Set<string>();

      // Optimized by ChatGLM @ Apr 6 2026
      // Prefer the latest 3 months.
      // If not enough, then go deeper to earlier history.
      // Loop till all history entries are checked or maxResults is reached.

      let currentStartIndex = 0;
      const maxConcurrency = 5; // Max concurrent promises.

      while (result.length < maxResults) {
        const end = Math.min(currentStartIndex + maxConcurrency, this.chunks.length);
        const targetChunks = this.chunks.slice(currentStartIndex, end); // 1. Directly slice the array to get the target chunks.

        if (targetChunks.length == 0) {
          meow(`No more chunks to check.`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);
          break;
        }

        const remaining = maxResults - result.length;
        const promises = targetChunks.map(chunk => (bruteForce ? chunk.lookUpHistoryEntriesBruteForce(query, minHitRate, remaining) : chunk.lookUpHistoryEntries(query, remaining))); // 2. Request concurrently for the remaining amount.
        const allResults = await Promise.all(promises); // 3. Wait for the results.

        for (let i = 0; i < allResults.length; i++) {
          const chunkResult = allResults[i];
          for (let j = 0; j < chunkResult.length; j++) {
            // Unique
            if (unique) {
              const key = `${chunkResult[j].url}|${chunkResult[j].title}`;
              if (addedKeys.has(key)) {
                continue;
              }
              addedKeys.add(key);
            }

            // Push
            result.push(chunkResult[j]);
            if (result.length >= maxResults) {
              break;
            }
          }
          if (result.length >= maxResults) {
            break;
          }
        } // 4. Use double loop to merge results.

        currentStartIndex += maxConcurrency;
        if (currentStartIndex >= this.chunks.length) break; // 5. If is enough
      } // The loop
      meow(`Looked up history: ["${query}", ${maxResults}], result length ${result.length} (${Date.now() - startTime} ms)`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);
      return result;
    } finally {
      this.busy = false;
    }
  }

  /**
   * Look up the query in a specific chunk in descending (new to old) time order, and return query results.
   * @param chunk The chunk.
   * @param query The query.
   * @param maxResults The maximum number of results to return.
   * @param bruteForce To use brute force or not.
   * @param minHitRate The minimum keyword hit rate for brute force.
   * @returns The query results.
   */
  async lookUpHistoryEntriesFromChunk(chunk: meowHistoryChunk, query: string, maxResults: number, bruteForce: boolean, minHitRate: number = 0.8) {
    if (bruteForce) {
      return await chunk.lookUpHistoryEntriesBruteForce(query, minHitRate, maxResults) ?? [];
    } else {
      return await chunk.lookUpHistoryEntries(query, maxResults) ?? [];
    }
  }

  // Locking

  /**
   * Attempts to acquire the exclusive operation mutex.
   *
   * The check and the set are separated by zero awaits,
   * which is atomic in the single-threaded ArkTS model — no two callers can pass this gate simultaneously.
   *
   * @returns true if the lock was acquired, false if another operation is already in progress.
   */
  private tryLock(): boolean {
    if (this.busy) {
      return false;
    }
    this.busy = true;
    return true;
  }

  // Helpers

  /**
   * Gets the history chunk name of a given chunk.
   * @param timestamp The timestamp.
   * @returns The chunk name.
   */
  private historyChunkName(timestamp: number) {
    const date = new Date(timestamp);
    return `history_${date.getUTCFullYear()}_${(date.getUTCMonth() + 1).toString().padStart(2, '0')}.txt`;
  }
}
