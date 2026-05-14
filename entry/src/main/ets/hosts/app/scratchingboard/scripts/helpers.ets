import lazy { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData";
import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { fileCopySync, fileNameOfPath, path_2_uri, uri_2_path } from "../../../../catstypicalframework/utils/storage";
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
  let lastAdd = '';

  records.forEach((rec) => {
    const type = rec.getType();
    switch (type) {
      case uniformTypeDescriptor.UniformDataType.PLAIN_TEXT: {
        const items = splitUrls((rec as unifiedDataChannel.PlainText).textContent);
        for (const item of items) {
          const content = item.content as string;
          if (lastAdd != content) {
            if (unique) {
              lastAdd = content;
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
        if (lastAdd != url) {
          if (unique) {
            lastAdd = url;
          }
          newRecords.push({
            type: MeowScratchingBoardDataType.URL,
            content: url
          });
        }

        // description 原子处理
        if (description && lastAdd != description) {
          if (unique) {
            lastAdd = description;
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
        if (lastAdd != imgUri) {
          if (unique) {
            lastAdd = imgUri;
          }

          const imgPath = uri_2_path(imgUri);
          const originalName = fileNameOfPath(imgPath);
          const originalExt = originalName.includes('.') ? `.${originalName.split('.').pop()}` : '';
          const newPath = `${tempDir}/dragdrop-temp/${Date.now()}${originalExt}`;
          fileCopySync(imgPath, newPath, false);

          newRecords.push({
            type: MeowScratchingBoardDataType.IMAGE,
            // content: imgUri
            content: path_2_uri(newPath)
          });
        }

        const uri = (rec as unifiedDataChannel.Image).uri;
        if (lastAdd != uri) {
          if (unique) {
            lastAdd = uri;
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

  const result: MeowScratchingBoardData[] = [];
  if (!text || text.length === 0) {
    return result;
  }

  const segments = text.split(/(\s+)/);
  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i];
    if (seg.length > 0) {
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
  }

  const merged = mergeTextSegments(result);
  // 去除每个 TEXT 的首尾空白，并丢弃空 TEXT

  // const r = trimAndFilterTextEntries(merged);

  meow(`Done in (${Date.now() - startTime} ms)`, 'splitUrls', meowLevel.WARN);

  return merged;
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
    parts.push({
      type: MeowScratchingBoardDataType.TEXT,
      content: leftText
    });
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
  const startTime = Date.now();
  let bestStart = -1;
  let bestEnd = -1;
  let bestUrl = '';

  for (let start = 0; start < token.length; start++) {
    for (let end = token.length; end > start; end--) {
      const candidate = token.substring(start, end);
      const isLegalTuple = isLegalUrl(candidate);
      const isLegal = isLegalTuple[0];
      // meow(`Candidate: ${candidate} - Legal: ${isLegal} (${isLegalTuple[1]}) (${Date.now() - startTime} ms)`, 'findFirstUrlInToken');
      if (isLegal) {
        if (bestStart === -1 || start < bestStart) {
          bestStart = start;
          bestEnd = end;
          bestUrl = candidate;
        }
        break;
      }
    }
    
    if (token.length - start < bestEnd - bestStart) {
      // Pointless to continue
      break;
    }
  }

  if (bestStart !== -1) {
    const match: UrlMatch = { url: bestUrl, start: bestStart, end: bestEnd };
    meow(`Found URL: ${bestUrl} at ${bestStart}-${bestEnd} (${Date.now() - startTime} ms)`, 'findFirstUrlInToken');
    return match;
  }
  return null;
}

function mergeTextSegments(data: MeowScratchingBoardData[]): MeowScratchingBoardData[] {
  const merged: MeowScratchingBoardData[] = [];

  // 提取出的“修剪末尾文本”逻辑
  const trimLastIfText = (lastItem: MeowScratchingBoardData | undefined): void => {
    if (lastItem !== undefined && lastItem.type === MeowScratchingBoardDataType.TEXT) {
      lastItem.content = lastItem.content.trim();
    }
  };

  // Process all data entries
  for (const item of data) {
    const last = merged[merged.length - 1]; // May be undefined! :Os
    if (item.type === MeowScratchingBoardDataType.TEXT) {
      // IS TEXT!
      if (merged.length > 0 && last.type === MeowScratchingBoardDataType.TEXT) {
        // Merge if last is also TEXT.
        last.content = last.content + item.content;
      } else {
        // Push a new one.
        const newItem: MeowScratchingBoardData = {
          type: MeowScratchingBoardDataType.TEXT,
          content: item.content
        };
        merged.push(newItem);
      }
    } else {
      // Trim last text if is not TEXT.
      trimLastIfText(last);
      const newItem: MeowScratchingBoardData = {
        type: item.type,
        content: item.content
      };
      merged.push(newItem);
    }
  }

  // 循环结束后，修剪最后一个文本
  const last = merged[merged.length - 1];
  trimLastIfText(last);

  return merged;
}
