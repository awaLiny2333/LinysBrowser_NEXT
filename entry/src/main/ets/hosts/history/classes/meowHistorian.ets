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

import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { appendTextToEndOfFile, clearDirectory, listFilesUnderDir, readArrayBufferConcurrent, saveHybrid } from "../../../catstypicalframework/utils/storage";
import { fastbuffer } from "@kit.ArkTS";
import { fileIo } from "@kit.CoreFileKit";
import { buildAllIndexToDisk, buildIndexToDisk } from "../scripts/indexing";
import { meowHistoryEntry } from "./meowHistoryEntry";
import { meowHistoryChunk } from "./meowHistoryChunk";

@ObservedV2
export class meowHistorian {
  basePath: string;
  chunkBasePath: string;
  indexBasePath: string;
  @Trace lastUpdate: number = Date.now(); // Would be overwritten if init() succeeded.
  @Trace busy: boolean = true; // Initially true, Would be set to false after init().
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
      const lastUpdate = latestContent.slice(-13);
      if (lastUpdate) {
        this.lastUpdate = parseInt(lastUpdate);
        meow(`Last update: ${this.lastUpdate} in file ${latestChunkName}, and in human readable time, that is ${new Date(this.lastUpdate).toLocaleString()}`, 'meowHistorian][init', meowLevel.INFO);
      } else {
        meow(`No last update found in file ${latestChunkName}. What an empty month!`, 'meowHistorian][init', meowLevel.WARN);
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
    if (this.busy) {
      meow(`Busy. Rejected history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}]`, 'meowHistorian][pushHistory', meowLevel.WARN);
      return false;
    }

    // Only accept newer history entries.
    if (newHistoryEntry.time <= this.lastUpdate) {
      meow(`Time. Rejected history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}]`, 'meowHistorian][pushHistory', meowLevel.WARN);
      return false;
    }

    const startTime = Date.now();
    this.busy = true;

    // Check existence of target chunk file
    const chunkFilePath = `${this.chunkBasePath}/${this.historyChunkName(newHistoryEntry.time)}`;
    let chunkFileExist: boolean = false;
    try {
      chunkFileExist = await fileIo.access(chunkFilePath);
    } catch (error) {
      meow(`Error checking file existence: ${error}`, 'meowHistorian][pushHistory', meowLevel.ERROR);
      this.busy = false;
      return false;
    }

    // Directly append to file. Avoid loading anything from the disk again.
    let result = true;
    if (chunkFileExist) {
      result = await appendTextToEndOfFile(chunkFilePath, `\n${newHistoryEntry.title}\n${newHistoryEntry.url}\n${newHistoryEntry.time}`); // Append to file.
    } else {
      result = await saveHybrid(chunkFilePath, `${newHistoryEntry.title}\n${newHistoryEntry.url}\n${newHistoryEntry.time}`, true) || true; // Create file.
      this.chunks.unshift(new meowHistoryChunk(this.chunkBasePath, this.indexBasePath, this.historyChunkName(newHistoryEntry.time))); // Record it to the head of the list (latest).
    }

    // File operations failed.
    if (!result) {
      meow(`Failed to push history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}] One of the storing methods failed.`, 'meowHistorian][pushHistory', meowLevel.ERROR);
      this.busy = false;
      return false;
    }

    // (Re) Build index of this chunk.
    let affectedChunk = this.chunks[0]; // Because the latest chunk is always the 0th chunk in list.
    try {
      affectedChunk.entries?.push(newHistoryEntry);
    } catch (e) {
      meow(`Error pushing history ${newHistoryEntry}: ${e}`, 'meowHistorian][pushHistory', meowLevel.ERROR);
    } // Direct and manually update entry ↓.
    await buildIndexToDisk(`${this.indexBasePath}`, affectedChunk, false); // Would utilize existing entries and won't read from disk.
    await affectedChunk.loadIndexFromDisk(true); // Load built index.
    meow(`Built index of chunk #${0} (${Date.now() - startTime} ms)`, 'meowHistorian][pushHistory', meowLevel.INFO);

    // Fin.
    meow(`Pushed history: ["${newHistoryEntry.url}", "${newHistoryEntry.title}", ${newHistoryEntry.time}] (${Date.now() - startTime} ms)`, 'meowHistorian][pushHistory', meowLevel.INFO);
    this.lastUpdate = newHistoryEntry.time;
    this.busy = false;
    return true;
  }

