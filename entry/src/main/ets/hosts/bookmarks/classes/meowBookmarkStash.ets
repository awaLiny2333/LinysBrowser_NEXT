import { meowBookmarkItem } from "./meowBookmarkItem";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { fileCopy, fileDocumentPick2Path, fileDocumentPickSave, saveHybrid } from "../../../catstypicalframework/utils/storage";
import { parseBookmarksConcurrent, parseToHTMLConcurrent } from "../scripts/parser";

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

  /**
   * Import bookmarks from HTML file in documents.
   */
  async importHTMLfromDocuments() {
    const result = await fileDocumentPick2Path(['.html'], 1);
    if (!result.succeed) {
      meow(`Failed to pick HTML from documents.`, 'meowBookmarkStash][importHTMLfromDocuments', meowLevel.WARN);
      return;
    }
    const path = result.sourcePaths![0];
    await fileCopy(path, this.defaultBookmarksPath, true);
    const parseBookmarksResult = await parseBookmarksConcurrent(this.defaultBookmarksPath);

    if (!parseBookmarksResult.success) {
      meow(`Failed to parse bookmarks from HTML.`, 'meowBookmarkStash][importHTMLfromDocuments', meowLevel.ERROR);
      return;
    }

    this.lastImportTimeCost = parseBookmarksResult.time;
    this.root = parseBookmarksResult.root;
  }

  async exportHTMLtoDocuments() {
    const htmlText = await parseToHTMLConcurrent(this.root);
    if (!htmlText) {
      meow(`Failed to export HTML to documents. htmlText is empty!`, 'meowBookmarkStash][exportHTMLtoDocuments', meowLevel.WARN);
      return;
    }
    await fileDocumentPickSave('Bookmarks.html', htmlText);
  }

  /**
   * Load bookmarks from disk.
   */
  async loadFromDisk() {
    const startTime = Date.now();
    const parseBookmarksResult = await parseBookmarksConcurrent(this.defaultBookmarksPath);

    if (!parseBookmarksResult.success) {
      meow(`Failed to parse bookmarks from HTML. (${Date.now() - startTime} ms)`, 'meowBookmarkStash][loadFromDisk', meowLevel.ERROR);
      return;
    }

    this.lastImportTimeCost = parseBookmarksResult.time;
    if (parseBookmarksResult.root.children.length == 1) {
      this.root = parseBookmarksResult.root.children[0];
    } else {
      this.root = parseBookmarksResult.root;
    }
    meow(`Successfully loaded bookmarks from disk. (${Date.now() - startTime} ms)`, 'meowBookmarkStash][loadFromDisk', meowLevel.INFO);
  }

  /**
   * Save bookmarks to disk.
   */
  async saveToDisk() {
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
}
