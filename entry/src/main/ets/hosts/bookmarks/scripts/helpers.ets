import { meowBookmarkItem } from "../classes/meowBookmarkItem";
import { ENTITY_MAP } from "./entityMap";

/**
 * Escapes special characters to prevent HTML injection and structural breakage.
 *
 * ⚠️ CRITICAL: The ampersand (&) MUST be replaced first. If we replace '<' with '&lt;'
 * first, the subsequent '&' replacement would corrupt it into '&amp;lt;'.
 *
 * @param text The raw string (bookmark name or URL).
 * @returns The safely escaped string.
 * @author ChatGLM @ Apr 6 2026
 */
function encodeHtmlString(text: string): string {
  if (!text) return "";
  let result = text;
  result = result.replaceAll('&', '&amp;');
  result = result.replaceAll('<', '&lt;');
  result = result.replaceAll('>', '&gt;');
  result = result.replaceAll('"', '&quot;'); // Double quotes must be escaped to avoid breaking HREF="..."
  result = result.replaceAll("'", '&#39;'); // Single quotes escaped for strict XHTML compatibility
  return result;
}

/**
 * 完整 HTML 实体解码（ArkTS Strict 完全兼容）
 *
 * 覆盖范围：
 *   - 全部常见命名实体（&nbsp; &copy; &mdash; 等 60+ 个）
 *   - 十进制数字实体（&#169;）
 *   - 十六进制数字实体（&#xA9;）
 *   - 正确处理补充平面字符/Emoji（&#128512;）
 *
 * @param str 原始 HTML 字符串
 * @returns 解码后的字符串
 */
export function decodeHtmlString(str: string): string {
  // 短路：无 & 则必然无实体，直接返回
  if (str.indexOf('&') === -1) {
    return str;
  }

  let result = '';
  let i = 0;
  const len = str.length;

  while (i < len) {
    if (str.charAt(i) === '&') {
      // 寻找结束符 ;
      const semiIndex = str.indexOf(';', i + 1);
      // 限制查找长度，避免把正常文本中的分号误认为实体结尾（最长命名实体约 8 字符）
      if (semiIndex !== -1 && semiIndex - i <= 10) {
        const decoded = resolveEntity(str.substring(i + 1, semiIndex));
        if (decoded !== null) {
          result += decoded;
          i = semiIndex + 1;
          continue;
        }
      }
    }
    // 非实体字符，直接追加
    result += str.charAt(i);
    i++;
  }

  return result;
}

function resolveEntity(body: string): string | null {
  if (body.length === 0) {
    return null;
  }

  // 处理数字实体 &#1234; 或 &#x1F600;
  if (body.charAt(0) === '#') {
    if (body.length <= 1) {
      return null;
    }
    const numStr = body.substring(1);
    let code = 0;

    if (body.charAt(1) === 'x' || body.charAt(1) === 'X') {
      if (numStr.length <= 1) {
        return null;
      }
      code = Number.parseInt(numStr.substring(1), 16);
    } else {
      code = Number.parseInt(numStr, 10);
    }

    if (Number.isNaN(code) || code <= 0) {
      return null;
    }
    // fromCodePoint 能正确处理 > 0xFFFF 的 Emoji 等补充平面字符
    return String.fromCodePoint(code);
  }

  // 处理命名实体 &nbsp;
  const val = ENTITY_MAP.get(body);
  return val !== undefined ? val : null;
}

/**
 * Ultra-fast string extraction from HTML attributes.
 *
 * @param str The raw HTML string.
 * @param start The starting index to search from.
 * @param end The ending index to search within.
 * @param attr The attribute name to extract.
 * @returns The extracted string value of the attribute, or an empty string if not found.
 */
export function fastExtractStr(str: string, start: number, end: number, attr: string): string {
  const searchStr = attr + '="';
  let idx = str.indexOf(searchStr, start);
  if (idx === -1 || idx > end) return "";
  idx += searchStr.length;
  const endIdx = str.indexOf('"', idx);
  if (endIdx === -1 || endIdx > end) return "";
  return str.substring(idx, endIdx);
}

/**
 * Ultra-fast number extraction from HTML attributes.
 *
 * @param str The raw HTML string.
 * @param start The starting index to search from.
 * @param end The ending index to search within.
 * @param attr The attribute name to extract.
 * @returns The extracted number value of the attribute, or 0 if not found or invalid.
 */
export function fastParseNum(str: string, start: number, end: number, attr: string): number {
  const searchStr = attr + '="';
  let idx = str.indexOf(searchStr, start);
  if (idx === -1 || idx > end) return 0;
  idx += searchStr.length;
  const endIdx = str.indexOf('"', idx);
  if (endIdx === -1 || endIdx > end) return 0;
  const numStr = str.substring(idx, endIdx);
  const val = parseInt(numStr, 10);
  return isNaN(val) ? 0 : val;
}

/**
 * Context: The Netscape HTML standard requires standard Unix Epoch timestamps (seconds since Jan 1, 1970).
 *
 * Generates the current timestamp for HTML timestamps.
 * Which is basically the current Unix timestamp in seconds.
 */
export function nowHtmlTimestamp(): number {
  return Math.floor(Date.now() / 1000);
}

/**
 * Recursively traverses the bookmark tree and constructs the HTML string representation.
 *
 * @param node The current bookmark node (folder or URL).
 * @param indent The current indentation string, used for human-readable formatting.
 * @returns The HTML string chunk for this node and its children.
 * @author ChatGLM @ Apr 6 2026
 */
export function buildNodeHTML(node: meowBookmarkItem, indent: string): string {
  let result = "";

  if (node.isFolder) {
    const name = encodeHtmlString(node.name);
    const addDate = node.date_added;
    const modDate = node.date_modified;

    // Folder format: <DT><H3> defines the folder, followed by a nested <DL> list.
    result += `${indent}<DT><H3 ADD_DATE="${addDate}" LAST_MODIFIED="${modDate}">${name}</H3>\n`;
    result += `${indent}<DL><p>\n`;

    // Recursively process children with an increased indent (4 spaces per level).
    if (node.children && node.children.length > 0) {
      const childIndent = indent + "    ";
      for (let i = 0; i < node.children.length; i++) {
        result += buildNodeHTML(node.children[i], childIndent);
      }
    }

    result += `${indent}</DL><p>\n`;
  } else {
    // Leaf node format: <DT><A> defines the actual bookmark.
    const name = encodeHtmlString(node.name);
    const url = encodeHtmlString(node.url);
    const addDate = node.date_added;

    result += `${indent}<DT><A HREF="${url}" ADD_DATE="${addDate}">${name}</A>\n`;
  }

  return result;
}
