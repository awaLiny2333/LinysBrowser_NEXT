import { meowBookmarkItem } from "../classes/meowBookmarkItem";
/**
 * Extract a number (such as a timestamp) from an HTML attribute string.
 * @param attrString The HTML attribute string to extract from.
 * @param attrName The name of the attribute to extract.
 */
export function extractNumAttr(attrString: string, attrName: string): number {
  const regex = new RegExp(`${attrName}="([^"]*)"`, 'i');
  const match = attrString.match(regex);
  if (match && match[1]) {
    const val = parseInt(match[1], 10);
    return isNaN(val) ? 0 : val;
  }
  return 0;
}

/**
 * Extract a string (such as a URL) from an HTML attribute string.
 * @param attrString The HTML attribute string to extract from.
 * @param attrName The name of the attribute to extract.
 */
export function extractStrAttr(attrString: string, attrName: string): string {
  const regex = new RegExp(`${attrName}="([^"]*)"`, 'i');
  const match = attrString.match(regex);
  return (match && match[1]) ? match[1] : "";
}

/**
 * HTML entity decoder
 * Handle &amp; &lt; &gt; &quot; &#39; etc.
 * @author ChatGLM @ Apr 5 2026.
 */
export function decodeHtmlEntities(text: string): string {
  return text.replace(/&(?:amp|lt|gt|quot|apos|#39|#x27);/gi, (match) => {
    switch (match.toLowerCase()) {
      case '&amp;': return '&';
      case '&lt;': return '<';
      case '&gt;': return '>';
      case '&quot;': return '"';
      case '&apos;':
      case '&#39;':
      case '&#x27;': return "'";
      default: return match;
    }
  });
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

