import { sandbox_open_sync, sandbox_save } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';

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
}

export class bunch_of_history {
  history_this_month: history_record[] = [];
  current_year: number = new Date().getFullYear();
  current_month: number = new Date().getMonth() + 1;
  private cached_plain_history: string[][] = [];
  private plain_history_default_max_length: number = 500;
  private current_opened_file_path: string = '';

  /**
   * A class holding a history_record[] array, in which there stores history_record objects.
   * @param plain_history_max_length The default max length of plain history reconstruction.
   */
  constructor(plain_history_max_length?: number) {
    if (plain_history_max_length) {
      this.plain_history_default_max_length = plain_history_max_length;
    }
    this.open_month_from_disk(this.current_year, this.current_month, true);
  }

  // Settings

  /**
   * Set the max length of cached_plain_history reconstruction products.
   * @param max_length The default max length of plain history reconstruction.
   * */
  set_plain_max_length(max_length: number) {
    this.plain_history_default_max_length = max_length;
  }

  // Use

  /**
   * Adds a history, automatically puts it in the order of time.
   * @param history A history_record object.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  add_history(history: history_record, instantly_save_to_disk: boolean) {
    let history_date = new Date(history.accessed_time);
    let year = history_date.getFullYear();
    let month = history_date.getMonth() + 1;

    // Opens the month required
    this.open_month_from_disk(year, month, false);

    let insert_position = this.index_of_record_after_time(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_this_month.length;
    }
    this.history_this_month.splice(insert_position, 0, history);
    this.cached_plain_history.push([history.label, history.link]);

    if (instantly_save_to_disk) {
      this.save_month_to_disk();
    }
  }

  /**
   * Removes the history record at the index given.
   *
   * Not recommended when deleting a lot of history records.
   * @param index A number, the index of the target item in the grand history_list.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_history(year: number, month: number, index: number, instantly_save_to_disk: boolean) {
    // Opens the month required
    this.open_month_from_disk(year, month, false);
    // Delete
    this.history_this_month.splice(index, 1);
    // Save
    if (instantly_save_to_disk) {
      this.save_month_to_disk();
    }
  }

  /**
   * Removes some selected histories, according to a given array of indices.
   *
   * Should be preferred when deleting a lot of history records.
   * @param selections A number[] array, indicating the indices of the items to be deleted.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_selected_history(year: number, month: number, selections: number[], instantly_save_to_disk: boolean) {

    // Opens the month required
    this.open_month_from_disk(year, month, false);

    selections.sort((a, b) => {
      return a - b;
    });

    let selected = new Array<boolean>(this.history_this_month.length);
    let result_history: history_record[] = [];

    for (let i = 0; i < selections.length; i++) {
      selected[selections[i]] = true;
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
  index_of_record_after_time(timestamp: number) {
    if (this.history_this_month.length == 0) {
      return -1;
    }
    if (timestamp > this.history_this_month[this.history_this_month.length - 1].accessed_time) {
      return -2;
    }
    if (timestamp <= this.history_this_month[0].accessed_time) {
      return 0;
    }

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

  /**
   * Get the plain label link array from the cached array.
   * @returns A string[][] array, cached_plain_history, which consists of plain label and link pairs.
   * @example [['bing', 'www.bing.com'], ['loading', 'www.google.com']]
   * */
  get_plain_history(): string[][] {
    if (this.cached_plain_history.length == 0) {
      this.construct_this_month_plain_history();
    }
    return this.cached_plain_history as string[][];
  }

  /**
   * Constructs the plain history of this month.
   * */
  construct_this_month_plain_history() {
    for (let index = 0; index < Math.min(this.history_this_month.length, this.plain_history_default_max_length);
      index++) {
      this.cached_plain_history.push([this.history_this_month[index].label, this.history_this_month[index].link]);
    }
  }

