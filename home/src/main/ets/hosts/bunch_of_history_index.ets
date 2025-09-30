import { sandbox_read_text_sync } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';
import { collections } from '@kit.ArkTS';
import { get_histories_from_disk, index_file_name_of_month } from './bunch_of_history_index_x_functions';
import { bunch_of_history_index_lite } from './bunch_of_history_index_lite';
import { meowContext } from '../utils/environment_tools';
import { divide_string, insert_into_array } from '../utils/data_operation_tools';

export class bunch_of_history_index {
  static index_map: collections.Map<string, collections.Array<number>> = new collections.Map<string, collections.Array<number>>();

  constructor() {
    // Create history index folder
    try {
      fs.mkdirSync(meowContext().filesDir + '/history-index');
    } catch (e) {
      // console.log(log_head() + 'Check disk of month: E: /history-index folder already exists.')
    }
  }

  /**
   * Clears index by setting it a new empty Map.
   * */
  static clear() {
    bunch_of_history_index.index_map = new collections.Map<string, collections.Array<number>>();
  }

  /**
   * Searches in the index_map and return eligible history of label-links
   * @param key the keywords, for example "huawei developers harmony"
   * @returns string[][] of label-links
   * */
  static search_history_label_link(key: string, max?: number) {
    let history_index_saving = AppStorage.get('history_index_saving') as boolean | undefined;
    let history_index_loading = AppStorage.get('history_index_loading') as boolean | undefined;
    let reindexing = AppStorage.get('reindexing_history') as boolean | undefined;

    if (history_index_saving == true) {
      console.log(bunch_of_history_index.log_head() + " A history_index_saving task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }
    if (history_index_loading == true) {
      console.log(bunch_of_history_index.log_head() + " A history_index_loading task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }
    if (reindexing == true) {
      console.log(bunch_of_history_index.log_head() + " A reindexing task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }

    // TODO: find a more elegant way instead of reverse().
    let stamps = bunch_of_history_index.search_timestamps(key, max);
    stamps.reverse();
    let result = get_histories_from_disk(stamps, max);
    result.reverse();
    return result;
  }

  /**
   * Searches in the index_map and return eligible timestamps
   * @param key the keywords, for example "huawei developers harmony"
   * @returns number[] of timestamps
   * */
  static search_timestamps(key: string, max?: number) {
    let div_keys = divide_string(key);
    // console.log("[qwq]" + div_keys.toString());
    let ranges: collections.Array<collections.Array<number>> = new collections.Array<collections.Array<number>>();

    for (const key of div_keys) {
      // Pushes it
      ranges.push(bunch_of_history_index.index_map.get(key) || new collections.Array<number>());
      // console.log("[awa]" + (bunch_of_history_index.index_map.get(key) || []).toString());
    }
    // console.log(log_head() + "Found ranges of keys: " + ranges.join(" "));
    return bunch_of_history_index.findCommonElements(ranges, max);
  }

  /**
   * Index from built index file.
   * @param path the path of index file, for example, 'history-index/index_2002_12.txt'.
   * @param context_filesDir getContext().filesDir.
   * */
  static index_from_index_file(path: string, context_filesDir: string) {
    // Open the file
    let imp = sandbox_read_text_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");

    // traverse each key - values
    for (let index = 0; index < import_list.length - 1; index += 2) {
      const key = import_list[index];
      const values = import_list[index+1].split("_");

      // TODO: Improve logics here to boost efficiency!
      for (let j = 0; j < values.length; j++) {
        bunch_of_history_index.add_index_key_string(key, parseInt(values[j]), false);
      }
    }
  }

  /**
   * Pushes a timestamp to the end of values of str (keys).
   * @param key the SINGLE, SPECIFIC key.
   * @param timestamp the timestamp.
   * @param check_month set true to check if this action fits in the currently opened month in bunch_of_history_index_lite.
   * */
  static add_index_key_string(key: string, timestamp: number, check_month: boolean) {
    if (check_month) {
      const current_year: number = new Date(timestamp).getUTCFullYear();
      const current_month: number = new Date(timestamp).getUTCMonth() + 1;
      if (index_file_name_of_month(current_year, current_month) != bunch_of_history_index_lite.this_file_name()) {
        // This could happen when system time is manually changed.
        // DONT DO THIS IN YOUR DAILY USE PLZ.
        return;
      }
    }

    if (bunch_of_history_index.index_map.has(key)) {
      // console.log(bunch_of_history_index.index_map.get(item)?.toString());
      // bunch_of_history_index.index_map.get(key)!.push(timestamp);

      let got_array = bunch_of_history_index.index_map.get(key)!;
      let old_last = got_array[got_array.length-1];
      if (timestamp < old_last) {
        console.log(bunch_of_history_index.log_head() + ' Adding new index (' + timestamp + ') earlier than the old ones (' + old_last + ')??? How???');
      } else {
        got_array.push(timestamp);
      }
    } else {
      bunch_of_history_index.index_map.set(key, new collections.Array<number>(timestamp));
    }
  }

  /**
   * Pushes a timestamp to the correct position of values of str (keys).
   * @param str the keys.
   * @param timestamp the timestamp.
   * */
  static add_index_string_full(str: string, timestamp: number) {
    // Divide into words
    let all_words = divide_string(str.toUpperCase());

    // Traverse and add
    for (const item of all_words) {
      let original = bunch_of_history_index.index_map.get(item) || new collections.Array<number>();
      // concat it in ascending order
      bunch_of_history_index.index_map.set(item, insert_into_array(original, timestamp));
      // bunch_of_history_index.index_map.get(item)?.push(timestamp);
    }
  }

  /**
   * Returns the common elements appearing in arrays of unique numbers in ascending orders.
   * @param ranges the arrays
   * @returns another array
   * @author Generated by DeepSeek on 16th May, 2025, modified by awa_Liny
   * */
  static findCommonElements(ranges: collections.Array<collections.Array<number>>, max?: number): number[] {
    if (ranges.length === 0) {
      return [];
    }

    // Find the shortest array as the base to minimize iterations
    let baseArray = ranges[0];
    for (const arr of ranges) {
      if (arr.length < baseArray.length) {
        baseArray = arr;
      }
    }

    const result: number[] = [];
    for (let k = baseArray.length - 1; k >= 0; k--) {
      const val = baseArray[k];
      let isCommon = true;

      for (const arr of ranges) {
        if (arr === baseArray) {
          continue;
        } // Skip the base array itself

        if (!bunch_of_history_index.binarySearch(arr, val)) {
          isCommon = false;
          break;
        }
      }
      if (isCommon) {
        result.push(val);
        if (max !== undefined && result.length === max) {
          return result;
        }
      }
    }

    return result;
  }

  /**
   * Helper function to perform binary search
   * @author Generated by DeepSeek on 16th May, 2025, modified by awa_Liny
   * */
  static binarySearch(arr: collections.Array<number>, target: number): boolean {
    let left = 0;
    let right = arr.length - 1;
    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      if (arr[mid] === target) {
        return true;
      } else if (arr[mid] < target) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return false;
  }

  /**
   * The head of logging information.
   * @returns "[Meow][bunch_of_history_index]"
   * */
  static log_head() {
    return '[Meow][bunch_of_history_index]';
  }

  /**
   * The head of logging information for workers.
   * @returns "[Meow][bunch_of_history_index]"
   * */
  static log_head_worker() {
    return '[Meow][bunch_of_history_index][Worker]';
  }
}