import { decode_html_code_to_string, encode_string_to_html_code } from '../utils/html_tools';
import { ensure_scheme } from '../utils/url_tools';
import { collections } from '@kit.ArkTS';

@Sendable
export class bunch_of_bookmarks {
  root: bookmark;
  last_accessed: number = 0;
  init: boolean = false;
  cached_plain_bookmarks: collections.Array<collections.Array<string>> | undefined = undefined;
  // Temp
  private last_add_path: string | undefined = undefined;
  private last_add_path_bookmark: bookmark | undefined = undefined;

  /**
   * A class holding a root folder, in which there stores bookmarks and folders.
   * @param root_label The label of root folder.
   */
  constructor(root_label: string) {
    this.root = new bookmark(root_label, '', undefined, undefined, true);
  }

  /**
   * Reconstruct plain bookmarks and store in a cache array as a member variable of this bunch_of_bookmarks.
   * @summary So that requests can be satisfied with this cached data in stead of another reconstruction which
   * consumes another a lot of performance and time.
   * */
  reconstruct_cached_plain_bookmarks() {
    let t0 = Date.now();
    this.cached_plain_bookmarks = this.root.get_plain_bookmarks();
    console.log(`[bunch_of_bookmarks][plain_bookmarks] Reconstructed plain bookmarks! length: ${this.cached_plain_bookmarks.length} (Used ${(Date.now() - t0)} ms)`);
  }

  /**
   * Adds a bookmark to this bunch_of_bookmarks.
   * @param item A bookmark object.
   * @param path A string, technically the path of the folder which the bookmark item will be put into.
   * @param no_reconstruct_plain_bookmarks A boolean, will not reconstruct the plain bookmarks array if set true,
   * otherwise (unfilled or set false) will reconstruct the plain bookmarks array.
   * @returns true if success.
   * @returns false if failed (for a name crash or a nonexistent destination).
   * */
  add_bookmark(item: bookmark, path: string, no_reconstruct_plain_bookmarks?: boolean) {
    let check_path = "";
    if (path == "") {
      check_path = item.get_label()
    } else {
      check_path = path + "/" + item.get_label()
    }

    // Add
    let add_result: boolean;
    if (this.access_bookmark(check_path)) {
      // already exist
      return false;
    } else {
      if (this.last_add_path == path && this.last_add_path_bookmark) {
        // Direct add in cached bookmark
        this.last_add_path_bookmark.add_content(item);
        // console.log('[bunch_of_bookmarks][add_bookmark] Hit Cache!');
        add_result = true;
      } else {
        add_result = this.add_bookmark_process(item, path);
        this.last_add_path = path;
      }
    }

    if (no_reconstruct_plain_bookmarks) {
      return add_result;
    }
    // Update plain_bookmarks
    this.reconstruct_cached_plain_bookmarks();
    if (this.init) {
      this.last_accessed = Date.now();
    }
    return add_result;
  }

  /**
   * Adds a folder to this bunch_of_bookmarks.
   * @param item A folder object.
   * @param path A string, technically the path of the folder which the bookmark item will be put into.
   * @param no_reconstruct_plain_bookmarks A boolean, will not reconstruct the plain bookmarks array if set true,
   * otherwise (unfilled or set false) will reconstruct the plain bookmarks array.
   * @returns true if success.
   * @returns false if failed (for a name crash or a nonexistent destination).
   * */
  add_folder(item: bookmark, path: string, no_reconstruct_plain_bookmarks?: boolean) {
    let check_path = "";
    if (path == "") {
      check_path = item.get_label()
    } else {
      check_path = path + "/" + item.get_label()
    }

    // Add
    let add_result: boolean;
    if (this.access_folder(check_path)) {
      // already exist
      add_result = false;
    } else {
      if (this.last_add_path == path && this.last_add_path_bookmark) {
        // Direct add in cached bookmark
        this.last_add_path_bookmark.add_content(item);
        // console.log('[bunch_of_bookmarks][add_folder] Hit Cache!');
        add_result = true;
      } else {
        add_result = this.add_folder_process(item, path);
        this.last_add_path = path;
      }
    }

    if (no_reconstruct_plain_bookmarks) {
      return add_result;
    }
    // Update plain_bookmarks
    this.reconstruct_cached_plain_bookmarks();
    if (this.init) {
      this.last_accessed = Date.now();
    }
    return add_result;
  }

