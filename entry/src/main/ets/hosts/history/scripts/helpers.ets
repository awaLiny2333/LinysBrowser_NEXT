import { readArrayBufferConcurrent } from "../../../catstypicalframework/utils/storage";
import { fastbuffer } from "@kit.ArkTS";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowHistoryEntry } from "../classes/meowHistoryEntry";
import collections from "@arkts.collections";

/**
 * Fetches the history entries from one chunk file on the disk.
 * @returns The history entries in a sendable collections.Array<meowHistoryEntry>.
 * @throws Errors that fastbuffer and collections.Array.push would throw.
*/
export async function loadChunkFromDisk(chunkPath: string) {
  const startTime = Date.now();
  // try {

  //     const entries = fastbuffer.from(await readArrayBufferConcurrent(chunkPath)).toString().split('\n');
  //     // Parse the text entries into meowHistoryEntry objects
  //     let history: collections.Array<meowHistoryEntry> = new collections.Array<meowHistoryEntry>();
  //     for (let i = 0; i + 2 < entries.length; i += 3) {
  //       history.push(new meowHistoryEntry(entries[i], entries[i + 1], parseInt(entries[i + 2])));
  //     }

  // Optimized by ChatGLM @ Apr 6 2026
  let history: collections.Array<meowHistoryEntry> = new collections.Array<meowHistoryEntry>();
  const buffer = await readArrayBufferConcurrent(chunkPath);

  if (!buffer || buffer.byteLength === 0) {
    return history;
  }

  const text = fastbuffer.from(buffer).toString();
  const len = text.length;
  let pos = 0;

  while (pos < len) {
    // --- 读取第 1 行：entries[i] ---
    let nextNl = text.indexOf('\n', pos);
    if (nextNl === -1) break; // 文件结束或格式异常，直接退出，不会产生脏数据
    const arg1 = text.substring(pos, nextNl);
    pos = nextNl + 1;

    // --- 读取第 2 行：entries[i + 1] ---
    nextNl = text.indexOf('\n', pos);
    if (nextNl === -1) break;
    const arg2 = text.substring(pos, nextNl);
    pos = nextNl + 1;

    // --- 读取第 3 行：entries[i + 2] ---
    nextNl = text.indexOf('\n', pos);
    if (nextNl === -1) break;
    // 明确传入基数 10，比 Number() 少走一层类型推断逻辑
    const arg3 = parseInt(text.substring(pos, nextNl), 10);
    pos = nextNl + 1;

    // --- 构建对象并 push ---
    history.push(new meowHistoryEntry(arg1, arg2, arg3));
  }

  meow(`Fetched history chunk at [${chunkPath}] (${Date.now() - startTime} ms)`, 'helpers][loadChunkFromDisk', meowLevel.INFO);
  return history;

  // } catch (e) {
  //   meow(`Error reading file [${chunkPath}]: ${e}, returning an empty list. This happens to an empty history file. Relax if this is the case :)`, 'helpers][loadChunkFromDisk', meowLevel.ERROR);
  //   return new collections.Array<meowHistoryEntry>();
  // }
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

/**
 * 极速通用升序二分查找
 * @param arr 有序数组 (支持原生 Array 和 collections.Array)
 * @param target 目标值
 * @param compare 比较函数: 返回 < 0 表示 mid 值偏小, > 0 表示偏大, === 0 表示命中
 * @returns 命中的索引，未命中返回 -1
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

