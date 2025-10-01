import { sandbox_read_text_sync, sandbox_save, sandbox_unlink_sync } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';
import { bunch_of_history_index } from './bunch_of_history_index';
import {
  ensure_this_month_history_file,
  ensure_this_month_index_file,
  history_index_full_rebuild_worker,
  history_index_load_from_disk_worker,
  history_index_save_to_disk_worker,
  history_path_of_month
} from './bunch_of_history_index_x_functions';
import { bunch_of_history_index_lite } from './bunch_of_history_index_lite';
import { meowContext } from '../utils/environment_tools';
import { deduplicate_pairs, divide_string, label_link_match_key } from '../utils/data_operation_tools';

export class history_record {
  accessed_time: number = Date.now();
  label: string;
  link: string;

  /**
   * history_record item, consists of a label, a link and an accessed timestamp.
   * @param label A string, the name of this bookmark.
   * @param link A string, the link of this bookmark.
   * @param accessed_time A number, the access time of this history (timestamp in milliseconds)
   * */
  constructor(label: string, link: string, accessed_time?: number) {
    if (accessed_time !== undefined) {
      this.accessed_time = accessed_time;
    }
    this.label = label;
    this.link = link;
  }

  /**
   * Increases this history's accessed_time by one (1).
   * */
  shift_time() {
    this.accessed_time++;
  }

  toString() {
    return "[" + this.accessed_time.toString() + "] " + this.label + " (" + this.link + ") ";
  }
}

export class bunch_of_history {
  static history_index: bunch_of_history_index = new bunch_of_history_index();
  private history_this_month: history_record[] = [];
  private current_year: number = new Date().getUTCFullYear();
  private current_month: number = new Date().getUTCMonth() + 1;
  private current_opened_file_path: string = '';

  /**
   * A class holding a history_record[] array, in which there stores history_record objects.
   * @param no_init Will not open any data from disk nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }

    let first_launch = false;

    // Creates folders for history and index
    try {
      fs.mkdirSync(meowContext().filesDir + '/history');
    } catch (e) {
      // console.log('[Meow][bunch_of_history] Check disk of month: E: /history folder already exists.')
    }
    try {
      fs.mkdirSync(meowContext().filesDir + '/history-index');
    } catch (e) {
      // console.log('[Meow][bunch_of_history] Check disk of month: E: /history folder already exists.')
    }

    // History
    try {
      if (fs.listFileSync(meowContext().filesDir + '/history-index', { recursion: false }).length == 0) {
        // First launch of app
        first_launch = true;
      } else {
        // Compatibility patch for older BrowserCats
        this.patch_old_history_files();
        this.patch_history_files_before_index_era();
      }
    } catch (e) {
      console.error('[bunch_of_history][constructor] patch error: ' + e);
    }

    // Indexing
    try {
      if (fs.listFileSync(meowContext().filesDir + '/history-index', { recursion: false }).length == 0) {
        if (first_launch) {
          // No history. First launch of app.
          console.log(bunch_of_history_index.log_head() + ' First launch of app. Skipping loading index.');
        } else {
          console.log(bunch_of_history_index.log_head() + ' No index found. Perhaps this is an upgrade from older BrowserCats?');
          console.log(bunch_of_history_index.log_head() + ' Rebuilding... ');
          history_index_full_rebuild_worker();
        }
      } else {
        // Load index
        // In a concurrent way?!
        history_index_load_from_disk_worker("normal");
      }
    } catch (e) {
      console.error('[bunch_of_history][constructor] index error: ' + e);
    }

    // Ensure
    try {
      ensure_this_month_index_file();
      ensure_this_month_history_file();
    } catch (e) {
      console.error('[bunch_of_history][constructor] ensure error: ' + e);
    }

    // Load today
    try {
      this.open_month_from_disk_sync(this.current_year, this.current_month);
    } catch (e) {
      console.error('[bunch_of_history][constructor] load today error: ' + e);
    }

    // Log
    // console.log('[Meow][bunch_of_history] bunch_of_history initialization finished!');
  }

  // Statics

  /**
   * Connects a year and a month to string.
   * @param year A number, the year.
   * @param month A number, the month.
   * @returns A string, in the format (year - month).
   * */
  static year_month_to_string(year: number, month: number) {
    return "(" + year.toString() + " - " + month.toString() + ")"
  }