  // External interaction

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
   * Import history records in a specific plain text format.
   *
   * In default overwrites whatever was in this history_list.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  private import_string(imp: string) {
    this.history_this_month = [];

    if (imp.split("\n").length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history] Import Error: not 3*n length: " + imp)
      return;
    }

    this.history_this_month = [];
    // Clear
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 3) {
      if (import_list[index] != "") {
        let new_history_record =
          new history_record(import_list[index], import_list[index+1], Number.parseInt(import_list[index+2]));
        this.add_history(new_history_record, false);
      }
    }
    console.log("[Meow][bunch_of_history] Import history success, length: " + this.history_this_month.length.toString())
  }

  /**
   * Check the history file structure on disk.
   * After executing this, there will be ENSURED a history/history_year_month.txt existing for use.
   * */
  check_disk_month(year: number, month: number) {
    let filesDir = getContext().filesDir;
    let new_history = true;
    try {
      fs.mkdirSync(filesDir + '/history');
    } catch (e) {
      console.log('[Meow][bunch_of_downloads] E: history folder already exists.')
      new_history = false;
    }

    let history_year_month_path = this.history_path_of_month(year, month);

    if (new_history) {
      // no history before, like the first use of entire app
      console.log("[Meow][meowAppSettings] NO HISTORY BEFORE!");
      sandbox_save(history_year_month_path, '');
    } else {
      // check if this month have a history
      let this_month_history = sandbox_open_sync(history_year_month_path);
      if (this_month_history as string == "undefined") {
        // This month doesn't have a history file
        console.log("[Meow][meowAppSettings] NO HISTORY FOR " + history_year_month_path);
        sandbox_save(history_year_month_path, '');
      } else {
        // This month has an existing history file
        console.log("[Meow][meowAppSettings] Found existing history for this month, no actions meow!");
      }
    }
  }

  /**
   * Opens a month of history.
   * @param path A string, the path of the file.
   * */
  open_month_from_disk(year: number, month: number, construct_monthly_plain_history: boolean) {
    if (this.history_path_of_month(year, month) == this.current_opened_file_path) {
      // Already opened
      // console.log('already opened')
      return;
    }
    this.check_disk_month(year, month);
    let path = this.history_path_of_month(year, month);
    let the_file = sandbox_open_sync(path);
    this.current_opened_file_path = path;
    this.current_year = year;
    this.current_month = month;
    this.import_string(the_file);
    if (construct_monthly_plain_history) {
      this.construct_this_month_plain_history();
    }
  }

  /**
   * Saves the current opened file to disk
   * */
  save_month_to_disk() {
    sandbox_save(this.current_opened_file_path, this.export_string());
  }

  /**
   * Constructs the file name of history records in which history in [year, month] should be.
   * @param year A number, the year, like 2024.
   * @param month A number, the month, like 12.
   * @returns A string, 'history/history_year_month.txt'
   * */
  history_path_of_month(year: number, month: number) {
    let month_unified = month.toString();
    if (month_unified.length == 1) {
      month_unified = '0' + month_unified;
    }
    return 'history/history_' + year.toString() + "_" + month_unified + '.txt';
  }

  /**
   * Lists all the months with history.
   * @returns A number[][] array, e.g. [[2024, 2], [2023, 4], ...].
   * */
  scan_history_months() {
    this.check_disk_month(new Date().getFullYear(), new Date().getMonth() + 1);
    let result: number[][] = [];
    let filesDir = getContext().filesDir;
    let history_files = fs.listFileSync(filesDir + '/history', { recursion: false });
    for (let index = 0; index < history_files.length; index++) {
      let f_name = history_files[index].split('.')[0];
      // 'history_2024_2.txt'
      let f_split = f_name.split('_');
      let year = parseInt(f_split[1]);
      let month = parseInt(f_split[2]);
      result.push([year, month]);
    }
    result = result.sort((a, b) => (b[0] * 12 + b[1]) - (a[0] * 12 + a[1]));
    // console.log(result.toString())
    return result;
  }
}
