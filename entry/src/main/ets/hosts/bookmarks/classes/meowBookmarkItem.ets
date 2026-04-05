import collections from "@arkts.collections";

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
}