  /**
   * Lists all the months in which ther are history records made.
   * @returns A number[][] array, e.g. [[2024, 2], [2023, 4], ...].
   * */
  static get_history_months(context_filesDir?: string) {
    let filesDir: string = context_filesDir || meowContext().filesDir;
    // Ensure this month
    ensure_this_month_history_file(context_filesDir);
    // Traverse directory
    let result: number[][] = [];
    let history_files = fs.listFileSync(filesDir + '/history', { recursion: false });
    for (let index = 0; index < history_files.length; index++) {
      let f_name = history_files[index].split('.')[0];
      // 'history_2024_02.txt'
      let f_split = f_name.split('_');
      let year = parseInt(f_split[1]);
      let month = parseInt(f_split[2]);
      result.push([year, month]);
    }
    result = result.sort((a, b) => (b[0] * 12 + b[1]) - (a[0] * 12 + a[1]));
    console.log('[Meow][bunch_of_history] Got_available_months. Result: ' + result.join(' ') + '.')
    return result;
  }

  /**
   * Search all histories with help of index
   * @param key the search key
   * @param max_result_number max result number. if not filled then unlimited.
   * @returns label-link string[][]
   * */
  static search_with_index(key: string, max_result_number?: number): string[][] {
    // Timer
    let s = Date.now();
    // console.log('[Meow][bunch_of_history_index] Start Searching with Index! Start: ' + s.toString())

    let search_number = max_result_number;
    if (search_number) {
      search_number *= 10;
    }
    let result = bunch_of_history_index.search_history_label_link(key, search_number);

    // Deduplication
    result = deduplicate_pairs(result).slice(0, max_result_number);

    let result_count = result.length;
    if (result.length > 0) {
      console.log('[Meow][bunch_of_history][bunch_of_history_index] ' + result_count.toString() + ' results of Key "' + key + '" ' +
        'searched among ' + bunch_of_history_index.index_map.size.toString() + ' keys! (' + (Date.now() - s).toString() + ' ms)');
    }
    return result;
  }

  // Properties

  get_current_year() {
    return this.current_year;
  }

  get_current_month() {
    return this.current_month;
  }

  get_history_this_month() {
    return this.history_this_month;
  }

  /**
   * Searches through the history of this month.
   * @param key The search key.
   * @returns Array<Array<history_record | number>>
   * */
  get_history_this_month_with_index(key: string = '') {
    let result: Array<Array<history_record | number>> = [];
    let shown: boolean[] = [];
    let woofHistory_filter = AppStorage.get('woofHistory_filter') as number;
    let woofHistory_match_coefficient = AppStorage.get('woofHistory_match_coefficient') as number;

    // Process keyword
    key = key.toUpperCase();
    let keys: string[] = [];
    if (woofHistory_match_coefficient == 1) {
      keys.push(key);
    } else {
      keys = Array.from(divide_string(key));
    }
    console.log('[Meow][bunch_of_history] History search keywords: \n' + keys.join('\n'));

    // Search
    for (let index = 0; index < this.history_this_month.length; index++) {
      let element = this.history_this_month[index];

      if (key != '') {
        // Prepare information
        let url: string;
        try {
          url = decodeURIComponent(element.link).toUpperCase();
        } catch (e) {
          url = element.link.toUpperCase();
        }
        let label = (element.label.toUpperCase());
        // Push if hits search
        if (label_link_match_key(label, url, keys, woofHistory_filter, woofHistory_match_coefficient)) {
          result.push([element, index]);
          shown.push(true);
        } else {
          shown.push(false);
        }

      } else {
        // No search
        result.push([element, index]);
        shown.push(true);
      }
    }

    // Label the proportion of records that are included in the search result.
    AppStorage.set('woofHistory_shown', shown);

    // TODO: Is .reverse() efficient enough?
    return result.reverse();
  }

  // Operations

