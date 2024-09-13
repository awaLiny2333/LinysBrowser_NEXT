import { encode_string_to_html_code } from '../utils/html_tools';
import { ensure_scheme_or_https } from '../utils/url_tools';

export class bookmark {
  private label: string;
  private link: string;
  private add_date: number;

  constructor(label: string, link: string, add_date?: number) {
    let date = new Date();
    this.label = label.replaceAll("/", "／");
    this.link = link;
    this.add_date = add_date !== undefined ? add_date : date.getTime();
  }

  set_label(set: string) {
    this.label = set.replaceAll("/", "／");
  }

  set_link(set: string) {
    this.link = set;
  }

  get_label() {
    return this.label;
  }

  get_link() {
    return this.link;
  }

  get_add_date() {
    return this.add_date;
  }

  get_type() {
    return "bookmark";
  }
}

export class folder {
  // bookmark: bookmark = new bookmark("bilibili","bilibili.com")

  private contents: unified_item[] = [];
  private add_date: number;
  private last_modified: number;
  private label: string;

  constructor(label: string, add_date?: number, last_modified?: number) {
    let date = new Date();
    this.label = label.replaceAll("/", "／");
    this.add_date = add_date !== undefined ? add_date : date.getTime();
    this.last_modified = last_modified !== undefined ? last_modified : date.getTime();
  }

  set_label(set: string) {
    this.label = set.replaceAll("/", "／");
    this.last_modified = (new Date()).getTime();
  }

  get_add_date() {
    return this.add_date;
  }

  get_last_modified() {
    return this.last_modified;
  }

  get_label() {
    return this.label;
  }

  get_type() {
    return "folder";
  }

  add_content(item: unified_item) {
    this.contents.push(item);
  }

  del_content(index: number) {
    this.contents.splice(index, 1);
  }

  get_content() {
    return this.contents as unified_item[];
  }

  print_contents_in_html() {
    let type: string = "";
    let item: bookmark | folder;
    let result: string[] = [];
    result.push("" +
      "<DT><H3 ADD_DATE=\"" + this.add_date.toString() + "\" LAST_MODIFIED=\"" + this.last_modified.toString() + "\">"
      + encode_string_to_html_code(this.label) + "</H3>\n<DL><p>\n"); // Head of folder
    for (let index = 0; index < this.contents.length; index++) {
      item = this.contents[index].get_item();
      type = item.get_type();
      // Get item data
      if (type == "bookmark") {
        item = item as bookmark;
        result.push(
          "<DT><A HREF=\"" + ensure_scheme_or_https(item.get_link()) + "\" ADD_DATE=\"" +
          item.get_add_date().toString() + "\">"
            + encode_string_to_html_code(item.get_label()) + "</A>\n"); // Push bookmark
      } else if (type == "folder") {
        item = item as folder;
        result = result.concat(item.print_contents_in_html());
      }
    }
    result.push("</DL><p>\n\n"); // END of folder
    return result;
  }
}

export class unified_item {
  private bookmark: bookmark | undefined;
  private folder: folder | undefined;

  constructor(bm?: bookmark, fd?: folder) {
    if (bm === undefined && fd === undefined) {
      this.bookmark = new bookmark("Liny's Browser", "https://github.com/awaLiny2333/LinysBrowser_NEXT");
      // If is creating an empty one, then set default
      console.log("[Meow][BunchOfBookmarks][ERROR] Creating an empty unified_item, set default.")
    } else {
      // at least one of them is not undefined
      if (bm !== undefined) {
        this.bookmark = bm;
        // If is packaging a bookmark
      } else if (fd !== undefined) {
        this.folder = fd;
        // If is packaging a folder
      }
    }
  }

  get_item() {
    if (this.bookmark !== undefined) {
      return this.bookmark as bookmark;
    } else {
      return this.folder as folder;
    }
  }
}

export class BunchOfBookmarks {
  root: folder;

  constructor(root_label: string) {
    this.root = new folder(root_label);
  }

  add_bookmark(item: bookmark, path: string) {
    let check_path = "";
    if (path == "") {
      check_path = item.get_label()
    } else {
      check_path = path + "/" + item.get_label()
    }
    if (this.get_bookmark(check_path)) {
      // already exist
      return false;
    } else {
      return this.add_bookmark_process(item, path);
    }
  }

  // add_folder(new folder("honk"),"")
  // add_bookmark(new bookmark("bili","bilibili.com"),"") // adding in the root directory
  // add_bookmark(new bookmark("github","github.com"),"honk") // adding in root/honk directory
  // add_folder(new folder("second"),"honk")
  // add_folder(new folder("third"),"honk/second")
  // add_bookmark(new bookmark("gitee","gitee.com"),"honk/second/third") // adding in root/honk/second/third directory

  add_folder(item: folder, path: string) {
    let check_path = "";
    if (path == "") {
      check_path = item.get_label()
    } else {
      check_path = path + "/" + item.get_label()
    }
    if (this.get_folder(check_path)) {
      // already exist
      return false;
    } else {
      return this.add_folder_process(item, path);
    }
  }

  // add_folder(new folder("honk"),"")
  // add_folder(new folder("second"),"honk")
  // add_folder(new folder("third"),"honk/second")

