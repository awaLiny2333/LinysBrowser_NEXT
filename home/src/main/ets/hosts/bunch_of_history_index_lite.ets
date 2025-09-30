import { sandbox_read_text_sync } from '../utils/storage_tools';
import { collections } from '@kit.ArkTS';
import { history_path_of_month, index_file_name_of_month, index_path_of_month } from './bunch_of_history_index_x_functions';
import { divide_string, insert_into_array } from '../utils/data_operation_tools';

export class bunch_of_history_index_lite {
  static index_map: collections.Map<string, collections.Array<number>> = new collections.Map<string, collections.Array<number>>();
  static this_month: number;
  static this_year: number;

  /**
   * This bunch_of_history_index could only clear and push data in a sorted manner.
   * */
  constructor() {
  }

  /**
   * Clears index by setting it a new empty Map.
   * */
  static clear() {
    bunch_of_history_index_lite.index_map = new collections.Map<string, collections.Array<number>>();
  }

  /**
   * Returns the opened file name of this lite index.
   * @returns the file name
   * */
  static this_file_name(): string {
    return index_file_name_of_month(bunch_of_history_index_lite.this_year, bunch_of_history_index_lite.this_month);
  }

  /**
   * Index from history file.
   * @param path the path of history file, for example, 'history/history_2002_12.txt'.
   * @param context_filesDir getContext().filesDir.
   * */
  static index_from_history_month_file(year: number, month: number, context_filesDir: string) {
    // Set year and month
    bunch_of_history_index_lite.this_year = year;
    bunch_of_history_index_lite.this_month = month;

    // Open the file
    let path = history_path_of_month(year, month);
    let imp = sandbox_read_text_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");

    // Skip errors
    if (import_list.length <= 1) {
      console.info(bunch_of_history_index_lite.log_head() + " Import history SKIPPED: Too short. (" + path + ").");
      return;
    }
    if (import_list.length % 3 > 0) {
      console.error("[ERROR]" + bunch_of_history_index_lite.log_head() + " Import history Error: not 3*n length. Raw string: \n" + imp);
      return;
    }

    // Traverse
    for (let index = 0; index < import_list.length; index += 3) {
      let access_time = parseInt(import_list[index+2]);
      let content = import_list[index] + " " + import_list[index+1];
      bunch_of_history_index_lite.add_index_string(content, access_time);
    }
  }

  /**
   * Index from built index file.
   * @param path the path of index file, for example, 'history-index/index_2002_12.txt'.
   * @param context_filesDir getContext().filesDir.
   * */
  static index_from_index_month_file(year: number, month: number, context_filesDir: string) {
    // Set year and month
    bunch_of_history_index_lite.this_year = year;
    bunch_of_history_index_lite.this_month = month;

    // Open the file
    let path = index_path_of_month(year, month);
    let imp = sandbox_read_text_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");

    if (import_list.length <= 1) {
      console.info(bunch_of_history_index_lite.log_head() + " Import index SKIPPED: Too short. (" + path + ").");
      return;
    }

    // traverse each key - values
    for (let index = 0; index < import_list.length - 1; index += 2) {
      const key = import_list[index];
      const values = import_list[index+1].split("_");

      // TODO: Improve logics here to boost efficiency!
      for (let j = 0; j < values.length; j++) {
        bunch_of_history_index_lite.add_index_key_string(key, parseInt(values[j]));
      }
    }
  }

  /**
   * Pushes a timestamp to the end of values of str (keys).
   * @param str the keys.
   * @param timestamp the timestamp.
   * */
  static add_index_string(str: string, timestamp: number) {
    const target_year: number = new Date(timestamp).getUTCFullYear();
    const target_month: number = new Date(timestamp).getUTCMonth() + 1;
    if (index_file_name_of_month(target_year, target_month) != bunch_of_history_index_lite.this_file_name()) {
      // This could happen when system time is manually changed.
      // DONT DO THIS IN YOUR DAILY USE PLZ.
      const this_year_month: string = bunch_of_history_index_lite.this_year.toString() + ' - ' + bunch_of_history_index_lite.this_month.toString();
      const target_year_month: string = target_year.toString() + ' - ' + target_month.toString();
      console.log(bunch_of_history_index_lite.log_head() +
        ' Adding history to another month (' + target_year_month + ') but current month loaded is ' + this_year_month + '! Interrupted add_index_string.');
      return;
    }

    // Divide into words
    let all_words = divide_string(str.toUpperCase());

    // Traverse and add
    for (const item of all_words) {
      if (bunch_of_history_index_lite.index_map.has(item)) {
        let got_array = bunch_of_history_index_lite.index_map.get(item)!;
        let old_last = got_array[got_array.length-1];
        if (timestamp < old_last) {
          console.log(bunch_of_history_index_lite.log_head() + ' Adding new index (' + timestamp + ') earlier than the old ones (' + old_last + ')??? How???');
        } else {
          got_array.push(timestamp);
        }
      } else {
        bunch_of_history_index_lite.index_map.set(item, new collections.Array<number>(timestamp));
      }
    }
  }

  /**
   * Pushes a timestamp to the correct position of values of str (keys).
   * @param str the keys.
   * @param timestamp the timestamp.
   * */
  static add_index_string_full(str: string, timestamp: number) {
    const target_year: number = new Date(timestamp).getUTCFullYear();
    const target_month: number = new Date(timestamp).getUTCMonth() + 1;
    if (index_file_name_of_month(target_year, target_month) != bunch_of_history_index_lite.this_file_name()) {
      // This could happen when system time is manually changed.
      // DONT DO THIS IN YOUR DAILY USE PLZ.
      const this_year_month: string = bunch_of_history_index_lite.this_year.toString() + ' - ' + bunch_of_history_index_lite.this_month.toString();
      const target_year_month: string = target_year.toString() + ' - ' + target_month.toString();
      console.log(bunch_of_history_index_lite.log_head() +
        ' Adding history to another month (' + target_year_month + ') but current month loaded is ' + this_year_month + '! Interrupted add_index_string_full.');
      return;
    }

    // Divide into words
    let all_words = divide_string(str.toUpperCase());

    // Traverse and add
    for (const item of all_words) {
      let original = bunch_of_history_index_lite.index_map.get(item) || new collections.Array<number>();
      // concat it in ascending order
      bunch_of_history_index_lite.index_map.set(item, insert_into_array(original, timestamp));
      // bunch_of_history_index.index_map.get(item)?.push(timestamp);
    }
  }

  /**
   * Pushes a timestamp to the end of the values of key (only ONE key).
   * @param key the key, for example, "BING".
   * @param timestamp the timestamp of history record to be linked to.
   * */
  static add_index_key_string(key: string, timestamp: number) {
    if (bunch_of_history_index_lite.index_map.has(key)) {
      // console.log(bunch_of_history_index.index_map.get(item)?.toString());
      bunch_of_history_index_lite.index_map.get(key)!.push(timestamp);
    } else {
      bunch_of_history_index_lite.index_map.set(key, new collections.Array<number>(timestamp));
    }
  }

  /**
   * The head of logging information.
   * @returns "[Meow][bunch_of_history_index_indexer_only]"
   * */
  static log_head() {
    return '[Meow][bunch_of_history_index_indexer_only]';
  }

  /**
   * The head of logging information for workers.
   * @returns "[Meow][bunch_of_history_index]"
   * */
  static log_head_worker() {
    return '[Meow][bunch_of_history_index_add_only][Worker]';
  }
}