  /**
   * Adds a history, automatically puts it in the order of time.
   * @param history A history_record object.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  add_history(history: history_record, instantly_save_to_disk: boolean, index: boolean, layer?: number) {
    // console.log('[Meow][bunch_of_history]' + '    '.repeat(layer || 0) + '(' + (layer || 0).toString() + ') Add history: ' + history.toString());
    let history_date = new Date(history.accessed_time);
    let year = history_date.getUTCFullYear();
    let month = history_date.getUTCMonth() + 1;

    // Opens the month required
    this.open_month_from_disk_sync(year, month);

    // Determine insert position
    let insert_position = this.index_of_first_record_at_or_after_time(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_this_month.length;
    } else {
      // Avoid same accessed_time
      while (this.history_this_month[insert_position].accessed_time == history.accessed_time) {
        insert_position++;
        history.shift_time();
        if (insert_position >= this.history_this_month.length) {
          insert_position = this.history_this_month.length;
          break;
        }
      }
    }

    // Perhaps insert position determination process caused this history item to shift time, entering another month.
    // check if this reaches another month
    let new_history_date = new Date(history.accessed_time);
    let new_year = new_history_date.getUTCFullYear();
    let new_month = new_history_date.getUTCMonth() + 1;
    if (new_year * 100 + new_month != year * 100 + month) {
      // Reaches another month
      this.add_history(history, instantly_save_to_disk, index, (layer || 0) + 1);
    } else {
      // Still in this month
      this.history_this_month.splice(insert_position, 0, history);
      // Saving
      if (instantly_save_to_disk) {
        this.save_month_to_disk();
      }
      // Indexing
      if (index) {
        let history_index_loading = AppStorage.get('history_index_loading') as boolean;
        if (history_index_loading) {
          // Loading task is ongoing
          console.log("[Meow][bunch_of_history][bunch_of_history_index] History_index_loading task is ongoing! Interrupted this one.")
        } else {
          // Add to index
          try {
            // TODO: IMPROVE THIS LOGIC to avoid missing add_index_string jobs.
            // ↑ This got relaxed due to monthly division of index system.
            // This try catch is just to avoid crashes.
            bunch_of_history_index.add_index_string_full(history.label + " " + encodeURI(history.link), history.accessed_time);
            // TODO: This only works when history is in same month.
            bunch_of_history_index_lite.add_index_string(history.label + " " + encodeURI(history.link), history.accessed_time);
          } catch (e) {
            console.error(e);
          }
          try {
            // TODO: figure out why history_index_loading is false for the initial loading
            console.log(bunch_of_history_index_lite.log_head() + " Loading: " + (AppStorage.get('history_index_loading') as boolean ? "loading." : "OK."));
            history_index_save_to_disk_worker(bunch_of_history_index_lite.index_map, bunch_of_history_index_lite.this_file_name(), false);
          } catch (e) {
            // Import not finished
            console.error(e);
          }
        }
      }
    }
  }

  /**
   * Removes some selected histories, according to a given array of indices.
   *
   * Should be preferred when deleting a lot of history records.
   * @param indices A number[] array, indicating the indices of the items to be deleted.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_histories_at_indices(year: number, month: number, indices: number[], instantly_save_to_disk: boolean) {

    // Opens the month required
    this.open_month_from_disk_sync(year, month);

    indices.sort((a, b) => {
      return a - b;
    });

    let selected = new Array<boolean>(this.history_this_month.length);
    let result_history: history_record[] = [];

    for (let i = 0; i < indices.length; i++) {
      selected[indices[i]] = true;
    }

    for (let i = 0; i < this.history_this_month.length; i++) {
      if (selected[i] == true) {
        // Marked to be deleted
      } else {
        result_history.push(this.history_this_month[i]);
      }
    }

    this.history_this_month = result_history;

    // Save
    if (instantly_save_to_disk) {
      this.save_month_to_disk();
    }
  }

  /**
   * Get the index of the first history item whose access_time is not smaller than Target.
   * @param timestamp The limit of earliest timestamp.
   * @returns A positive number, the index.
   * @returns -1 if list is empty.
   * @returns -2 if Target is bigger than all histories.
   * */
  index_of_first_record_at_or_after_time(timestamp: number) {
    if (this.history_this_month.length == 0) {
      return -1;
    }
    if (timestamp > this.history_this_month[this.history_this_month.length - 1].accessed_time) {
      return -2;
    }
    if (timestamp <= this.history_this_month[0].accessed_time) {
      return 0;
    }

    // Binary search
    let start = 0;
    let end = this.history_this_month.length - 1;
    let mid = Math.floor((start + end) / 2);
    while (start <= end) {
      mid = Math.floor((start + end) / 2);
      let mid_time = this.history_this_month[mid].accessed_time;
      if (mid_time > timestamp) {
        end = mid - 1;
      }
      if (mid_time < timestamp) {
        start = mid + 1;
      }
      if (mid_time == timestamp) {
        while (mid > 0 && this.history_this_month[mid].accessed_time == timestamp) {
          // in case of same access_time
          // choose the front-most
          mid -= 1;
        }
        break;
      }
    }
    if (mid + 1 < this.history_this_month.length && this.history_this_month[mid].accessed_time < timestamp) {
      // Make sure the history at mid has an access_time equal to or larger than Target timestamp
      mid = mid + 1;
    }
    return mid;
  }

