import { sandbox_open_sync, sandbox_save, sandbox_unlink } from '../utils/storage_tools';
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

  shift_time() {
    this.accessed_time++;
  }
}

export class bunch_of_history {
  private history_this_month: history_record[] = [];
  private current_year: number = new Date().getFullYear();
  private current_month: number = new Date().getMonth() + 1;
  private cached_plain_history: string[][] = [];
  private plain_history_default_max_length: number = 500;
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

    // Load today
    this.open_month_from_disk(this.current_year, this.current_month, true);

    // Compatibility path for older BrowserCats
    this.patch_old_history_files();

    //Log
    console.log('[Meow][bunch_of_history] bunch_of_history initialization finished!')
  }

  get_current_year() {
    return this.current_year;
  }

  get_current_month() {
    return this.current_month;
  }

  get_history_this_month() {
    return this.history_this_month;
  }

  // PATCHES

  /**
   * Executed when an old format history.txt is found.
   * This migrates old histories to new format and deletes the old file.
   * */
  patch_old_history_files() {
    let old_history = sandbox_open_sync('history.txt');
    if (old_history != 'undefined') {
      console.log('[Meow][bunch_of_history] Patch old history: found old history:\n' + old_history.toString())
      this.import_string(old_history);
      sandbox_unlink('history.txt');
    }
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
    // check if this reaches next month
    let new_history_date = new Date(history.accessed_time);
    let new_year = new_history_date.getFullYear();
    let new_month = new_history_date.getMonth() + 1;
    if (new_year * 100 + new_month != year * 100 + month) {
      // Reaches another month
      this.add_history(history, instantly_save_to_disk);
    } else {
      // Still in this month
      this.history_this_month.splice(insert_position, 0, history);
      this.cached_plain_history.push([history.label, history.link]);

      if (instantly_save_to_disk) {
        this.save_month_to_disk();
      }
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
   * @param indices A number[] array, indicating the indices of the items to be deleted.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_history_at_indices(year: number, month: number, indices: number[], instantly_save_to_disk: boolean) {

    // Opens the month required
    this.open_month_from_disk(year, month, false);

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
    for (let i = 0; i < Math.min(this.history_this_month.length, this.plain_history_default_max_length); i++) {
      this.cached_plain_history.push([this.history_this_month[i].label, this.history_this_month[i].link]);
    }
  }

  // External interaction

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
      console.log('[Meow][bunch_of_history] Check disk of month: E: /history folder already exists.')
      new_history = false;
    }

    let history_year_month_path = this.history_path_of_month(year, month);

    if (new_history) {
      // no history before, like the first use of entire app
      console.log("[Meow][bunch_of_history] Check disk of month: NO HISTORY EVER BEFORE! Creating an empty one.");
      sandbox_save(history_year_month_path, '');
    } else {
      // check if this month have a history
      let this_month_history = sandbox_open_sync(history_year_month_path);
      if (this_month_history as string == "undefined") {
        // This month doesn't have a history file
        console.log("[Meow][bunch_of_history] Check disk of month: NO HISTORY FOR " +
        this.year_month_to_string(year, month) + ', creating an empty one.');
        sandbox_save(history_year_month_path, '');
      } else {
        // This month has an existing history file
        console.log("[Meow][bunch_of_history] Check disk of month: Found existing history for this month " +
        this.year_month_to_string(year, month) + "!");
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
   * Connects a year and a month to string.
   * @param year A number, the year.
   * @param month A number, the month.
   * @returns A string, in the format (year - month).
   * */
  year_month_to_string(year: number, month: number) {
    return "(" + year.toString() + " - " + month.toString() + ")"
  }

  /**
   * Lists all the months in which ther are history records made.
   * @returns A number[][] array, e.g. [[2024, 2], [2023, 4], ...].
   * */
  get_available_months() {
    this.check_disk_month(new Date().getFullYear(), new Date().getMonth() + 1);
    let result: number[][] = [];
    let filesDir = getContext().filesDir;
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
    if (imp.split("\n").length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history] Import history Error: not 3*n length. Raw string: \n" + imp)
      return;
    }

    // Clear
    this.history_this_month = [];

    let import_list: string[] = imp.split("\n");
    let last_month = [0, 0];
    for (let index = 0; index < import_list.length; index += 3) {
      if (import_list[index] != "") {
        let access_time = Number.parseInt(import_list[index+2]);
        let access_Date = new Date(access_time);
        let new_month = [new Date(access_time).getFullYear(), new Date(access_time).getMonth() + 1];

        if ((last_month[0] != new_month[0]) || (last_month[1] != new_month[1])) {
          // if changed month, then save this file
          if ((last_month[0] != 0) && (last_month[1] != 0)) {
            console.log('[Meow][bunch_of_history] Import history saved month ' + last_month.toString() + 'to disk.');
            this.save_month_to_disk();
            this.history_this_month = []; // I believe this should be added
          }
        }

        let new_history_record = new history_record(import_list[index], import_list[index+1], access_time);
        this.add_history(new_history_record, false);

        last_month = [access_Date.getFullYear(), access_Date.getMonth() + 1];
      }
    }
    this.save_month_to_disk();
    console.log("[Meow][bunch_of_history] Import history success!")
  }
}