  /**
   * Delete all entries with matching timestamps from the corresponding chunk file, then save the file. Orders doesn't matter.
   * @param timestamps List of timestamps of historical records to be deleted.
   * @author ChatGLM @ 2026 Mar 31
   */
  async deleteHistory(timestamps: number[]): Promise<boolean> {
    if (this.busy) {
      meow(`Busy. Rejected history: ["${timestamps.join(', ')}"]`, 'meowHistorian][deleteHistory', meowLevel.WARN);
      return false;
    }
    if (timestamps.length === 0) {
      meow(`Empty. Rejected history: ["${timestamps.join(', ')}"]`, 'meowHistorian][deleteHistory', meowLevel.WARN);
      return false;
    }

    const startTime = Date.now();
    this.busy = true;

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
      let theChunk = this.chunks[chunkIndex]; // Find the object of that chunk.
      tasks.push(theChunk.deleteHistory(tsSet));
    });
    await Promise.all(tasks);

    // 3. Fin.
    meow(`Deleted history: ["${timestamps.join(', ')}"] (${Date.now() - startTime} ms)`, 'meowHistorian][deleteHistory', meowLevel.INFO);
    this.busy = false;
    return true;
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
    if (this.busy) {
      meow(`Busy. Rejected history: ["${index}"]`, 'meowHistorian][getHistoryEntries', meowLevel.WARN);
      return [];
    }
    this.busy = true;

    await this.chunks[index].loadEntriesFromDisk();
    const result = Array.from(this.chunks[index].entries || []);

    this.busy = false;
    return result;
  }

  // Index

  /**
   * Rebuilds the index of all chunks.
   */
  async rebuildIndex() {
    if (this.busy) {
      meow(`Busy. Rejected rebuild`, 'meowHistorian][rebuildIndex', meowLevel.WARN);
      return false;
    }
    this.busy = true;

    await clearDirectory(`${this.indexBasePath}`); // Clear all built index files.
    await buildAllIndexToDisk(`${this.indexBasePath}`, this.chunks, true); // BUILD!

    this.busy = false;
    return true;
  }

  /**
   * Look up the query in all chunks in time order, and return query results.
   * @param query The query.
   * @param maxResults The maximum number of results to return.
   * @returns The query results.
   */
  async lookUpHistoryEntries(query: string, maxResults: number) {
    if (this.busy) {
      meow(`Busy. Rejected history: ["${query}", ${maxResults}]`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);
      return [];
    }

    console.log(' ');
    meow(`Looking up history: ["${query}", ${maxResults}]`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);

    const startTime = Date.now();
    this.busy = true;
    const result: meowHistoryEntry[] = [];


    // Optimized by ChatGLM @ Apr 6 2026
    // Prefer the latest 12 months.
    // If not enough, then go deeper to earlier history.

    const maxConcurrency = 12; // 定义最大并发数量（比如只查前 5 个 chunk）
    const targetChunks = this.chunks.slice(0, maxConcurrency); // 1. 直接截断，后面的 chunk 连 Promise 都不会产生
    const promises = targetChunks.map(chunk => chunk.lookUpHistoryEntries(query, maxResults)); // 2. 同时发起前 N 个查询
    const allResults = await Promise.all(promises); // 3. 等待并发结果

    for (let i = 0; i < allResults.length; i++) {
      const chunkResult = allResults[i];
      for (let j = 0; j < chunkResult.length; j++) {
        result.push(chunkResult[j]);
        if (result.length >= maxResults) {
          break;
        }
      }
      if (result.length >= maxResults) {
        break;
      }
    } // 4. 极速合并（避开 ArkTS 禁用的 ... 展开运算符，双层循环最安全最快）

    if (result.length < maxResults) {
      // Written manually by awa_Liny :O
      for (let i = 0; i < this.chunks.length; i++) {
        const chunk = this.chunks[i];
        const chunkResult = await chunk.lookUpHistoryEntries(query, maxResults - result.length);
        if (chunkResult.length > 0) {
          result.push(...chunkResult);
        }
        if (result.length >= maxResults) {
          break;
        }
      }
    } // 5. If is not enough

    // result.sort((a, b) => b.time - a.time);
    meow(`Looked up history: ["${query}", ${maxResults}], result is ${result.join(', ')} (${Date.now() - startTime} ms)`, 'meowHistorian][lookUpHistoryEntries', meowLevel.WARN);
    this.busy = false;
    return result;
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