  get_bookmark(path: string, base_folder?: folder): bookmark | undefined {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    let base_content = base_folder.get_content();

    if (!path.includes("/")) {
      // if at destination folder
      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "bookmark" && item.get_label() == path) {
          return item as bookmark;
        }
      }
      return undefined;
      // not found
    } else {
      let rest_path = path.split("/").slice(1).join("/");
      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          item = item as folder;
          return this.get_bookmark(rest_path, item);
        }
      }
      return undefined;
    }
  }

  // get_bookmark("honk/second/third/gitee") // returns the bookmark with label "gitee"

  get_folder(path: string, base_folder?: folder): folder | undefined {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    let base_content = base_folder.get_content();

    if (!path.includes("/")) {
      // if at destination folder
      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "folder" && item.get_label() == path) {
          return item as folder;
        }
      }
      return undefined;
      // not found
    } else {
      let rest_path = path.split("/").slice(1).join("/");
      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          item = item as folder;
          return this.get_folder(rest_path, item);
        }
      }
      return undefined;
    }
  }

  // get_folder("honk/second/third") // returns the folder with label "third"

  del_bookmark(path: string) {
    if (!this.get_bookmark(path)) {
      // bookmark doesn't exist
      return false;
    }
    return this.delete_bookmark_process(path);
  }

  // del_bookmark("honk/github") // deletes the bookmark with label "github"

  del_folder(path: string) {
    if (!this.get_folder(path)) {
      // folder doesn't exist
      return false;
    }
    return this.delete_folder_process(path);
  }

  // del_folder("honk/second/third") // deletes the folder with label "third"

  export_html() {
    let result: string[] = [];
    let head: string = "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n" +
      "<!-- This is an automatically generated file.\n" +
      "     It will be read and overwritten.\n" +
      "     DO NOT EDIT! -->\n" +
      "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n" +
      "<TITLE>Bookmarks Meow</TITLE>\n" +
      "<H1>Bookmarks Meow</H1>\n" +
      "\n"
    result.push(head);
    result.push("<DL><p>\n")
    result = result.concat(this.root.print_contents_in_html());
    console.log(this.root.print_contents_in_html().join("\n"))
    result.push("</DL><p>\n")
    return result;
  }

  private delete_bookmark_process(path: string, base_folder?: folder): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    if (!path.includes("/")) {
      // Directly delete in this folder
      let dir: unified_item[] = base_folder.get_content();
      let target: number = -1;

      for (let index = 0; index < dir.length; index++) {
        if (dir[index].get_item().get_type() == "bookmark") {
          if (dir[index].get_item().get_label() == path) {
            target = index;
          }
        }
      }
      if (target == -1) {
        return false;
      } else {
        base_folder.del_content(target);
        return true;
      }

    } else {
      // Continue to open
      let rest_path = path.split("/").slice(1).join("/");
      let base_content = base_folder.get_content()

      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          item = item as folder;
          return this.delete_bookmark_process(rest_path, item);
        }
      }
      return false;
      // if next path part is not found in this directory;
    }
  }

  private delete_folder_process(path: string, base_folder?: folder): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    if (!path.includes("/")) {
      // Directly delete in this folder
      let dir: unified_item[] = base_folder.get_content();
      let target: number = -1;

      for (let index = 0; index < dir.length; index++) {
        if (dir[index].get_item().get_type() == "folder") {
          if (dir[index].get_item().get_label() == path) {
            target = index;
          }
        }
      }
      if (target == -1) {
        return false;
      } else {
        base_folder.del_content(target);
        return true;
      }

    } else {
      // Continue to open
      let rest_path = path.split("/").slice(1).join("/");
      let base_content = base_folder.get_content()

      for (let index = 0; index < base_content.length; index++) {
        let item = base_content[index].get_item()
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          item = item as folder;
          return this.delete_folder_process(rest_path, item);
        }
      }
      return false;
      // if next path part is not found in this directory;
    }
  }

  private add_bookmark_process(item: bookmark, path: string, base_folder?: folder): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }
    let this_folder = base_folder.get_content();
    let next_folder = path.split("/")[0];
    let rest_path = "";
    if (path.includes("/")) {
      rest_path = path.split("/").slice(1).join("/");
    }

    if (path == "") {
      // if at root of this base_folder
      base_folder.add_content(new unified_item(item));
      console.log("[Meow][BunchOfBookmarks] Added bookmark [" + item.get_label() + "]!")
      return true;
      // Directly add
    } else {
      // continue to open folders
      for (let index = 0; index < this_folder.length; index++) {
        let checking = this_folder[index].get_item();
        if (checking.get_type() == "folder") {
          if (checking.get_label() == next_folder) {
            return this.add_bookmark_process(item, rest_path, checking as folder);
            // next target found
          }
        }
      }
      return false;
    }
  }

  private add_folder_process(item: folder, path: string, base_folder?: folder): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    let this_folder = base_folder.get_content();
    let next_folder = path.split("/")[0];
    let rest_path = "";
    if (path.includes("/")) {
      rest_path = path.split("/").slice(1).join("/");
    }

    if (path == "") {
      // if at root of this base_folder
      base_folder.add_content(new unified_item(undefined, item));
      console.log("[Meow][BunchOfBookmarks] Added folder [" + item.get_label() + "]!")
      return true;
      // Directly add
    } else {
      // continue to open folders
      for (let index = 0; index < this_folder.length; index++) {
        let checking = this_folder[index].get_item();
        if (checking.get_type() == "folder") {
          if (checking.get_label() == next_folder) {
            return this.add_folder_process(item, rest_path, checking as folder);
            // next target found
          }
        }
      }
      return false;
    }
  }
}
