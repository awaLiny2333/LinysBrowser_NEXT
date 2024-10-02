export class bunch_of_search_engines {
  list_of_search_engines: search_engine[] = [];

  constructor() {
  }

  add_search_engine(se: search_engine) {
    this.list_of_search_engines.push(se);
  }

  del_search_engine(index: number) {
    this.list_of_search_engines.splice(index, 1);
  }

  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_search_engines.length; index++) {
      let ua: search_engine = this.list_of_search_engines[index];
      export_list.push(ua.label);
      export_list.push(ua.content);
    }
    return export_list.join("\n");
  }

  /**
   * @param imp store string
   * @abstract In default overwrites whatever was in this bunch_of_search_engines
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
  content: string;

  constructor(label: string, content: string) {
    this.label = label;
    this.content = content;
  }
}