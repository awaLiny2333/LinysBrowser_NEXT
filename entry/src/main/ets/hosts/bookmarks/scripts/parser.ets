import { fastbuffer, taskpool } from '@kit.ArkTS';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { readArrayBuffer } from '../../../catstypicalframework/utils/storage';
import { meowBookmarkItem } from '../classes/meowBookmarkItem';
import { buildNodeHTML, decodeHtmlEntities, extractNumAttr, extractStrAttr } from './helpers';

/**
 * Parse bookmarks from an HTML file (High-Performance Concurrent Version).
 * Uses a cursor-based string scanner to avoid massive memory allocations
 * from string splitting and trimming.
 * 
 * Throws what collections.Array.push() would throw.
 *
 * @param path The path of the HTML file.
 * @returns The root folder of the bookmarks.
 * @author ChatGLM @ Apr 5 2026.
 * 
 * @throws	{ BusinessError } 401 - Parameter error.
 * @throws	{ BusinessError } 10200011 - The push method cannot be bound.
 * @throws	{ BusinessError } 10200201 - Concurrent modification error.
*/
@Concurrent
async function parseBookmarks(path: string): Promise<meowBookmarkItem> {
  const startTime = Date.now();
  const rootFolder = new meowBookmarkItem(true, "meow", "", 0, 0);

  const buffer = await readArrayBuffer(path);
  if (!buffer) {
    meow(`Failed to read bookmarks file. Returning an empty folder.`, 'parser][parseBookmarks', meowLevel.ERROR);
    return rootFolder;
  }

  let htmlString = '';
  try {
    htmlString = fastbuffer.from(buffer).toString();
  } catch (e) {
    meow(`Failed to parse bookmarks from HTML.`, 'parser][parseBookmarks', meowLevel.ERROR);
    return rootFolder;
  }

  const len = htmlString.length;
  let cursor = 0;

  // Prepare the stack. We keep a direct reference to the current parent
  // to avoid frequent array boundary checks in the hot loop.
  const stack: meowBookmarkItem[] = [rootFolder];
  let currentParent = rootFolder;

  while (cursor < len) {
    // 1. Find the next line break
    let nextNewLine = htmlString.indexOf('\n', cursor);
    if (nextNewLine === -1) nextNewLine = len;

    // 2. Handle '\r\n' natively without RegExp replace
    let lineEnd = nextNewLine;
    if (lineEnd > cursor && htmlString.charCodeAt(lineEnd - 1) === 13) { // 13 is '\r'
      lineEnd--;
    }

    // 3. Manual Left-Trim (Skip leading spaces/tabs without allocating a new string)
    let lineStart = cursor;
    while (lineStart < lineEnd) {
      const c = htmlString.charCodeAt(lineStart);
      if (c === 32 || c === 9) { // 32 is ' ', 9 is '\t'
        lineStart++;
      } else {
        break;
      }
    }

    // Move cursor for the next iteration
    cursor = nextNewLine + 1;

    // Skip empty lines
    if (lineStart >= lineEnd) continue;

    // 4. Fast pre-check using charCodeAt (60 is '<').
    // Rejects irrelevant lines instantly without substring allocation.
    if (htmlString.charCodeAt(lineStart) !== 60) continue;

    // Now we allocate a substring ONLY for valid-looking lines
    const line = htmlString.substring(lineStart, lineEnd);

    if (line.startsWith('<DL')) continue;

    if (line.startsWith('</DL>')) {
      if (stack.length > 1) {
        stack.pop();
        currentParent = stack[stack.length - 1];
      }
      continue;
    }

    // 5. Parse Folder: Replace Regex with fast indexOf
    if (line.startsWith('<DT><H3')) {
      const endH3 = line.indexOf('</H3>');
      if (endH3 !== -1) {
        const attrsEnd = line.lastIndexOf('>', endH3);
        const name = decodeHtmlEntities(line.substring(attrsEnd + 1, endH3));
        const attrs = line.substring(8, attrsEnd); // 8 is length of '<DT><H3'

        const dateAdded = extractNumAttr(attrs, 'ADD_DATE');
        const dateModified = extractNumAttr(attrs, 'LAST_MODIFIED');

        const folder = new meowBookmarkItem(true, name, "", dateAdded, dateModified);
        currentParent.children.push(folder);
        stack.push(folder);
        currentParent = folder; // Update reference
      }
      continue;
    }

    // 6. Parse Bookmark: Replace Regex with fast indexOf
    if (line.startsWith('<DT><A')) {
      const endA = line.indexOf('</A>');
      if (endA !== -1) {
        const attrsEnd = line.lastIndexOf('>', endA);
        const name = decodeHtmlEntities(line.substring(attrsEnd + 1, endA));
        const attrs = line.substring(7, attrsEnd); // 7 is length of '<DT><A'

        const url = decodeHtmlEntities(extractStrAttr(attrs, 'HREF'));
        const dateAdded = extractNumAttr(attrs, 'ADD_DATE');

        const bookmark = new meowBookmarkItem(false, name, url, dateAdded, 0);
        currentParent.children.push(bookmark);
      }
      continue;
    }
  }

  meow(`Parsed bookmarks. (${Date.now() - startTime} ms)`, 'bookmarks][parseBookmarks', meowLevel.INFO);

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
