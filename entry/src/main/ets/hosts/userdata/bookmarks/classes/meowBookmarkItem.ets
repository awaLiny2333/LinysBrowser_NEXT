import collections from "@arkts.collections";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { nowHtmlTimestamp } from "../scripts/helpers";

/**
 * meowBookmarkItem is a class that represents a bookmark item.
 * However, due to limitations brought by @Sendable, this class is not observable.
 */
@Sendable
export class meowBookmarkItem {
  isFolder: boolean;
  title: string;
  url: string;
  date_added: number;
  date_modified: number;
  children: collections.Array<meowBookmarkItem> = new collections.Array<meowBookmarkItem>();

  constructor(isFolder: boolean, title: string, url: string, date_added?: number, date_modified?: number) {
    this.isFolder = isFolder;
    this.title = title;
    this.url = url;
    this.date_added = date_added || nowHtmlTimestamp();
    this.date_modified = date_modified || nowHtmlTimestamp();
  }

  /**
   * Creates a shallow copy of the given item.
   * @param item The item to be cloned.
   * @returns A shallow copy of the given item.
   */
  static from(item: meowBookmarkItem) {
    const clone = new meowBookmarkItem(item.isFolder, item.title, item.url, item.date_added, item.date_modified);
    clone.children = item.children;
    return clone;
  }

  toString(): string {
    return this.title;
  }

  /**
   * Adds a new folder to the children array.
   * @param label The label of the new folder.
   */
  addFolder(label: string) {
    try {
      this.children.push(new meowBookmarkItem(true, label, '', nowHtmlTimestamp(), nowHtmlTimestamp()));
    } catch (e) {
      meow(`Failed to add folder: ${label}`, 'meowBookmarkItem', meowLevel.ERROR);
    }
  }

  /**
   * Adds a new bookmark to the children array.
   * @param label The label of the new bookmark.
   * @param url The URL of the new bookmark.
   */
  addBookmark(label: string, url?: string) {
    try {
      this.children.push(new meowBookmarkItem(false, label, url || '', nowHtmlTimestamp(), nowHtmlTimestamp()));
    } catch (e) {
      meow(`Failed to add folder: ${label}`, 'meowBookmarkItem', meowLevel.ERROR);
    }
  }
}
