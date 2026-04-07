import { fastbuffer, taskpool } from '@kit.ArkTS';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { readArrayBuffer } from '../../../catstypicalframework/utils/storage';
import { meowBookmarkItem } from '../classes/meowBookmarkItem';
import { buildNodeHTML, fastParseNum, fastExtractStr, fastDecode } from './helpers';

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
  let cursor = 0;

  const stack: meowBookmarkItem[] = [rootFolder];

  // --- Predefined ASCII code constants to avoid repeated calculations in loops ---
  const CHAR_LESS = 60; // '<'
  const CHAR_GT = 62; // '>'
  const CHAR_SLASH = 47; // '/'
  const CHAR_D = 68; // 'D'
  const CHAR_T = 84; // 'T'
  const CHAR_H = 72; // 'H'
  const CHAR_L = 76; // 'L'
  const CHAR_3 = 51; // '3'
  const CHAR_A = 65; // 'A'
  const CHAR_SPACE = 32;
  const CHAR_TAB = 9;
  const CHAR_CR = 13; // '\r'

  while (cursor < len) {
    // 1. Find the next newline character
    let nextNL = html.indexOf('\n', cursor);
    if (nextNL === -1) nextNL = len;

    // 2. Handle \r\n (native handling, no new string allocation)
    let lineEnd = nextNL;
    if (lineEnd > cursor && html.charCodeAt(lineEnd - 1) === CHAR_CR) {
      lineEnd--;
    }

    // 3. Manually skip leading spaces (never call trim())
    let start = cursor;
    while (start < lineEnd) {
      const c = html.charCodeAt(start);
      if (c !== CHAR_SPACE && c !== CHAR_TAB) break;
      start++;
    }

    cursor = nextNL + 1; // Move the cursor
    if (start >= lineEnd) continue; // Skip empty line

    // 4. It must start with '<', otherwise it is skipped (blocks 90% of useless lines, zero function calls)
    if (html.charCodeAt(start) !== CHAR_LESS) continue;

    // Branch 1: Match </DL> (hard-coded character comparison)
    // Exit current level folder (pop)
    if (html.charCodeAt(start + 1) === CHAR_SLASH &&
      html.charCodeAt(start + 2) === CHAR_D &&
      html.charCodeAt(start + 3) === CHAR_L) {
      if (stack.length > 1) stack.pop();
      continue;
    }

    // Branch 2: Match <DL> (ignore)
    if (html.charCodeAt(start + 1) === CHAR_D &&
      html.charCodeAt(start + 2) === CHAR_L) {
      continue;
    }

    // Branch 3: Match <DT><H3 (folder)
    // Push the folder and enter the level
    if (html.charCodeAt(start + 1) === CHAR_D &&
      html.charCodeAt(start + 2) === CHAR_T &&
      html.charCodeAt(start + 3) === CHAR_GT &&
      html.charCodeAt(start + 4) === CHAR_LESS &&
      html.charCodeAt(start + 5) === CHAR_H &&
      html.charCodeAt(start + 6) === CHAR_3) {

      const endH3 = html.indexOf('</H3>', start);
      if (endH3 !== -1) {
        // Extract Name: Slice directly based on location
        const nameStart = html.lastIndexOf('>', endH3) + 1;
        const name = fastDecode(html.substring(nameStart, endH3));

        // Extract attribute area: after <DT><H3, before the folder name
        const attrStart = start + 7;
        const attrEnd = nameStart - 1;

        // Directly extract numbers
        const dateAdded = fastParseNum(html, attrStart, attrEnd, 'ADD_DATE');
        const dateModified = fastParseNum(html, attrStart, attrEnd, 'LAST_MODIFIED');

        // Instantiate and push
        const folder = new meowBookmarkItem(true, name, "", dateAdded, dateModified);
        stack[stack.length - 1].children.push(folder);
        stack.push(folder); // Enter new level
      }
      continue;
    }

    // Branch 4: Match <DT><A (bookmark)
    if (html.charCodeAt(start + 1) === CHAR_D &&
      html.charCodeAt(start + 2) === CHAR_T &&
      html.charCodeAt(start + 3) === CHAR_GT &&
      html.charCodeAt(start + 4) === CHAR_LESS &&
      html.charCodeAt(start + 5) === CHAR_A) {

      const endA = html.indexOf('</A>', start);
      if (endA !== -1) {
        const nameStart = html.lastIndexOf('>', endA) + 1;
        const name = fastDecode(html.substring(nameStart, endA));

        const attrStart = start + 6;
        const attrEnd = nameStart - 1;

        // Extract URL
        const url = fastDecode(fastExtractStr(html, attrStart, attrEnd, 'HREF'));
        const dateAdded = fastParseNum(html, attrStart, attrEnd, 'ADD_DATE');

        // Instantiate and push
        const bookmark = new meowBookmarkItem(false, name, url, dateAdded, 0);
        stack[stack.length - 1].children.push(bookmark);
      }
      continue;
    }
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