  // Files and Saving

  /**
   * Opens a month of history using lite import, that is, assuming all of them are in time range one month.
   * @param path A string, the path of the file.
   * */
  open_month_from_disk_sync(year: number, month: number) {
    if (history_path_of_month(year, month) == this.current_opened_file_path) {
      // Already opened
      // console.log('already opened')
      return;
    }
    console.log('[bunch_of_history] Called open_month_from_disk_sync Y: ' + year + ' M: ' + month + '.');
    ensure_this_month_history_file();
    let path = history_path_of_month(year, month);
    let the_file = sandbox_read_text_sync(path);
    this.current_opened_file_path = path;
    this.current_year = year;
    this.current_month = month;
    if (the_file == "undefined" || the_file.length <= 1) {
      console.info("[Meow][bunch_of_history] Import history SKIPPED: Too short. (" + path + ").");
      // Clear
      this.history_this_month = [];
      return;
    }
    this.import_string_lite(the_file, year, month);
  }

  /**
   * Saves the current opened file to disk
   * */
  save_month_to_disk() {
    sandbox_save(this.current_opened_file_path, this.export_string());
  }

  // PATCHES

  /**
   * Executed when an old format history.txt is found.
   * This migrates old histories to new format and deletes the old file.
   * */
  patch_old_history_files() {
    let old_history = sandbox_read_text_sync('history.txt');
    if (old_history == 'undefined') {
      return;
    }
    // Patch
    console.log('[Meow][bunch_of_history] Patch old history: found old history:\n' + old_history.toString());
    this.import_string_full(old_history);
    sandbox_unlink_sync('history.txt');
  }

  /**
   * This migration happens between 1.7.6(1000024) and 1.7.7(1000025)
   * to switch all original timestamps into UTC time.
   * */
  patch_history_files_before_index_era() {
    let version_file = sandbox_read_text_sync('last_app_versionCode.txt');
    if (version_file != 'undefined') {
      return;
    }
    console.log('[Meow][bunch_of_history] Patch old history of migration 1.7.6(1000024) to 1.7.7(1000025).');

    let result: string = "";
    let months = bunch_of_history.get_history_months();
    for (let index = 0; index < months.length; index++) {
      const year = months[index][0];
      const month = months[index][1];
      const path = history_path_of_month(year, month);
      if (result == "") {
        result = sandbox_read_text_sync(path);
      } else {
        result = result + "\n" + sandbox_read_text_sync(path);
      }
      // console.log(result.split("\n").length.toString());
    }

    // clear history
    try {
      let filesDir = meowContext().filesDir;
      fs.rmdirSync(filesDir + "/history");
      fs.mkdirSync(filesDir + "/history")
    } catch (e) {
      console.error(e)
    }

    this.import_string_full(result);
  }

  // Data Management

