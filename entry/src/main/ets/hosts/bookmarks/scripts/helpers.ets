import { meowBookmarkItem } from "../classes/meowBookmarkItem";

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
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;') // Double quotes must be escaped to avoid breaking HREF="..."
    .replace(/'/g, '&#39;'); // Single quotes escaped for strict XHTML compatibility
}

/**
 * Ultra-fast HTML entity decoding (ArkTS Strict compatible version)
 * 
 * @param str The raw HTML string.
 * @returns The decoded string.
 * @author ChatGLM @ Apr 6 2026
 */
export function decodeHtmlString(str: string): string {
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