  access_bookmark(path: string): boolean {
    let access_result = this.access(path, 'bookmark');
    if (access_result == true) {
      return true;
    } else if (access_result == false) {
      return false;
    } else {
      return this.get_bookmark(path) ? true : false;
    }
  }

  access_folder(path: string): boolean {
    let access_result = this.access(path, 'folder');
    if (access_result == true) {
      return true;
    } else if (access_result == false) {
      return false;
    } else {
      return this.get_folder(path) ? true : false;
    }
  }

  get_bookmark(path: string, base_folder?: bookmark): bookmark | undefined {
    // Basic idea:
    // Will recursively open folders and sub folders, until the path is chopped down to a single level.
    // Then just pick the bookmark requested.

    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    let base_content = base_folder.get_content();

    if (!path.includes("/")) {
      // if at destination folder
      for (let index = 0; index < base_content.length; index++) {
        // Temporarily get the item
        let item = base_content[index];
        if (item.get_type() == "bookmark" && item.get_label() == path) {
          return item as bookmark;
        }
      }
      // not found
      return undefined;
    } else {
      let rest_path = path.split("/").slice(1).join("/");
      let next_folder_label = path.split("/")[0];
      for (let index = 0; index < base_content.length; index++) {
        // Temporarily get the item
        let item = base_content[index];
        if (item.get_type() == "folder" && item.get_label() == next_folder_label) {
          return this.get_bookmark(rest_path, item);
        }
      }
      // not found
      return undefined;
    }
  }

