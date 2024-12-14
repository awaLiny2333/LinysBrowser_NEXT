export class bunch_of_search_engines {
  list_of_search_engines: search_engine[] = [];
  last_accessed: number = 0;
  /**
   * A class holding a search_engine[] array, in which there stores search_engine objects.
   */
  constructor() {
  }

  /**
   * Add a new search engine to the current search engine list.
   * @param se A search_engine object, the search engine to be added.
   * */
  add_search_engine(se: search_engine) {
    this.list_of_search_engines.push(se);
    this.last_accessed = Date.now();
  }

  /**
   * Remove a search engine from the current search engine list.
   * @param index A number, the index of the search engine to be removed in the list.
   * */
  del_search_engine(index: number) {
    this.list_of_search_engines.splice(index, 1);
    this.last_accessed = Date.now();
  }

  /**
   * Export search engines in a specific plain text format.
   * @returns '\n' connected string of search engines in the format of:
   * @example 'Bing\nhttps://www.cn.bing.com/search?q=%s\nGoogle\nhttps://www.google.com/search?q=%s'
   * */
  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_search_engines.length; index++) {
      let ua: search_engine = this.list_of_search_engines[index];
      export_list.push(ua.label);
      export_list.push(ua.url);
    }
    return export_list.join("\n");
  }

  /**
   * Import search engines in a specific plain text format.
   * In default overwrites whatever was in this list_of_search_engines.
   * @param imp The string in the correct format:
   * @example 'Bing\nhttps://www.cn.bing.com/search?q=%s\nGoogle\nhttps://www.google.com/search?q=%s'
   * */
  import_string(imp: string) {
    // Clear
    this.list_of_search_engines = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        this.add_search_engine(new search_engine(import_list[index], import_list[index+1]));
      }
    }
  }
}

export class search_engine {
  label: string;
  url: string;

  /**
   * A search_engine object, which consists of a label and the search engine url.
   * @param label The name of the search engine.
   * @param url The url of the search engine, '%s' in which will be replaced with real search keywords.
   */
  constructor(label: string, content: string) {
    this.label = label;
    this.url = content;
  }
}
