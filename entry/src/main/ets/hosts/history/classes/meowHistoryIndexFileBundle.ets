/**
 * A bundle that holds index information ([index] & [data]) and provide query functions.
 * Takes in indexFilePath and dataFilePath for [index] & [data] information.
 *
 * [index] contains all keys and the positions and lengths in the data file of their corresponding timestamps.
 * [data] contains all timestamps. They are filled linearly with no space between, one by one.
 * Each timestamp takes 8 bytes of space (64 bit numbers for timestamps in milliseconds in TS).
 *
 * [data] at dataFilePath is not loaded to the bundle,
 * but its segments are requested to be read from disk in each request of query.
 * This saves memory, i guess, if the data file is really large.
 */

import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { readArrayBufferConcurrent } from "../../../catstypicalframework/utils/storage";
import { collections, fastbuffer } from "@kit.ArkTS";

@Sendable
export class meowHistoryIndexFileBundle {
  indexFilePath: string; // for example "/data/storage/el2/base/haps/entry/files/history-index/history_2026_03.txt.index"
  dataFilePath: string; // for example "/data/storage/el2/base/haps/entry/files/history-index/history_2026_03.txt.data"
  indexKeyHeaders: collections.Map<string, meowHistoryIndexHeader> = new collections.Map<string, meowHistoryIndexHeader>(); // Generated in this.init().
  ready: boolean = false;

  constructor(indexFilePath: string, dataFilePath: string) {
    this.indexFilePath = indexFilePath;
    this.dataFilePath = dataFilePath;
  }

  /**
   * Reads the index file and generate the map of keys to index data positins.
   */
  async init() {
    // Read the index file.
    const indexFileBundle = await readArrayBufferConcurrent(this.indexFilePath);
    if (!indexFileBundle) {
      meow(`Failed to read index file ${this.indexFilePath}`, 'meowHistoryIndexFileBundle', meowLevel.ERROR);
      return;
    }

    // Read and parse
    try {
      const text = fastbuffer.from(indexFileBundle).toString();

      // const lines = indexText.split('\n');
      // for (let i = 0; i < lines.length; i += 3) {
      //   if (lines[i] === '') continue;
      //   const key = lines[i];
      //   const positionStart = Number(lines[i + 1]);
      //   const length = Number(lines[i + 2]);
      //   this.indexKeyHeaders.set(key, new meowHistoryIndexHeader(positionStart, length));
      // }

      // Optimized by ChatGLM @ Apr 6 2026
      // 假设这是在某个类的方法内部
      const len = text.length;
      let pos = 0;

      while (pos < len) {
        // --- 读取第 1 行：Key ---
        let nextNl = text.indexOf('\n', pos);
        if (nextNl === -1) break; // 文件读完了或者格式损坏，直接终止

        // 🚀 极速跳过空行：如果 pos 等于 nextNl，说明这两个符号之间没有字符，直接跳过，连 substring 都不调用！
        if (pos === nextNl) {
          pos = nextNl + 1;
          continue;
        }

        // 只有确认不是空行，才去截取字符串（避免无意义的内存分配）
        const key = text.substring(pos, nextNl);
        pos = nextNl + 1;

        // --- 读取第 2 行：Position Start ---
        nextNl = text.indexOf('\n', pos);
        if (nextNl === -1) break;
        // 使用 parseInt 替代 Number()，对于纯整数字符串，parseInt 更快且不会有浮点数转换的开销
        const positionStart = parseInt(text.substring(pos, nextNl), 10);
        pos = nextNl + 1;

        // --- 读取第 3 行：Length ---
        nextNl = text.indexOf('\n', pos);
        if (nextNl === -1) break;
        const length = parseInt(text.substring(pos, nextNl), 10);
        pos = nextNl + 1;

        // --- 存入 Map ---
        this.indexKeyHeaders.set(key, new meowHistoryIndexHeader(positionStart, length));
      }

    } catch (e) {
      meow(`Failed to parse index file ${this.indexFilePath}: ${e}`, 'meowHistoryIndexFileBundle', meowLevel.ERROR);
    }
    
    this.ready = true;
  }

  /**
   * Checks if a key exists in the index file.
   * @param key The SINGLE token key to check.
   * @returns The array of timestamps indexed, undefined if ran into an error.
   */
  async getEntriesForKey(key: string) {
    if (!this.ready) {
      meow(`Index file ${this.indexFilePath} is not ready yet.`, 'meowHistoryIndexFileBundle', meowLevel.ERROR);
      return undefined;
    }

    const startTime = Date.now();

    try {
      // Get the key header of the key.
      // The header remembers the positionStart and length of the indexed ids under this key.
      const header = this.indexKeyHeaders.get(key);
      if (!header) {
        // meow(`Header for key ${key} not found in index file ${this.indexFilePath}.`, 'meowHistoryIndexFileBundle', meowLevel.WARN);
        return [];
      }

      // Precisely read the index segment from disk.
      const segmentStart = header.positionStart * Float64Array.BYTES_PER_ELEMENT;
      const segmentLength = header.length * Float64Array.BYTES_PER_ELEMENT;
      const timestampsSegment = await readArrayBufferConcurrent(this.dataFilePath, segmentStart, segmentLength);
      if (!timestampsSegment) {
        meow(`Failed to read data file ${this.dataFilePath}, start: ${segmentStart}, length: ${segmentLength}`, 'meowHistoryIndexFileBundle', meowLevel.ERROR);
        return undefined;
      }

      // Process arrayBuffer into readable number[].
      const timestampsArray = Array.from(new Float64Array(timestampsSegment));
      meow(`Read data file ${this.dataFilePath} and got numberArray, length is ${timestampsArray.length} (${Date.now() - startTime} ms)`, 'meowHistoryIndexFileBundle', meowLevel.INFO);
      return timestampsArray;

    } catch (e) {
      meow(`Failed to get key ${key} in index file ${this.indexFilePath}: ${e}`, 'meowHistoryIndexFileBundle', meowLevel.ERROR);
      return undefined;
    }
  }
}

@Sendable
class meowHistoryIndexHeader {
  positionStart: number;
  length: number;

  /**
   * The constructor of meowHistoryIndexHeader.
   * @param positions The positions of the index.
   * @param length The length of the indexed ids under this key.
   */
  constructor(positionStart: number, length: number) {
    this.positionStart = positionStart;
    this.length = length;
  }
}
