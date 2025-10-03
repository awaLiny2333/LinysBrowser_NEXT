import { default_search_engine } from './bunch_of_defaults';
import { bunch_of_settings } from './bunch_of_settings';

export class bunch_of_search_engines {
  static list_of_search_engines: search_engine[] = [];

  /**
   * Update last accessed time. This would trigger some refresh on UI layer.
   * */
  static update_last_accessed() {
    AppStorage.setOrCreate('bunch_of_search_engines_update', Date.now());
  }

  /**
   * Sets the global SE.
   * @param idx The index of SE.
   * */
  static set_global_SE(idx: number) {
    if (idx == -99) {
      // Setting index to -99 then the real value
      // Can force refresh @Watch
      // And the index -99 has no meaning
      return;
    }
    AppStorage.setOrCreate('search_engine_selected', idx);
    if (idx <= -1) {
      // If set back to default
      AppStorage.setOrCreate('search_engine', default_search_engine());
    } else {
      AppStorage.setOrCreate('search_engine', bunch_of_search_engines.list_of_search_engines[idx].url);
    }
    bunch_of_settings.set('custom_search_engines_selected_index', idx);
  }

  /**
   * Add a new search engine to the current search engine list.
   * @param se A search_engine object, the search engine to be added.
   * */
  static add_search_engine(se: search_engine) {
    bunch_of_search_engines.list_of_search_engines.push(se);
    bunch_of_search_engines.update_last_accessed();
  }

  /**
   * Remove a search engine from the current search engine list.
   * @param index A number, the index of the search engine to be removed in the list.
   * */
  static del_search_engine(index: number) {
    bunch_of_search_engines.list_of_search_engines.splice(index, 1);
    bunch_of_search_engines.update_last_accessed();
  }

  /**
   * Export search engines in a specific plain text format.
   * @returns '\n' connected string of search engines in the format of:
   * @example 'Bing\nhttps://www.cn.bing.com/search?q=%s\nGoogle\nhttps://www.google.com/search?q=%s'
   * */
  static export_string() {
    let export_list: string[] = []
    for (let index = 0; index < bunch_of_search_engines.list_of_search_engines.length; index++) {
      let ua: search_engine = bunch_of_search_engines.list_of_search_engines[index];
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
  static import_string(imp: string) {
    // Clear
    bunch_of_search_engines.list_of_search_engines = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        bunch_of_search_engines.add_search_engine(new search_engine(import_list[index], import_list[index+1]));
      }
    }
  }
}

export class search_engine {
  label: string;
  url: string;

  /**
   * A search_engine object, which consists of a label and the search engine link.
   * @param label The name of the search engine.
   * @param link The link of the search engine, '%s' in which will be replaced with real search keywords.
   */
  constructor(label: string, content: string) {
    this.label = label;
    this.url = content;
  }
}
