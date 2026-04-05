import { fastbuffer, taskpool } from '@kit.ArkTS';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { readArrayBuffer, saveHybrid } from '../../../catstypicalframework/utils/storage';
import { meowBookmarkItem } from '../classes/meowBookmarkItem';
import { buildNodeHTML, decodeHtmlEntities, extractNumAttr, extractStrAttr } from './helpers';

/**
 * Parse bookmarks from HTML file.
 *
 * @param path The path of the HTML file.
 * @returns The root folder of the bookmarks.
 * @author ChatGLM @ Apr 5 2026.
 */
@Concurrent
async function parseBookmarks(path: string): Promise<meowBookmarkItem> {
  const rootFolder = new meowBookmarkItem(true, "meow", "", 0, 0);

  const buffer = await readArrayBuffer(path);
  if (!buffer) {
    meow(`Failed to read bookmarks file. Returning an empty folder.`, 'parser][parseBookmarks', meowLevel.ERROR);
    return rootFolder;
  }

  // Read the HTML text file.
  let htmlString = '';
  try {
    htmlString = fastbuffer.from(buffer).toString();
  } catch (e) {
    meow(`Failed to parse bookmarks from HTML.`, 'parser][parseBookmarks', meowLevel.ERROR);
    return rootFolder;
  }

  // Prepare the stack of folders and lines to parse.
  const stack: meowBookmarkItem[] = [rootFolder];
  const lines = htmlString.replace(/\r\n/g, '\n').split('\n');

  for (let i = 0; i < lines.length; i++) {
    let line = lines[i].trim();
    if (!line) continue; // Skip empty lines.

    if (line.startsWith('<DL')) continue; // Ignore.
    if (line.startsWith('</DL')) {
      if (stack.length > 1) stack.pop();
      continue;
    } // Exit that folder level.

    // Match folders.
    const folderRegex = /^<DT><H3([^>]*)>(.*?)<\/H3>$/i;
    const folderMatch = line.match(folderRegex);
    if (folderMatch) {
      const attrs = folderMatch[1];
      const name = decodeHtmlEntities(folderMatch[2]);
      const dateAdded = extractNumAttr(attrs, 'ADD_DATE');
      const dateModified = extractNumAttr(attrs, 'LAST_MODIFIED');
      // Create that folder
      const folder = new meowBookmarkItem(true, name, "", dateAdded, dateModified);
      try {
        stack[stack.length - 1].children.push(folder);
      } catch (e) {
        meow(`Failed to push folder ${name} to stack: ${e}`, 'parser][parseBookmarks', meowLevel.ERROR);
      }
      stack.push(folder);
      continue;
    }

    // Match bookmarks.
    const bookmarkRegex = /^<DT><A([^>]*)>(.*?)<\/A>/i;
    const bookmarkMatch = line.match(bookmarkRegex);
    if (bookmarkMatch) {
      const attrs = bookmarkMatch[1];
      const name = decodeHtmlEntities(bookmarkMatch[2]);
      const url = decodeHtmlEntities(extractStrAttr(attrs, 'HREF'));
      const dateAdded = extractNumAttr(attrs, 'ADD_DATE');
      // Create that bookmark
      const bookmark = new meowBookmarkItem(false, name, url, dateAdded, 0);
      try {
        stack[stack.length - 1].children.push(bookmark);
      } catch (e) {
        meow(`Failed to push bookmark ${name} to stack: ${e}`, 'parser][parseBookmarks', meowLevel.ERROR);
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
 * @param path The path of the bookmarks HTML file.
 */
export async function parseBookmarksConcurrent(path: string) {
  try {
    const startTime = Date.now();
    const rootFolder = await taskpool.execute(new taskpool.Task(parseBookmarks, path)) as meowBookmarkItem;
    meow(`Parsed bookmarks. (${Date.now() - startTime} ms)`, 'bookmarks][parseBookmarks', meowLevel.INFO);
    return { success: true, root: rootFolder, time: Date.now() - startTime } as parseBookmarksResult;
  } catch (e) {
    meow(`Error parsing bookmarks: ${e}`, 'bookmarks][parseBookmarks', meowLevel.ERROR);
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
  const body = buildNodeHTML(item, "    ");

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
    meow(`Exported bookmarks. (${Date.now() - startTime} ms)`, 'bookmarks][exportToHTML', meowLevel.INFO);
    return html;
  } catch (e) {
    meow(`Error exporting bookmarks: ${e}`, 'bookmarks][exportToHTML', meowLevel.ERROR);
    return undefined;
  }
}
