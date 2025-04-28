export class bunch_of_homepage_shortcuts {
  list_of_homepage_shortcuts: homepage_shortcut[] = [];
  last_accessed: number = 0;

  /**
   * A class holding a homepage_shortcut[] array, in which there stores homepage_shortcut objects.
   */
  constructor() {
  }

  /**
   * Add a new homepage shortcut to the current homepage shortcut list.
   * @param hs A homepage_shortcut object, the homepage shortcut to be added.
   * */
  add_homepage_shortcut(hs: homepage_shortcut) {
    this.list_of_homepage_shortcuts.push(hs);
    this.last_accessed = Date.now();
  }

  /**
   * Remove a homepage shortcut from the current homepage shortcut list.
   * @param index A number, the index of the homepage shortcut to be removed in the list.
   * */
  del_homepage_shortcut(index: number) {
    this.list_of_homepage_shortcuts.splice(index, 1);
    this.last_accessed = Date.now();
  }

  /**
   * Export homepage shortcut in a specific plain text format.
   * @returns '\n' connected string of search engines in the format of:
   * @example 'Bing\nhttps://www.cn.bing.com\nGoogle\nhttps://www.google.com'
   * */
  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_homepage_shortcuts.length; index++) {
      let ua: homepage_shortcut = this.list_of_homepage_shortcuts[index];
      export_list.push(ua.label);
      export_list.push(ua.url);
    }
    return export_list.join("\n");
  }

  /**
   * Import homepage shortcut in a specific plain text format.
   * In default overwrites whatever was in this list_of_homepage_shortcut.
   * @param imp The string in the correct format:
   * @example 'Bing\nhttps://www.cn.bing.com\nGoogle\nhttps://www.google.com'
   * */
  import_string(imp: string) {
    // Clear
    this.list_of_homepage_shortcuts = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        this.add_homepage_shortcut(new homepage_shortcut(import_list[index], import_list[index+1]));
      }
    }
  }
}

export class homepage_shortcut {
  label: string;
  url: string;

  /**
   * A homepage_shortcut object, which consists of a label and the homepage shortcut url.
   * @param label The name of the homepage_shortcut.
   * @param url The url of the homepage_shortcut.
   */
  constructor(label: string, content: string) {
    this.label = label;
    this.url = content;
  }
}