  get_folder(path: string, base_folder?: bookmark): bookmark | undefined {
    // Basic idea:
    // Will recursively open folders and sub folders, until the path is chopped down to a single level.
    // Then just pick the folder requested.

    if (path == '/') {
      return undefined;
    }

    if (path == '') {
      return this.root;
    }

    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    let base_content = base_folder.get_content();

    if (!path.includes("/")) {
      // if at destination folder
      for (let index = 0; index < base_content.length; index++) {
        // Temporarily get the item
        let item = base_content[index];
        if (item.get_type() == "folder" && item.get_label() == path) {
          return item;
        }
      }
      // not found
      return undefined;
    } else {
      let rest_path = path.split("/").slice(1).join("/");
      for (let index = 0; index < base_content.length; index++) {
        // Temporarily get the item
        let item = base_content[index];
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          return this.get_folder(rest_path, item);
        }
      }
      return undefined;
    }
  }

  del_bookmark(path: string) {
    if (!this.get_bookmark(path)) {
      // bookmark doesn't exist
      return false;
    }
    let delete_result = this.delete_bookmark_process(path);

    // Update plain_bookmarks
    this.reconstruct_cached_plain_bookmarks();
    this.last_accessed = Date.now();
    return delete_result;
  }

  del_folder(path: string) {
    if (!this.get_folder(path)) {
      // folder doesn't exist
      return false;
    }
    let delete_result = this.delete_folder_process(path);

    // Update plain_bookmarks
    this.reconstruct_cached_plain_bookmarks();
    this.last_accessed = Date.now();
    return delete_result;
  }

  /**
   * Moves a bookmark to another directory
   * @param bookmark_path directory of bookmark to be moved
   * @param to_path directory of destination
   * @returns 0 if success
   * @returns 1 if no bookmark selected
   * @returns 2 if name crash
   * */
  move_bookmark(bookmark_path: string, to_path: string) {
    if (bookmark_path == "") {
      console.log("[ERROR][Meow][bunch_of_bookmarks] Empty bookmark_path!")
      return 1;
    }
    // Get objects
    let item_bookmark = this.get_bookmark(bookmark_path);
    let target_folder: bookmark | undefined;
    if (to_path == "") {
      target_folder = this.root;
    } else {
      target_folder = this.get_folder(to_path);
    }

    // If Objects got
    if (item_bookmark && target_folder) {
      // Check name crash
      let check_path = "";
      if (to_path == "") {
        check_path = item_bookmark.get_label()
      } else {
        check_path = to_path + "/" + item_bookmark.get_label()
      }
      if (this.get_bookmark(check_path)) {
        // name crash
        console.log("[ERROR][Meow][bunch_of_bookmarks] Duplicate bookmark name @ \"" + check_path + "\"!")
        return 2;
      }
      // All OK
      target_folder.add_content(item_bookmark);
      this.del_bookmark(bookmark_path);
    }
    this.last_accessed = Date.now();
    return 0;
  }

  /**
   * Moves a folder to another directory
   * @param folder_path directory of folder to be moved
   * @param to_path directory of destination
   * @returns 0 if success
   * @returns 1 if no folder selected
   * @returns 2 if name crash
   * @returns 3 if moving a folder to its sub folder
   * */
  move_folder(folder_path: string, to_path: string) {
    if (folder_path == "") {
      console.log("[ERROR][Meow][bunch_of_bookmarks] Empty folder_path!")
      return 1;
    }
    if (to_path.indexOf(folder_path) == 0) {
      console.log("[ERROR][bunch_of_bookmarks] Cannot move myself to my sub folder!")
      return 3;
    }

    // Get objects
    let item_folder = this.get_folder(folder_path);
    let target_folder: bookmark | undefined;
    if (to_path == "") {
      target_folder = this.root;
    } else {
      target_folder = this.get_folder(to_path);
    }

    // If Objects got
    if (item_folder && target_folder) {
      // Check name crash
      let check_path = "";
      if (to_path == "") {
        check_path = item_folder.get_label()
      } else {
        check_path = to_path + "/" + item_folder.get_label()
      }
      if (this.get_folder(check_path)) {
        // name crash
        console.log("[ERROR][Meow][bunch_of_bookmarks] Duplicate folder name @ \"" + check_path + "\"!")
        return 2;
      }
      // All OK
      target_folder.add_content(item_folder);
      this.del_folder(folder_path);
    }
    this.last_accessed = Date.now();
    return 0;
  }

  /**
   * Get the encoded HTML text of the whole bunch_of_bookmark.
   * @returns A string[] array, each element refers to a line after .join("\n").
   * */
  get_export_html() {
    let result: string[] = [];
    let head: string = "<!DOCTYPE NETSCAPE-bookmark-file-1>\n" +
      "<!-- This is an automatically generated file.\n" +
      "     It will be read and overwritten.\n" +
      "     DO NOT EDIT! -->\n" +
      "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n" +
      "<TITLE>bookmarks Meow</TITLE>\n" +
      "<H1>bookmarks Meow</H1>\n"
    result.push(head);
    result.push("<!-- Meow, Meow, Meow -->\n");
    result.push("<DL><p>");
    result = result.concat(this.root.get_contents_in_html(0));
    result.push("</DL><p>");
    return result;
  }

  /**
   * Imports HTML format bookmarks to bunch_of_bookmarks, allowing to either overwrite totally or add to root.
   *
   * If overwrite is set true then removes whatever was previously in this bunch_of_bookmarks.
   * @param html The string of .html format bookmarks.
   * @param overwrite Set false in default.
   * @returns -1 for no <H3> error.
   * @returns 0 for SUCCESS.
   * @returns 1 for no label.
   * @returns 2 for no link.
   * @returns 3 for add_folder method fail (Perhaps because label collision).
   * */
  import_html(html: string, overwrite?: boolean) {
    let t0 = Date.now();

    let overwrite_data = false;
    if (overwrite !== undefined) {
      overwrite_data = overwrite;
    }
    // Set overwrite options

    // let one_line_data: string = html.replace(/\s*\n+\s*/g, "") // Eliminate all returns
    // one_line_data = one_line_data.replace(/<p>/g, "") // Eliminate all <p>
    // one_line_data = one_line_data.replace(/<DT>/g, "") // Eliminate all <DT>
    // one_line_data = one_line_data.replace(/<DL>/g, "") // Eliminate all <DL>
    // one_line_data = one_line_data.replace(/<\/A>/g, "") // Eliminate all </A>
    // one_line_data = one_line_data.replace(/<\/H3>/g, "") // Eliminate all </H3>

    let one_line_data: string = html.replace(/<p>|<DT>|<DL>|<\/A>|<\/H3>|\s*\n+\s*/g, '');
    one_line_data = one_line_data.replace(/</g, "\n<") // Put returns

    let first_H3 = one_line_data.indexOf("<H3");
    if (first_H3 == -1) {
      return -1; // -1 for no <H3> error
    }

    one_line_data = one_line_data.substring(first_H3);
    let lines_split = one_line_data.split("\n");
    // Split Into lines

    let new_bunch_of_bookmarks_label = new Date().toLocaleString();
    let new_bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks(new_bunch_of_bookmarks_label);
    let now_path_stack: string[] = [];
    // Set new bookmarks bundle

    for (let index = 0; index < lines_split.length; index++) {
      let line = lines_split[index]; // For each line

      if (line.length == 0) {
        // Skip empty lines
        continue;
      }

      let now_path_string = now_path_stack.join("/");
      // Connect now path

      let position_of_label = line.indexOf(">");
      if (position_of_label == -1) {
        return 1; // 1 for no label error
      }

      let label = line.substring(position_of_label + 1);
      label = decode_html_code_to_string(label);
      // Extract Label

      let add_date = Number.parseInt(this.import_html_get_key("ADD_DATE=\"", line));
      let last_modified = Number.parseInt(this.import_html_get_key("LAST_MODIFIED=\"", line));
      if (last_modified == Number.NaN) {
        // No last_modified value, set new default
        last_modified = Math.round(new Date().getTime() / 1000)
      }
      // Extract dates

      if (line.includes("<H3 ")) {
        // is a folder
        new_bunch_of_bookmarks.add_folder(new bookmark(label, '', add_date, last_modified, true), now_path_string, true);
        now_path_stack.push(label)

      } else if (line.includes("<A HREF=\"")) {
        // is a bookmark
        let link = this.import_html_get_key("<A HREF=\"", line);
        if (link == "") {
          return 2; // 2 for empty link error
        }
        new_bunch_of_bookmarks.add_bookmark(new bookmark(label, link, add_date), now_path_string, true);

      } else if (line.includes("</DL>")) {
        // is a closing mark
        now_path_stack.pop();
        // go back to upper class folder
      }
    }

    let final_add_result = false;
    if (overwrite_data) {
      let root_contents: bookmark = new_bunch_of_bookmarks.root.get_content()[0];
      this.root = root_contents;
    } else {
      final_add_result = this.add_folder(new_bunch_of_bookmarks.root, "", true) as boolean;
    }

    // Update plain_bookmarks
    this.reconstruct_cached_plain_bookmarks();

    console.log(`[bunch_of_bookmarks][import_html] OK! (${(Date.now() - t0)} ms)`);

    if (final_add_result) {
      this.last_accessed = Date.now();
      return 0; // 0 for a successful import
    } else {
      return 3; // 3 for add_folder errors
    }
  }

  /**
   * Get the plain label link array from the cached array.
   * @returns A string[][] array, cached_plain_bookmarks, which consists of plain label and link pairs.
   * @example [['bing', 'www.bing.com'], ['loading', 'www.google.com']]
   * */
  get_all_plain_label_link(): collections.Array<collections.Array<string>> {
    if (!this.cached_plain_bookmarks) {
      this.reconstruct_cached_plain_bookmarks();
    }
    return this.cached_plain_bookmarks as collections.Array<collections.Array<string>>;
  }

  private import_html_get_key(key: string, from: string) {
    let start: number = from.indexOf(key) + key.length;
    let end: number = from.length;
    if (start == -1) {
      return "";
    }
    for (let index = start; index < from.length; index++) {
      if (from[index] == "\"") {
        end = index;
        break;
      }
    }
    return from.substring(start, end);
  }

  private delete_bookmark_process(path: string, base_folder?: bookmark): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    if (!path.includes("/")) {
      // Directly delete in this folder
      let dir: collections.Array<bookmark> = base_folder.get_content();
      let target: number = -1;

      for (let index = 0; index < dir.length; index++) {
        if (dir[index].get_type() == "bookmark") {
          if (dir[index].get_label() == path) {
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
        let item = base_content[index];
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          return this.delete_bookmark_process(rest_path, item);
        }
      }
      return false;
      // if next path part is not found in this directory;
    }
  }

  private delete_folder_process(path: string, base_folder?: bookmark): boolean {
    if (base_folder === undefined) {
      base_folder = this.root;
      // use root as default;
    }

    if (!path.includes("/")) {
      // Directly delete in this folder
      let dir: collections.Array<bookmark> = base_folder.get_content();
      let target: number = -1;

      for (let index = 0; index < dir.length; index++) {
        if (dir[index].get_type() == "folder") {
          if (dir[index].get_label() == path) {
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
        let item = base_content[index];
        if (item.get_type() == "folder" && item.get_label() == path.split("/")[0]) {
          return this.delete_folder_process(rest_path, item);
        }
      }
      return false;
      // if next path part is not found in this directory;
    }
  }

  private add_bookmark_process(item: bookmark, path: string, base_folder?: bookmark): boolean {
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
      base_folder.add_content(item);
      this.last_add_path_bookmark = base_folder;
      // console.log("[Meow][BunchOfbookmarks] Added bookmark [" + item.get_label() + "]!")
      return true;
      // Directly add
    } else {
      // continue to open folders
      for (let index = 0; index < this_folder.length; index++) {
        let checking = this_folder[index];
        if (checking.get_type() == "folder") {
          if (checking.get_label() == next_folder) {
            return this.add_bookmark_process(item, rest_path, checking);
            // next target found
          }
        }
      }
      // If target folder not found
      return false;
    }
  }

  private add_folder_process(item: bookmark, path: string, base_folder?: bookmark): boolean {
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
      base_folder.add_content(item);
      this.last_add_path_bookmark = base_folder;
      // console.log("[Meow][BunchOfbookmarks] Added folder [" + item.get_label() + "]!")
      return true;
      // Directly add
    } else {
      // continue to open folders
      for (let index = 0; index < this_folder.length; index++) {
        let checking = this_folder[index];
        if (checking.get_type() == "folder") {
          if (checking.get_label() == next_folder) {
            return this.add_folder_process(item, rest_path, checking);
            // next target found
          }
        }
      }
      return false;
    }
  }

  private access(path: string, type: string) {
    let target_label = path.split('/').pop();
    if (target_label && this.last_add_path && this.last_add_path_bookmark && (path.indexOf(this.last_add_path) == 0)) {
      // See if is exactly one level up
      if (this.last_add_path.length + target_label.length + 1 == path.length) {
        let base_content = this.last_add_path_bookmark.get_content();
        for (let index = 0; index < base_content.length; index++) {
          let item = base_content[index];
          if ((item.get_type() == type) && (item.get_label() == target_label)) {
            // console.log('[bunch_of_bookmarks][access] Hit Cache! True!');
            return true;
          }
        }
        // console.log('[bunch_of_bookmarks][access] Hit Cache! False');
        return false;
      }
    }
    return undefined;
  }
}

