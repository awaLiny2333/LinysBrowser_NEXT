import { meowBookmarkItem } from "./meowBookmarkItem";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { fileDocumentPick2Path, fileDocumentPickSave, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import lazy { parseBookmarksConcurrent, parseToHTMLConcurrent } from "../scripts/parser";
import lazy { nowHtmlTimestamp } from "../scripts/helpers";
import lazy { isMatchFast, tokenize } from "../../../../catstypicalframework/utils/strings";

export interface MeowBookmarkDragInfo {
  item: meowBookmarkItem;
  parent: meowBookmarkItem;
}

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

  // Look up

  /**
   * Look up bookmarks entries, with no duplicated items.
   * @param query The query word.
   * @param maxResults The maximum number of results to return.
   * @param minHitRate The minimum hit rate to return.
   * @returns The search results.
   * @author CodeGenie in DevEco Studio Preview @ May 7 2026, help refined by DeepSeek Web and awa_Liny itself! :P
   */
  lookUpBookmarksEntries(query: string, maxResults: number, minHitRate = 0.8): meowBookmarkItem[] {
    if (query == '') {
      return [];
    }

    // Tokenize query
    const queryTokens = tokenize(query);

    if (queryTokens.size == 0) {
      return [];
    }

    const addedKeys = new Set<string>();

    // Search
    const results: meowBookmarkItem[] = [];
    const search = (node: meowBookmarkItem) => {
      if (node.isFolder) {
        for (const child of node.children) {
          if (results.length >= maxResults) break;
          search(child);
        }
      } else {
        // Is bookmark
        if (results.length >= maxResults) {
          return; // Enough
        }
        const url = node.url.toLowerCase();
        const title = node.title.toLowerCase();
        const key = `${url}|${title}`;
        if (!addedKeys.has(key) && isMatchFast(key, queryTokens, minHitRate)) {
          results.push(node);
          addedKeys.add(key);
        }
      }
    };
    search(this.root);

    // Limit results
    return results;
  }

  /**
    * Get folder by path.
    * @param path The path. e.g. '/Bookmarks~Meow/New Folder can now be renamed/Bookmarks~Meow/UpSchool'
    * @returns The target meowBookmarkItem, or undefined if not found.
    * @author ChatGLM Web.
    */
  getFolder(path: string): meowBookmarkItem | undefined {
    if (!path || path.length === 0) return undefined;

    let current: meowBookmarkItem = this.root;
    let segStart = -1;
    let isPathStart = true;

    // 遍历路径字符串，手动切割段，避免 split 产生数组分配
    for (let i = 0; i <= path.length; i++) {
      const c = (i < path.length) ? path.charCodeAt(i) : 47; // 47 是 '/'，假装末尾有个 '/' 方便截断最后一段

      if (c === 47) { // 遇到 '/'
        if (segStart !== -1) {
          const segment = path.substring(segStart, i);

          if (isPathStart) {
            // 第一段必须严格等于当前根节点的名字
            if (current.title !== segment) return undefined;
            isPathStart = false;
          } else {
            // 后续段必须在当前节点的 children 里找
            if (!current.isFolder || current.children.length === 0) return undefined;

            let found = false;
            for (let j = 0; j < current.children.length; j++) {
              const child = current.children[j];
              if (child.title === segment) {
                current = child;
                found = true;
                break; // 命中立刻跳出内层循环
              }
            }
            if (!found) return undefined; // 某一级找不到，直接判定路径无效
          }
        }
        segStart = -1;
      } else if (segStart === -1) {
        // 记录非 '/' 字符的起始位置
        segStart = i;
      }
    }

    return current;
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
