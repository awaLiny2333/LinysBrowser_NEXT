import { taskpool } from "@kit.ArkTS";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { saveHybrid } from "../../../../catstypicalframework/utils/storage";
import { meowHistoryChunk } from "../classes/meowHistoryChunk";
import { meowHistoryIndexFileBundle } from "../classes/meowHistoryIndexFileBundle";

// Build
/**
 * Builds the index for a given chunk synchronously. You shouldn't call this sync function directly! Use the concurrent wrap!
 * @param indexBasePath The base path for the index files. This method would read ${indexBasePath}/history_yyyy_mm.txt.index and .data.
 * @param chunkYear The year of the chunk.
 * @param chunkMonth The month of the chunk. Ordering start with 1.
 * @param chunkPath The path of the chunk.
 */
@Concurrent
async function buildIndexToDiskSync(indexBasePath: string, chunk: meowHistoryChunk, cleanRebuild: boolean) {
  const startTime = Date.now();
  const indexChunkPath = `${indexBasePath}/history_${chunk.year}_${chunk.month.toString().padStart(2, '0')}.txt`;

  // i. Prerequisites

  // Read entries from the disk.
  await chunk.loadEntriesFromDisk(cleanRebuild);
  if (!chunk.entries) {
    meow(`chunk.loadEntriesFromDisk() failed to do its mission! indexChunkPath: ${indexChunkPath}. Quitting.`, 'indexing][buildIndexToDiskSync', meowLevel.ERROR);
    return;
  }

  // Discard indexBundle. So that in later queries, the chunks would notice the indexBundle is missing, and try to load out newly built index files from the disk!
  if (cleanRebuild) {
    chunk.indexBundle = undefined;
  }

  // ii. Build

  let totalTimestampCount = 0; // Total number of timestamps in the index.

  // Build the map from keys to timestamps.
  let indexMap: Map<string, number[]> = new Map<string, number[]>();
  for (let i = chunk.entries.length - 1; i >= 0; i--) {
    const hist = chunk.entries[i]; // Get hist

    // Ensure tokenize
    hist.tokenizeSelf();
    if (!hist.tokens) {
      continue; // Theoratically hist.tokenizeSelf(); would behave itself. But who knows :P
    }

    // Traverse the tokens and populate the index map.
    for (const token of hist.tokens) {
      const entry = indexMap.get(token); // Optimization: Search only once
      if (entry) {
        entry.push(hist.time);
      } else {
        indexMap.set(token, [hist.time]);
      }
      totalTimestampCount++; // Key point: Regardless of whether it goes through the if or else, a number is definitely inserted, and the total count increases by 1.
    }
  }

  // iii. Save

  // 1. Create a binary buffer
  const dataBuffer = new ArrayBuffer(totalTimestampCount * Float64Array.BYTES_PER_ELEMENT);
  const dataView = new Float64Array(dataBuffer);

  // 2. Fill the data and index arrays
  const indexLines: string[] = [];
  let currentOffset = 0;
  indexMap.forEach((ids, key) => {
    if (ids.length > 0) {
      dataView.set(ids, currentOffset);
    }
    indexLines.push(key, String(currentOffset), String(ids.length));
    currentOffset += ids.length;
  });

  // 3. Join the index lines with \n
  const indexText = indexLines.join('\n');

  // Save files
  await saveHybrid(`${indexChunkPath}.v2.index`, indexText, true);
  await saveHybrid(`${indexChunkPath}.v2.data`, dataBuffer, true);

  meow(`Built index ${chunk.year}-${chunk.month} to disk @[${indexChunkPath}] (${Date.now() - startTime} ms)`, 'indexing][buildIndexToDiskSync', meowLevel.INFO);
}

/**
 * Builds the index for ONE given chunk concurrently. You shouldn't call this directly. Use the Historian!
 * @param indexBasePath The base path for the index files. This method would read ${indexBasePath}/history_yyyy_mm.txt.index and .data.
 * @param chunk The chunk to build the index for.
 * @param cleanRebuild Whether to clean rebuild the index. (Discard existing entries and reset exising indexBudle)
 */
export async function buildIndexToDisk(indexBasePath: string, chunk: meowHistoryChunk, cleanRebuild: boolean) {
  try {
    await taskpool.execute(new taskpool.Task(buildIndexToDiskSync, indexBasePath, chunk, cleanRebuild));
  } catch (e) {
    meow(`Error building index for chunk ${chunk.year}-${chunk.month}: ${e}`, 'indexing][buildIndexToDisk', meowLevel.ERROR);
  }
}

/**
 * Builds the index for all chunks concurrently. You shouldn't call this directly. Use the Historian!
 * @param indexBasePath The base path for the index files. This method would read ${indexBasePath}/history_yyyy_mm.txt.index and .data.
 * @param chunks The chunks to build the index for.
 * @param cleanRebuild Whether to clean rebuild the index. (Discard existing entries and reset exising indexBudle)
 */
export async function buildAllIndexToDisk(indexBasePath: string, chunks: meowHistoryChunk[], cleanRebuild: boolean) {
  meow(`Building all chunks index concurrently into basePath ${indexBasePath}...`, 'indexing][buildAllIndexToDisk', meowLevel.INFO);
  try {
    let taskGroup = new taskpool.TaskGroup();
    chunks.forEach(chunk => {
      taskGroup.addTask(new taskpool.Task(buildIndexToDiskSync, indexBasePath, chunk, cleanRebuild));
    });
    await taskpool.execute(taskGroup);
  } catch (e) {
    meow(`Error building index for chunks: ${e}`, 'indexing][buildAllIndexToDisk', meowLevel.ERROR);
  }
}

// Read

/**
 * Reads the index file and returns a meowHistoryIndexFileBundle. You shouldn't call this sync function directly! Use the concurrent wrap!
 * @param indexFilePath The path of the index file.
 * @param dataFilePath The path of the data file.
 * @returns A meowHistoryIndexFileBundle.
 */
@Concurrent
async function loadIndexFromDiskSync(indexFilePath: string, dataFilePath: string) {
  let indexFileBundle = new meowHistoryIndexFileBundle(indexFilePath, dataFilePath);
  await indexFileBundle.init();
  return indexFileBundle;
}

/**
 * Reads the index files from disk and returns a meowHistoryIndexFileBundle.
 * @param indexFilePath The path of the index file.
 * @param dataFilePath The path of the data file.
 * @returns A meowHistoryIndexFileBundle.
 */
export async function loadIndexFromDisk(indexFilePath: string, dataFilePath: string) {
  const startTime = Date.now();
  try {
    const indexFileBundle = await taskpool.execute(new taskpool.Task(loadIndexFromDiskSync, indexFilePath, dataFilePath)) as meowHistoryIndexFileBundle;
    meow(`Read index file ${indexFilePath}, index size (${indexFileBundle.indexKeyHeaders.size}) (${Date.now() - startTime} ms)`, 'indexing][loadIndexFromDisk', meowLevel.INFO);
    return indexFileBundle;
  } catch (error) {
    meow(`Failed to read index file ${indexFilePath}: ${error}`, 'indexing][loadIndexFromDisk', meowLevel.ERROR);
    return undefined;
  }
}