@Sendable
export class bookmark {
  contents: collections.Array<bookmark> = new collections.Array();
  private is_folder: boolean = false;
  private last_modified: number;
  private label: string;
  private link: string;
  private add_date: number;

  /**
   * bookmark item, consists of a label, a link and an add timestamp.
   * @param label A string, the name of this bookmark.
   * @param link A string, the link of this bookmark.
   * @param add_date A number, the add date of this folder (timestamp in seconds).
   * */
  constructor(label: string, link: string, add_date?: number, last_modified?: number, is_folder: boolean = false) {
    let date = new Date();
    this.label = label.replaceAll("/", "／");
    this.link = link;
    this.add_date = add_date || Math.round(date.getTime() / 1000);
    this.last_modified = last_modified || Math.round(date.getTime() / 1000);
    this.is_folder = is_folder;
  }

  set_label(set: string) {
    // TODO: Find a better way to access a bookmark directory or store labels
    // Avoid slash collision in directory access
    this.label = set.replaceAll("/", "／");
  }

  /**
   * Sets the link of current bookmark. Doesn't take effect if is a folder.
   * @param set The new link.
   * */
  set_link(set: string) {
    if (this.is_folder) {
      this.link = '';
      return;
    }
    this.link = set;
  }

  get_label() {
    return this.label;
  }

