import { meowBookmarkItem } from "./meowBookmarkItem";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { fileDocumentPick2Path, fileDocumentPickSave, saveHybrid } from "../../../catstypicalframework/utils/storage";
import { parseBookmarksConcurrent, parseToHTMLConcurrent } from "../scripts/parser";
import { nowHtmlTimestamp } from "../scripts/helpers";

@ObservedV2
export class meowBookmarkStash {
  defaultBookmarksPath: string;
  @Trace root: meowBookmarkItem = new meowBookmarkItem(true, 'meow', '', 0, 0);
  @Trace lastImportTimeCost: number = 0;
  @Trace lastSaveTimeCost: number = 0;
  @Trace timeoutIdSaveToDisk: number | undefined;

  constructor(defaultBookmarksPath: string) {
    this.defaultBookmarksPath = defaultBookmarksPath;
  }
  
  // Files

  /**
   * Import bookmarks from HTML file in documents.
   * This would push the imported bookmarks to the root.
   */
  async importHTMLfromDocuments(putIn: meowBookmarkItem = this.root) {
    const result = await fileDocumentPick2Path(['.html'], 1);
    if (!result.succeed) {
      meow(`Failed to pick HTML from documents.`, 'meowBookmarkStash][importHTMLfromDocuments', meowLevel.WARN);
      return false;
    }

    // Parse the HTML file.
    const parseBookmarksResult = await parseBookmarksConcurrent(result.sourcePaths![0]);
    if (!parseBookmarksResult.success) {
      meow(`Failed to parse bookmarks from HTML.`, 'meowBookmarkStash][importHTMLfromDocuments', meowLevel.ERROR);
      return false;
    }

    // Push to root
    this.lastImportTimeCost = parseBookmarksResult.time;
    try {
      putIn.children.push(parseBookmarksResult.root);
      putIn.date_modified = nowHtmlTimestamp();
    } catch (e) {
      meow(`Failed to push root to stash.`, 'meowBookmarkStash][importHTMLfromDocuments', meowLevel.ERROR);
      return false;
    }

    // Save to disk
    this.requestSaveToDisk();
    return true;
  }

  /**
   * Export bookmarks to HTML file in documents.
   * 
   * @param folder The folder to export.
   */
  async exportHTMLtoDocuments(folder: meowBookmarkItem = this.root) {
    const htmlText = await parseToHTMLConcurrent(folder);
    if (!htmlText) {
      meow(`Failed to export HTML to documents. htmlText is empty!`, 'meowBookmarkStash][exportHTMLtoDocuments', meowLevel.WARN);
      return false;
    }
    await fileDocumentPickSave('Bookmarks.html', htmlText);
    return true;
  }
  
  // Internal

  /**
   * Load bookmarks from disk.
   */
  async loadFromDisk() {
    const startTime = Date.now();
    const parseBookmarksResult = await parseBookmarksConcurrent(this.defaultBookmarksPath);

    if (!parseBookmarksResult.success) {
      meow(`Failed to parse bookmarks from HTML. (${Date.now() - startTime} ms)`, 'meowBookmarkStash][loadFromDisk', meowLevel.ERROR);
      return false;
    }

    this.lastImportTimeCost = parseBookmarksResult.time;
    this.root = parseBookmarksResult.root;
    meow(`Successfully loaded bookmarks from disk. (${Date.now() - startTime} ms)`, 'meowBookmarkStash][loadFromDisk', meowLevel.INFO);
    return true;
  }

  /**
   * Save HTML to disk. Has a 500 ms timeout by default.
   * @returns true if success, false if failed.
   */
  requestSaveToDisk(timeout: number = 500) {
    clearTimeout(this.timeoutIdSaveToDisk);
    this.timeoutIdSaveToDisk = setTimeout(async () => {
      this.timeoutIdSaveToDisk = undefined;
      await this.saveToDisk();
    }, timeout);

    meow(`Called requestSaveToDisk. It is expected to save HTML to disk in ${timeout} ms`, 'meowBookmarkStash][requestSaveToDisk', meowLevel.INFO);
    return true;
  }

  /**
   * Save bookmarks to disk.
   */
  private async saveToDisk() {
    const startTime = Date.now();
    const htmlText = await parseToHTMLConcurrent(this.root);
    if (!htmlText) {
      meow(`Failed to export HTML to documents. htmlText is empty!`, 'meowBookmarkStash][exportHTMLtoDocuments', meowLevel.WARN);
      return;
    }
    await saveHybrid(this.defaultBookmarksPath, htmlText, true);
    this.lastSaveTimeCost = Date.now() - startTime;
    meow(`Successfully saved bookmarks to disk. (${Date.now() - startTime} ms)`, 'meowBookmarkStash][saveToDisk', meowLevel.INFO);
  }
}
