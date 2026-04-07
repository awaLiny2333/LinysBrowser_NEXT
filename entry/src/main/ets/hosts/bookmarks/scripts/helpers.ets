import { meowBookmarkItem } from "../classes/meowBookmarkItem";

/**
 * Ultra-fast HTML entity decoding (ArkTS Strict compatible version)
 */
export function fastDecode(str: string): string {
  // 1. Instant short circuit: If there is no '&' symbol, then no need to replace.
  // Return directly as is (intercept 99.9% of calls)
  if (str.indexOf('&') === -1) {
    return str;
  }

  // 2. Handling when an entity is hit: Use native string replacement.
  // Directly replace with hard-code.
  // Although intermediate strings are generated, the actual bookmark label usually contains at most 1-2 entities.
  // This kind of native string replacement at the C++ level is much faster than starting a regular expression engine.
  let result = str;
  result = result.replace('&amp;', '&');
  result = result.replace('&lt;', '<');
  result = result.replace('&gt;', '>');
  result = result.replace('&quot;', '"');
  result = result.replace('&#39;', "'");

  return result;
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
 * Escapes special characters to prevent HTML injection and structural breakage.
 *
 * ⚠️ CRITICAL: The ampersand (&) MUST be replaced first. If we replace '<' with '&lt;'
 * first, the subsequent '&' replacement would corrupt it into '&amp;lt;'.
 *
 * @param text The raw string (bookmark name or URL).
 * @returns The safely escaped string.
 * @author ChatGLM @ Apr 6 2026
 */
function encodeHtmlEntities(text: string): string {
  if (!text) return "";
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;') // Double quotes must be escaped to avoid breaking HREF="..."
    .replace(/'/g, '&#39;'); // Single quotes escaped for strict XHTML compatibility
}

/**
 * Converts internal timestamp formats to the standard Netscape HTML timestamp.
 *
 * Context: Chrome's internal JSON (`Bookmarks` file) stores timestamps as
 * Windows FILETIME (microseconds since Jan 1, 1601). However, the Netscape
 * HTML standard requires standard Unix Epoch timestamps (seconds since Jan 1, 1970).
 *
 * This function includes a heuristic check: if the number is unreasonably large
 * (> 10^10, which corresponds to Sept 9, 2001 in seconds), it assumes the value
 * is in microseconds and safely divides it down to seconds.
 *
 * @param microTimestamp The raw timestamp value from the data model.
 * @returns A Unix timestamp in seconds, safe for HTML export.
 * @author ChatGLM @ Apr 6 2026
 */
function toHtmlTimestamp(microTimestamp: number): number {
  if (!microTimestamp) return 0;

  // 10_000_000_000 corresponds to year 2286 in seconds, but year 1970 + micros.
  if (microTimestamp > 10000000000) {
    return Math.floor(microTimestamp / 1000000);
  }

  // Fallback in case the timestamp was already parsed to seconds previously.
  return microTimestamp;
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
    const name = encodeHtmlEntities(node.name);
    const addDate = toHtmlTimestamp(node.date_added);
    const modDate = toHtmlTimestamp(node.date_modified);

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
    const name = encodeHtmlEntities(node.name);
    const url = encodeHtmlEntities(node.url);
    const addDate = toHtmlTimestamp(node.date_added);

    result += `${indent}<DT><A HREF="${url}" ADD_DATE="${addDate}">${name}</A>\n`;
  }

  return result;
}

/**
 * Generates the current timestamp for HTML timestamps.
 * Which is basically the current Unix timestamp in seconds.
 */
export function nowHTMLTime(): number {
  return Math.floor(Date.now() / 1000);
}