  /**
   * Link of this bookmark object.
   * @returns The link if is a bookmark, empty string if is a folder.
   * */
  get_link() {
    return this.link;
  }

  get_add_date() {
    return this.add_date;
  }

  /**
   * gets the type of this object
   * @returns "bookmark"
   * */
  get_type() {
    return this.is_folder ? "folder" : "bookmark";
  }

  // Folder

  get_last_modified() {
    return this.last_modified;
  }

  /**
   * Get plain information of all bookmarks in this folder and sub folders.
   * @returns A string[][] array consists of labels and links.
   * @example [['bing','www.bing.com'],['google','www.google.com']]
   * */
  get_plain_bookmarks() {
    let type: string = "";
    let item: bookmark;
    let result: collections.Array<collections.Array<string>> = new collections.Array();
    for (let index = 0; index < this.contents.length; index++) {
      item = this.contents[index];
      type = item.get_type();
      // Get item data
      if (type == "bookmark") {
        // item = item as bookmark;
        result.push(collections.Array.from([item.get_label(), item.get_link()])); // Push bookmark
      } else if (type == "folder") {
        // item = item as folder;
        result = result.concat(item.get_plain_bookmarks());
      }
    }
    return result;
  }

  /**
   * Encode this folder into HTML style text.
   * @param number_of_spaces The number of spaces in the front the line (forming an indent).
   * @returns The encoded HTML style text of this folder, containing its sub folders.
   * */
  get_contents_in_html(number_of_spaces: number) {
    let spaces: number = number_of_spaces;
    let type: string = "";
    let item: bookmark;
    let result: string[] = [];
    result.push(" ".repeat(spaces) +
      "<DT><H3 ADD_DATE=\"" + this.add_date.toString() +
      "\" LAST_MODIFIED=\"" + this.last_modified.toString() +
      "\">" + encode_string_to_html_code(this.label) +
      "</H3>\n" + " ".repeat(spaces) + "<DL><p>"); // Head of folder
    for (let index = 0; index < this.contents.length; index++) {
      item = this.contents[index];
      type = item.get_type();
      // Get item data
      if (type == "bookmark") {
        // item = item as bookmark;
        result.push(
          " ".repeat(spaces + 4) +
            "<DT><A HREF=\"" + ensure_scheme(item.get_link()) +
            "\" ADD_DATE=\"" + item.get_add_date().toString() +
            "\">" + encode_string_to_html_code(item.get_label()) + "</A>"
        ); // Push bookmark
      } else if (type == "folder") {
        // item = item as folder;
        result = result.concat(item.get_contents_in_html(spaces + 4));
      }
    }
    result.push(" ".repeat(spaces) + "</DL><p>"); // END of folder
    return result;
  }

  add_content(item: bookmark) {
    this.contents.push(item);
  }

  /**
   * Deletes a bookmark or folder in this directory, according to the index given.
   * @param index The index of the delete target in this directory.
   * @returns true if success.
   * @returns false if failed, due to an index out of bounds, perhaps.
   * */
  del_content(index: number) {
    if (index >= this.contents.length) {
      // Index out of bounds
      return false;
    }
    this.contents.splice(index, 1);
    return true;
  }

  /**
   * Returns The contents of this folder.
   * @returns A bookmark[] array.
   * */
  get_content() {
    return this.contents as collections.Array<bookmark>;
  }

  /**
   * Returns The bookmarks, excluding folders, of this folder.
   * @returns A bookmark[] array.
   * */
  get_only_bookmarks_content() {
    let result_bookmarks: Array<bookmark> = [];
    for (let index = 0; index < this.contents.length; index++) {
      let this_item = this.contents[index];
      if (this_item.get_type() == 'bookmark') {
        result_bookmarks.push(this_item as bookmark);
      }
    }
    return result_bookmarks;
  }
}
