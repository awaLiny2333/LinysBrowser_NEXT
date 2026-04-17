import lazy { fastbuffer, taskpool } from '@kit.ArkTS';
import lazy { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import lazy { readArrayBuffer } from '../../../../catstypicalframework/utils/storage';
import lazy { meowBookmarkItem } from '../classes/meowBookmarkItem';
import lazy { buildNodeHTML, fastParseNum, fastExtractStr, decodeHtmlString } from './helpers';

/**
 * Parse bookmarks from an HTML file (High-Performance Concurrent Version).
 * Uses a cursor-based string scanner to avoid massive memory allocations
 * from string splitting and trimming.
 *
 * Throws what collections.Array.push() would throw.
 *
 * @param path The path of the HTML file.
 * @returns The root folder of the bookmarks.
 * @author ChatGLM @ Apr 6 2026.
 *
 * @throws	{ BusinessError } 401 - Parameter error.
 * @throws	{ BusinessError } 10200011 - The push method cannot be bound.
 * @throws	{ BusinessError } 10200201 - Concurrent modification error.
*/
@Concurrent
async function parseBookmarks(path: string): Promise<meowBookmarkItem> {
  const rootFolder = new meowBookmarkItem(true, "meow", "", 0, 0);
  const buffer = await readArrayBuffer(path);
  if (!buffer) return rootFolder;

  const html = fastbuffer.from(buffer).toString();
  const len = html.length;
  const stack: meowBookmarkItem[] = [rootFolder];

  // Keep hard-coded ASCII for ultimate speed
  // const CHAR_LESS = 60; // '<'
  const CHAR_SLASH = 47; // '/'
  const CHAR_D = 68; // 'D'
  const CHAR_L = 76; // 'L'
  const CHAR_H = 72; // 'H'
  const CHAR_3 = 51; // '3'
  const CHAR_A = 65; // 'A'
  const CHAR_GT = 62; // '>'

  let cursor = 0;

  while (cursor < len) {
    // 1. Brainlessly search for the next '<', regardless of what the preceding line break, space, or garbage is
    let nextTag = html.indexOf('<', cursor);
    if (nextTag === -1) break; // End of file

    // Boundary maintenance
    if (nextTag + 4 >= len) {
      cursor = nextTag + 1;
      continue;
    }

    const c1 = html.charCodeAt(nextTag + 1);
    const c2 = html.charCodeAt(nextTag + 2);

    // Anchor 1: Match </DL> (Exit current level)
    if (c1 === CHAR_SLASH &&
      c2 === CHAR_D &&
      html.charCodeAt(nextTag + 3) === CHAR_L &&
      html.charCodeAt(nextTag + 4) === CHAR_GT) {
      if (stack.length > 1) stack.pop();
      cursor = nextTag + 5;
      continue;
    }

    // Anchor 2: Match </H3> (Extract folder name and attributes)
    if (c1 === CHAR_SLASH &&
      c2 === CHAR_H &&
      html.charCodeAt(nextTag + 3) === CHAR_3 &&
      html.charCodeAt(nextTag + 4) === CHAR_GT) {

      const closePos = nextTag;

      // A stroke of genius: use lastIndexOf to find the starting '>' of the name.
      // Ignore any line breaks or <DT> tags, and precisely locate
      const nameStart = html.lastIndexOf('>', closePos - 1) + 1;
      const name = decodeHtmlString(html.substring(nameStart, closePos));

      // Continue searching backward to find the start position of the <H3 tag and extract the attribute area.
      const h3OpenPos = html.lastIndexOf('<H3', nameStart - 1);
      if (h3OpenPos !== -1) {
        const attrStart = h3OpenPos + 3; // Skip '<H3'
        const attrEnd = nameStart - 1;

        const dateAdded = fastParseNum(html, attrStart, attrEnd, 'ADD_DATE');
        const dateModified = fastParseNum(html, attrStart, attrEnd, 'LAST_MODIFIED');

        const folder = new meowBookmarkItem(true, name, "", dateAdded, dateModified);
        stack[stack.length - 1].children.push(folder);
        stack.push(folder); // Enter next folder level
      }

      cursor = closePos + 5;
      continue;
    }

    // Anchor 3: Match </A> (Extract bookmark name and attributes)
    if (c1 === CHAR_SLASH &&
      c2 === CHAR_A &&
      html.charCodeAt(nextTag + 3) === CHAR_GT) {

      const closePos = nextTag;

      const nameStart = html.lastIndexOf('>', closePos - 1) + 1;
      // Handle names containing '<' (e.g., Price < $5)
      const name = decodeHtmlString(html.substring(nameStart, closePos));

      const aOpenPos = html.lastIndexOf('<A', nameStart - 1);
      if (aOpenPos !== -1) {
        const attrStart = aOpenPos + 2; // Skip '<A'
        const attrEnd = nameStart - 1;

        const url = decodeHtmlString(fastExtractStr(html, attrStart, attrEnd, 'HREF'));
        const dateAdded = fastParseNum(html, attrStart, attrEnd, 'ADD_DATE');

        const bookmark = new meowBookmarkItem(false, name, url, dateAdded, 0);
        stack[stack.length - 1].children.push(bookmark);
      }

      cursor = closePos + 4;
      continue;
    }

    // It is not the ending tag we want, indicating it is a junk tag like <DL>, <DT>, or <p>, so skip this '<'.
    cursor = nextTag + 1;
  }

  return rootFolder;
}

export interface parseBookmarksResult {
  success: boolean;
  root: meowBookmarkItem;
  time: number;
}

/**
 * Parse bookmarks concurrently and returns the collections.Array<meowBookmarkItem>.
 * If the HTML has only one folder, that folder will be used as the root.
 * @param path The path of the bookmarks HTML file.
 */
export async function parseBookmarksConcurrent(path: string) {
  try {
    const startTime = Date.now();
    let rootFolder = await taskpool.execute(new taskpool.Task(parseBookmarks, path)) as meowBookmarkItem;
    meow(`Parsed bookmarks. (${Date.now() - startTime} ms)`, 'bookmarks][parseBookmarksConcurrent', meowLevel.INFO);

    // If the root has only one child, then use that child as root.
    if (rootFolder.children.length == 1) {
      rootFolder = rootFolder.children[0];
    }

    return { success: true, root: rootFolder, time: Date.now() - startTime } as parseBookmarksResult;
  } catch (e) {
    meow(`Error parsing bookmarks: ${e}`, 'bookmarks][parseBookmarksConcurrent', meowLevel.ERROR);
    return { success: false, root: new meowBookmarkItem(true, "meow", "", 0, 0), time: 0 } as parseBookmarksResult;
  }
}

/**
 * Exports a bookmark tree to a standard Netscape Bookmark File Format HTML string.
 * This format is universally recognized by Chrome, Firefox, Safari, and Edge.
 *
 * @param item The root node of the bookmark tree to export.
 * @returns A Promise resolving to the complete, well-formatted HTML string.
 * @author ChatGLM @ Apr 6 2026
 */
@Concurrent
function exportToHTML(item: meowBookmarkItem) {
  // The standard DOCTYPE and meta tags are mandatory. Browsers use these headers
  // to identify the file as a valid bookmark import, rather than a generic webpage.
  const header = `<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
`;

  // Generate the body recursively. Start with a standard 4-space indent.
  const body = buildNodeHTML(item, '    ');

  // The Netscape format strictly requires a closing </DL><p> at the root level.
  // Missing the trailing <p> can sometimes cause parsing quirks in certain browsers.
  const footer = `</DL><p>\n`;

  return header + body + footer;
}

/**
 * Exports the meowBookmarkItem to HTML text.
 * @param item The meowBookmarkItem.
 */
export async function parseToHTMLConcurrent(item: meowBookmarkItem) {
  try {
    const startTime = Date.now();
    const html = await taskpool.execute(new taskpool.Task(exportToHTML, item)) as string;
    meow(`Exported bookmarks. (${Date.now() - startTime} ms)`, 'bookmarks][parseToHTMLConcurrent', meowLevel.INFO);
    return html;
  } catch (e) {
    meow(`Error exporting bookmarks: ${e}`, 'bookmarks][parseToHTMLConcurrent', meowLevel.ERROR);
    return undefined;
  }
}
