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

  const segments = text.split(/(\s+)/);
  // const segments = text.split(/(\s+|[。！？；，、])/);
  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i];
    if (seg.length > 0) {
      if (/\s/.test(seg)) {
        result.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, seg));
      } else {
        // meow(`Going to split token [${seg}]!`, 'splitUrls');
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
    // meow(`No URL found in token [${token}]`, 'splitToken');
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
    // meow(`Found url [${url}] in token [${token}]! Passing rightTexts onward: [${rightText}]`, 'splitToken');
    const rightParts = splitToken(rightText);
    for (let i = 0; i < rightParts.length; i++) {
      parts.push(rightParts[i]);
    }
  } else {
    // meow(`Found url [${url}] in token [${token}]!`, 'splitToken');
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

  let searchStart = 0;
    while (searchStart < token.length) {
      // 优化：URL 只可能以字母、数字或 / 开头，跳过其他字符（如中文字符）
      const firstChar = token[searchStart];
      if (!/[A-Za-z0-9/]/.test(firstChar)) {
        searchStart++;
        continue;
      }

      FIND_LOOSE_URL_REGEX.lastIndex = searchStart;
      const match = FIND_LOOSE_URL_REGEX.exec(token);
      if (!match) break;

      const startIdx = match.index;
      const candidateBase = match[0];

      // 从当前匹配的最长候选开始，逐步缩短寻找合法 URL
      // 先剥离尾部常见的附着标点
      let currentCandidate = candidateBase.replace(/[.,;:!?)"']+$/, '');
    
      while (currentCandidate.length > 0) {
        if (isLegalUrl(currentCandidate)[0]) {
          const globalEnd = startIdx + currentCandidate.length;
          const result: UrlMatch = { url: currentCandidate, start: startIdx, end: globalEnd };
          meow(`Found URL: ${currentCandidate} at${startIdx}-${globalEnd} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken');
          return result;
        }

        // 缩短策略：
        // 对于没有 scheme 的 URL (如 example.com)，它必须包含点号才是合法的
        const hasScheme = /^[A-Za-z][A-Za-z0-9+.-]*:/.test(currentCandidate) || currentCandidate.startsWith("//");
        if (!hasScheme && currentCandidate !== "localhost" && !currentCandidate.includes(".")) {
          break; // 已经不可能是合法的 scheme-less URL 了，提前终止内部循环
        }

        // 逐字符缩短。这能完美处理类似 "example.comnow" 或 "http://example.comnow" 粘连的情况
        currentCandidate = currentCandidate.substring(0, currentCandidate.length - 1);
      }

      // 如果在当前匹配中没有找到合法 URL，从下一个位置继续搜索
      searchStart = startIdx + 1;
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
