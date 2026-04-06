import collections from "@arkts.collections";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { nowHTMLTime } from "../scripts/helpers";

/**
 * meowBookmarkItem is a class that represents a bookmark item.
 * However, due to limitations brought by @Sendable, this class is not observable.
 */
@Sendable
export class meowBookmarkItem {
  isFolder: boolean;
  name: string;
  url: string;
  date_added: number;
  date_modified: number;
  children: collections.Array<meowBookmarkItem> = new collections.Array<meowBookmarkItem>();

  constructor(isFolder: boolean, name: string, url: string, date_added: number, date_modified: number) {
    this.isFolder = isFolder;
    this.name = name;
    this.url = url;
    this.date_added = date_added;
    this.date_modified = date_modified;
  }

  toString(): string {
    return this.name;
  }

  /**
   * Adds a new folder to the children array.
   * @param label The label of the new folder.
   */
  addFolder(label: string) {
    try {
      this.children.push(new meowBookmarkItem(true, label, '', nowHTMLTime(), nowHTMLTime()));
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
      this.children.push(new meowBookmarkItem(false, label, url || '', nowHTMLTime(), nowHTMLTime()));
    } catch (e) {
      meow(`Failed to add folder: ${label}`, 'meowBookmarkItem', meowLevel.ERROR);
    }
  }
}
