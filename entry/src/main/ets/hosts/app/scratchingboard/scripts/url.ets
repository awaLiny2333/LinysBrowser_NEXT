import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { isLegalUrl } from "../../../../catstypicalframework/utils/url";
import lazy { MeowScratchingBoardData, MeowScratchingBoardDataType } from "../classes/meowBoardHolder";

// Helper interface to replace object literal types
interface UrlMatch {
  url: string;
  start: number;
  end: number;
}

const FIND_LOOSE_URL_REGEX = /(?:[A-Za-z][A-Za-z0-9+.-]*:|\/\/|localhost|[A-Za-z0-9][A-Za-z0-9-]*\.)(?:[A-Za-z0-9\-._~:/?#[\]@!$&'()*+,;=%]*)/g;

/**
 * Splits a text into segments of plain text and URLs.
 * URLs are validated using isLegalUrl and become URL-type entries.
 * All other content becomes TEXT-type entries.
 * 
 * @param text The text to be analyzed.
 * @returns MeowScratchingBoardData[]
 * @author DeepSeek Web @ May 13 2026, optimized by Liny and ChatGLM Web @ May 14 2026
 */
export function splitUrls(text: string): MeowScratchingBoardData[] {
  const startTime = Date.now();

  const result: MeowScratchingBoardData[] = [];
  if (!text || text.length === 0) {
    return result;
  }

  // const segments = text.split(/(\s+)/);
  const segments = text.split(/(\s+|[。！？；，、])/);
  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i];
    if (seg.length > 0) {
      if (/\s/.test(seg)) {
        result.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, seg));
      } else {
        const parts = splitToken(seg);
        for (let j = 0; j < parts.length; j++) {
          result.push(parts[j]);
        }
      }
    }
  }

  const merged = mergeTextSegments(result);
  meow(`Done in (${Date.now() - startTime} ms)`, 'splitUrls', meowLevel.WARN);
  return merged;
}

/**
 * Splits a token (potentially containing urls) into MeowScratchingBoardData[].
 * 
 * @param token The token to be analyzed.
 * @returns MeowScratchingBoardData[]
 * @author DeepSeek Web @ May 13 2026
 */
function splitToken(token: string): MeowScratchingBoardData[] {
  const urlMatch = findFirstUrlInToken(token);
  if (urlMatch === null) {
    return [new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, token)];
  }

  const url = urlMatch.url;
  const start = urlMatch.start;
  const end = urlMatch.end;

  const parts: MeowScratchingBoardData[] = [];

  if (start > 0) {
    const leftText = token.substring(0, start);
    parts.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, leftText));
  }

  parts.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.URL, url));

  if (end < token.length) {
    const rightText = token.substring(end);
    const rightParts = splitToken(rightText);
    for (let i = 0; i < rightParts.length; i++) {
      parts.push(rightParts[i]);
    }
  }

  return parts;
}

/**
 * Finds the first URL in a token.
 * 
 * @param token The token.
 * @returns UrlMatch | null
 * @author DeepSeek Web @ May 13 2026, optimized by Liny and ChatGLM Web @ May 14 2026
 */
function findFirstUrlInToken(token: string): UrlMatch | null {
  const startTime = Date.now();

  // 宽松的正则：用于快速定位可能的 URL 起始位置，并提取最大合法字符序列
  // 1. Scheme: [A-Za-z][A-Za-z0-9+.-]*: (如 http:, mailto:, data:)
  // 2. Protocol-relative: //
  // 3. Scheme-less 域名/IP: 必须包含点 (如 example.com, 192.168.1.1)
  // 4. localhost
  // 尾部匹配所有 RFC 3986 合法字符，避免误截断

  let match: RegExpExecArray | null;
  while ((match = FIND_LOOSE_URL_REGEX.exec(token)) !== null) {
    const startIdx = match.index;
    const candidateBase = match[0];

    // 1. 快速校验整个候选字符串
    if (isLegalUrl(candidateBase)[0]) {
      const result: UrlMatch = { url: candidateBase, start: startIdx, end: startIdx + candidateBase.length };
      meow(`Found URL: ${candidateBase} at ${startIdx}-${startIdx + candidateBase.length} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken][A');
      return result;
    } else {
      meow(`Rejected URL: ${candidateBase} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken][A');
    }

    // 2. 剥离常见的附着在 URL 尾部的标点符号 (如 .,;:!?)")
    const stripped = candidateBase.replace(/[.,;:!?)"']+$/, '');
    if (stripped.length > 0 && stripped.length < candidateBase.length) {
      if (isLegalUrl(stripped)[0]) {
        const result: UrlMatch = { url: stripped, start: startIdx, end: startIdx + stripped.length };
        meow(`Found URL: ${stripped} at ${startIdx}-${startIdx + stripped.length} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken][B');
        return result;
      }
    }

    // 3. 兜底：按 URL 结构分隔符切割校验 (处理 URL 与其他合法字符粘连的情况)
    const boundaries = new Set<number>();
    const seps = '/?#&=,;:@';
    for (let i = 0; i < candidateBase.length; i++) {
      if (seps.includes(candidateBase[i])) {
        boundaries.add(i);
        boundaries.add(i + 1);
      }
    }
    // 降序排列，优先匹配最长合法前缀
    const sortedBoundaries = Array.from(boundaries).sort((a, b) => b - a);

    for (const len of sortedBoundaries) {
      if (len === 0 || len === candidateBase.length || len === stripped.length) continue;
      const candidate = candidateBase.substring(0, len);
      if (isLegalUrl(candidate)[0]) {
        const result: UrlMatch = { url: candidate, start: startIdx, end: startIdx + len };
        meow(`Found URL: ${candidate} at ${startIdx}-${startIdx + len} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken][C');
        return result;
      }
    }
  }

  return null;
}

/**
 * Merges consecutive TEXT-type entries into a single entry.
 * @param data The MeowScratchingBoardData[] to be merged.
 * @returns The merged MeowScratchingBoardData[].
 * @author Liny and ChatGLM Web @ May 14 2026
 */
function mergeTextSegments(data: MeowScratchingBoardData[]): MeowScratchingBoardData[] {
  const merged: MeowScratchingBoardData[] = [];

  // 提取出的“修剪末尾文本”逻辑
  const trimLastIfText = (lastItem: MeowScratchingBoardData | undefined): void => {
    if (lastItem !== undefined && lastItem.type === MeowScratchingBoardDataType.TEXT) {
      lastItem.textContent = lastItem.textContent.trim();
    }
  };

  // Process all data entries
  for (const item of data) {
    const last = merged[merged.length - 1]; // May be undefined! :Os
    if (item.type === MeowScratchingBoardDataType.TEXT) {
      // IS TEXT!
      if (merged.length > 0 && last.type === MeowScratchingBoardDataType.TEXT) {
        // Merge if last is also TEXT.
        last.textContent = last.textContent + item.textContent;
      } else {
        // Push a new one.
        merged.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, item.textContent));
      }
    } else {
      // Trim last text if is not TEXT.
      trimLastIfText(last);
      merged.push(new MeowScratchingBoardData(item.type, item.textContent));
    }
  }

  // 循环结束后，修剪最后一个文本
  const last = merged[merged.length - 1];
  trimLastIfText(last);

  return merged;
}