  /**
   * Export history records in a specific plain text format.
   * @returns "\n" connected string of history records in the format of:
   * @example 'bing\nbing.com\n127771721'
   * */
  private export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.history_this_month.length; index++) {
      let history_item: history_record = this.history_this_month[index];
      export_list.push(history_item.label);
      export_list.push(history_item.link);
      export_list.push(history_item.accessed_time.toString());
    }
    return export_list.join("\n");
  }

  /**
   * THIS IS LEGACY CODE FOR MIGRATION ONLY
   *
   * Import history records in a specific plain text format.
   *
   * Usually used when to import a file containing histories spanning over months.
   *
   * In default overwrites whatever was in this opened_month_history_list.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  private import_string_full(imp: string) {
    let import_list: string[] = imp.split("\n");
    if (import_list.length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history] Import history Error: not 3*n length. Raw string: \n" + imp)
      return;
    }

    console.log("[Meow][bunch_of_history] Starting to import history");
    let start_time = Date.now();

    // Clear
    this.history_this_month = [];

    let last_month = [0, 0];
    for (let index = 0; index < import_list.length; index += 3) {
      // if (index % (3 * 10) == 0) {
      //   console.log("[Meow][bunch_of_history] Import progress: " + (index * 100 / import_list.length).toFixed(2) + "%")
      // }
      if (import_list[index] != "") {
        let access_time = Number.parseInt(import_list[index+2]);
        let access_Date = new Date(access_time);
        let new_month = [new Date(access_time).getUTCFullYear(), new Date(access_time).getUTCMonth() + 1];

        if ((last_month[0] != new_month[0]) || (last_month[1] != new_month[1])) {
          // if changed month, then save this file
          if ((last_month[0] != 0) && (last_month[1] != 0)) {
            console.log('[Meow][bunch_of_history] Import history saved month ' + last_month.toString() + 'to disk.');
            this.save_month_to_disk();
            this.history_this_month = []; // I believe this should be added
          }
        }

        let new_history_record = new history_record(import_list[index], import_list[index+1], access_time);
        this.add_history(new_history_record, false, false);

        last_month = [access_Date.getUTCFullYear(), access_Date.getUTCMonth() + 1];
      }
    }
    this.save_month_to_disk();
    console.log('[Meow][bunch_of_history] Import history success! Time used: ' +
    (Date.now() - start_time).toString() + "ms.");
  }

  /**
   * Import history records in a specific plain text format.
   *
   * Assuming that all records are in one month.
   *
   * In default overwrites whatever was in this opened_month_history_list.
   *
   * Usually used when importing a month file, because it is ensured to be legal.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  private import_string_lite(imp: string, year: number, month: number) {
    let import_list: string[] = imp.split("\n");
    if (import_list.length <= 1) {
      // This is theoretically prevented in previous codes
      // As far as this function is used in such way (19 May, 2025)
      console.log("[Meow][bunch_of_history][lite] Import history string SKIPPED: too short length. Raw string: '" + imp + "'.");
      return;
    }
    if (import_list.length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history][lite] Import history Error: not 3*n length. Raw string: '" + imp + "'.")
      return;
    }

    console.log("[Meow][bunch_of_history][lite] Starting to import history");
    let start_time = Date.now();
    let month_time_error = 0;

    // Clear
    this.history_this_month = [];

    for (let index = 0; index < import_list.length; index += 3) {
      // if (index % 1000 == 0) {
      //   console.log("[Meow][bunch_of_history][lite] Import progress: " + (index * 100 / import_list.length).toFixed(2) +
      //     "%")
      // }
      let access_time = Number.parseInt(import_list[index+2]);
      let d = new Date(access_time);
      if (d.getUTCFullYear() != year || (d.getUTCMonth() + 1) != month) {
        // THIS RECORD IS NOT IN THIS MONTH!
        month_time_error += 1;
        continue;
      }
      let new_history_record = new history_record(import_list[index], import_list[index+1], access_time);
      this.add_history(new_history_record, false, false);
    }

    if (month_time_error > 0) {
      console.error('[Meow][bunch_of_history][lite] Import history error: ' + month_time_error + ".");
    }
    console.log('[Meow][bunch_of_history][lite] Import history success! (' + (Date.now() - start_time) + " ms)");
  }
}