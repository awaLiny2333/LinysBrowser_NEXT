import lazy { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData";
import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { fileCopySync, path_2_uri, uri_2_path } from "../../../../catstypicalframework/utils/storage";
import { isLegalUrl } from "../../../../catstypicalframework/utils/url";
import lazy { meowBoardHolder, MeowScratchingBoardData, MeowScratchingBoardDataType } from "../classes/meowBoardHolder";

let myBoard: meowBoardHolder | undefined = undefined;

/**
 * Guarantee the existence of the meowAppHost instance and return it.
 * @returns The meowAppHost object!
 */
export function getMyBoard() {
  if (!myBoard) {
    myBoard = AppStorageV2.connect(meowBoardHolder, () => new meowBoardHolder())!;
  }
  return myBoard;
}

/**
 * All the accepted types of the meowBoardHolder.
 */
export const meowBoardHolderAccepteTypesSet = new Set<string>([
  uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
  uniformTypeDescriptor.UniformDataType.HYPERLINK,
  uniformTypeDescriptor.UniformDataType.IMAGE
]);

/**
 * unifiedDataChannel.UnifiedRecord[] to MeowScratchingBoardData[].
 * @param records unifiedDataChannel.UnifiedRecord[]
 * @returns MeowScratchingBoardData[]
 * @author DeepSeek Web @ May 13 2025
 */
export function unifiedRecord2BoardData(records: unifiedDataChannel.UnifiedRecord[], unique: boolean, tempDir: string) {
  const newRecords: MeowScratchingBoardData[] = [];
  const contentSet = new Set<string>(); // 合并去重：同时用于 URL 和 TEXT

  records.forEach((rec) => {
    const type = rec.getType();
    switch (type) {
      case uniformTypeDescriptor.UniformDataType.PLAIN_TEXT: {
        const items = splitUrls((rec as unifiedDataChannel.PlainText).textContent);
        for (const item of items) {
          const content = item.content as string;
          if (!contentSet.has(content)) {
            if (unique) {
              contentSet.add(content);
            }
            newRecords.push(item);
          }
        }
        break;
      }

      case uniformTypeDescriptor.UniformDataType.HYPERLINK: {
        const url = (rec as unifiedDataChannel.Hyperlink).url;
        const description = (rec as unifiedDataChannel.Hyperlink).description;

        // URL 原子处理
        if (!contentSet.has(url)) {
          if (unique) {
            contentSet.add(url);
          }
          newRecords.push({
            type: MeowScratchingBoardDataType.URL,
            content: url
          });
        }

        // description 原子处理
        if (description && !contentSet.has(description)) {
          if (unique) {
            contentSet.add(description);
          }
          newRecords.push({
            type: MeowScratchingBoardDataType.TEXT,
            content: description
          });
        }
        break;
      }

      case uniformTypeDescriptor.UniformDataType.IMAGE: {
        const imgUri = (rec as unifiedDataChannel.Image).imageUri;
        if (!contentSet.has(imgUri)) {
          if (unique) {
            contentSet.add(imgUri);
          }

          const newPath = `${tempDir}/dragdrop-temp/${Date.now()}`; // TODO: suffix for images.
          fileCopySync(uri_2_path(imgUri), newPath, false);

          newRecords.push({
            type: MeowScratchingBoardDataType.IMAGE,
            // content: imgUri
            content: path_2_uri(newPath)
          });
        }

        const uri = (rec as unifiedDataChannel.Image).uri;
        if (!contentSet.has(uri)) {
          if (unique) {
            contentSet.add(uri);
          }
          newRecords.push({
            type: MeowScratchingBoardDataType.URL,
            content: uri
          });
        }
        break;
      }
      default: {
        meow(`Entry of type ${type} is not accepted!`, 'meowBoardHolder][addEntry');
      }
    }
  });

  return newRecords;
}

// Helper interface to replace object literal types
interface UrlMatch {
  url: string;
  start: number;
  end: number;
}

/**
 * Splits a text into segments of plain text and URLs.
 * URLs are validated using isLegalUrl and become URL-type entries.
 * All other content becomes TEXT-type entries.
 */
export function splitUrls(text: string): MeowScratchingBoardData[] {
  const startTime = Date.now();

  if (!text || text.length === 0) {
    return [];
  }

  const segments = text.split(/(\s+)/);
  const filteredSegments: string[] = [];
  for (let i = 0; i < segments.length; i++) {
    if (segments[i].length > 0) {
      filteredSegments.push(segments[i]);
    }
  }

  const result: MeowScratchingBoardData[] = [];

  for (let i = 0; i < filteredSegments.length; i++) {
    const seg = filteredSegments[i];
    if (/\s/.test(seg)) {
      result.push({
        type: MeowScratchingBoardDataType.TEXT,
        content: seg
      });
    } else {
      const parts = splitToken(seg);
      for (let j = 0; j < parts.length; j++) {
        result.push(parts[j]);
      }
    }
  }

  const merged = mergeTextSegments(result);
  // 去除每个 TEXT 的首尾空白，并丢弃空 TEXT

  const r = trimAndFilterTextEntries(merged);

  meow(`Done in (${Date.now() - startTime} ms)`, 'splitUrls', meowLevel.WARN);

  return r;
}

function splitToken(token: string): MeowScratchingBoardData[] {
  const urlMatch = findFirstUrlInToken(token);
  if (urlMatch === null) {
    return [{ type: MeowScratchingBoardDataType.TEXT, content: token }];
  }

  const url = urlMatch.url;
  const start = urlMatch.start;
  const end = urlMatch.end;

  const parts: MeowScratchingBoardData[] = [];

  if (start > 0) {
    const leftText = token.substring(0, start);
    const leftParts = splitToken(leftText);
    for (let i = 0; i < leftParts.length; i++) {
      parts.push(leftParts[i]);
    }
  }

  parts.push({
    type: MeowScratchingBoardDataType.URL,
    content: url
  });

  if (end < token.length) {
    const rightText = token.substring(end);
    const rightParts = splitToken(rightText);
    for (let i = 0; i < rightParts.length; i++) {
      parts.push(rightParts[i]);
    }
  }

  return parts;
}

function findFirstUrlInToken(token: string): UrlMatch | null {
  let bestStart = -1;
  let bestEnd = -1;
  let bestUrl = '';

  for (let start = 0; start < token.length; start++) {
    for (let end = token.length; end > start; end--) {
      const candidate = token.substring(start, end);
      const isLegalTuple = isLegalUrl(candidate);
      const isLegal = isLegalTuple[0];
      if (isLegal) {
        if (bestStart === -1 || start < bestStart) {
          bestStart = start;
          bestEnd = end;
          bestUrl = candidate;
        }
        break;
      }
    }
  }

  if (bestStart !== -1) {
    const match: UrlMatch = { url: bestUrl, start: bestStart, end: bestEnd };
    return match;
  }
  return null;
}

function mergeTextSegments(data: MeowScratchingBoardData[]): MeowScratchingBoardData[] {
  const merged: MeowScratchingBoardData[] = [];
  for (let i = 0; i < data.length; i++) {
    const item = data[i];
    if (item.type === MeowScratchingBoardDataType.TEXT) {
      if (merged.length > 0 && merged[merged.length - 1].type === MeowScratchingBoardDataType.TEXT) {
        merged[merged.length - 1].content = merged[merged.length - 1].content + item.content;
      } else {
        const newItem: MeowScratchingBoardData = {
          type: MeowScratchingBoardDataType.TEXT,
          content: item.content
        };
        merged.push(newItem);
      }
    } else {
      const newItem: MeowScratchingBoardData = {
        type: item.type,
        content: item.content
      };
      merged.push(newItem);
    }
  }
  return merged;
}

/**
 * 去除每个 TEXT 条目首尾空白（包括换行、空格等），
 * 如果结果为空白字符串，则删除该条目。
 * URL 条目保持不变。
 */
function trimAndFilterTextEntries(data: MeowScratchingBoardData[]): MeowScratchingBoardData[] {
  const cleaned: MeowScratchingBoardData[] = [];
  for (let i = 0; i < data.length; i++) {
    const item = data[i];
    if (item.type === MeowScratchingBoardDataType.TEXT) {
      const trimmed = item.content.trim(); // 去除首尾所有空白
      if (trimmed.length > 0) {
        const newItem: MeowScratchingBoardData = {
          type: MeowScratchingBoardDataType.TEXT,
          content: trimmed
        };
        cleaned.push(newItem);
      }
      // 空字符串则跳过
    } else {
      // URL 或 IMAGE 原样保留
      const newItem: MeowScratchingBoardData = {
        type: item.type,
        content: item.content
      };
      cleaned.push(newItem);
    }
  }
  return cleaned;
}
