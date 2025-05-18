import { sandbox_open_sync, sandbox_save } from '../utils/storage_tools';
import { fileIo, fileIo as fs } from '@kit.CoreFileKit';
import { collections } from '@kit.ArkTS';
import { history_record } from './bunch_of_history';
import {
  divide_string,
  get_history_from_disk,
  history_index_full_rebuild_worker,
  history_index_load_from_disk_worker,
  index_file_name_of_month,
  index_path_of_month
} from './bunch_of_history_index_x_functions';
import { bunch_of_history_index_lite } from './bunch_of_history_index_lite';

export class bunch_of_history_index {
  static index_map: collections.Map<string, collections.Array<number>> = new collections.Map<string, collections.Array<number>>();

  constructor() {
    // Create history index folder
    try {
      let filesDir = getContext().filesDir;
      fs.mkdirSync(filesDir + '/history-index');
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
      console.log(bunch_of_history_index.log_head() +
        " A history_index_saving task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }
    if (history_index_loading == true) {
      console.log(bunch_of_history_index.log_head() +
        " A history_index_loading task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }
    if (reindexing == true) {
      console.log(bunch_of_history_index.log_head() +
        " A reindexing task is ongoing! Interrupted this search_history_label_link.");
      return [];
    }

    let stamps = bunch_of_history_index.search_timestamps(key, max);
    let result = get_history_from_disk(stamps, max);

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
   * Index from history file.
   * @param path the path of history file, for example, 'history/history_2002_12.txt'.
   * @param context_filesDir getContext().filesDir.
   * */
  static index_from_history_file(path: string, context_filesDir?: string) {
    let imp = sandbox_open_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");
    if (import_list.length % 3 > 0) {
      console.error("[ERROR]" + bunch_of_history_index.log_head() +
        " Import history Error: not 3*n length. Raw string: \n" + imp);
      return;
    }
    for (let index = 0; index < import_list.length; index += 3) {
      let access_time = parseInt(import_list[index+2]);
      bunch_of_history_index.add_index_string(import_list[index] + " " + import_list[index+1], access_time);

      // if (index % 100 == 0) {
      //   const progress = index / import_list.length * 100;
      //   console.log(log_head() + "Index sub progress: " + progress.toFixed(2) + "%");
      // }
    }
  }

  /**
   * Index from built index file.
   * @param path the path of index file, for example, 'history-index/index_2002_12.txt'.
   * @param context_filesDir getContext().filesDir.
   * */
  static index_from_index_file(path: string, context_filesDir?: string) {
    // Open the file
    let imp = sandbox_open_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");

    // traverse each key - values
    for (let index = 0; index < import_list.length - 1; index += 2) {
      const key = import_list[index];
      const values = import_list[index+1].split("_");

      // TODO: Improve logics here to boost efficiency!
      for (let j = 0; j < values.length; j++) {
        bunch_of_history_index.add_index_key_string(key, parseInt(values[j]));
      }
    }
  }

  static add_index_histories(histories: history_record[]) {
    for (let index = 0; index < histories.length; index++) {
      bunch_of_history_index.add_index_history(histories[index]);
    }
  }

  static add_index_history(history: history_record) {
    bunch_of_history_index.add_index_string(history.label + " " + encodeURI(history.link), history.accessed_time);
  }

  static add_index_string(str: string, timestamp: number) {
    const current_year: number = new Date(timestamp).getUTCFullYear();
    const current_month: number = new Date(timestamp).getUTCMonth() + 1;
    if (index_file_name_of_month(current_year, current_month) != bunch_of_history_index_lite.this_file_name()) {
      // This could happen when system time is manually changed.
      // DONT DO THIS IN YOUR DAILY USE PLZ.
      return;
    }

    // Divide into words
    let all_words = divide_string(str.toUpperCase());

    // Traverse and add
    for (const item of all_words) {
      if (bunch_of_history_index.index_map.has(item)) {
        bunch_of_history_index.index_map.get(item)!.push(timestamp);
      } else {
        bunch_of_history_index.index_map.set(item, new collections.Array<number>(timestamp));
      }
    }
  }

  static add_index_key_string(key: string, timestamp: number) {
    if (bunch_of_history_index.index_map.has(key)) {
      // console.log(bunch_of_history_index.index_map.get(item)?.toString());
      bunch_of_history_index.index_map.get(key)!.push(timestamp);
    } else {
      bunch_of_history_index.index_map.set(key, new collections.Array<number>(timestamp));
    }
  }

  static add_index_string_full(str: string, timestamp: number) {
    // Divide into words
    let all_words = divide_string(str.toUpperCase());
    for (const item of all_words) {
      let original = bunch_of_history_index.index_map.get(item) || new collections.Array<number>();
      // concat it in ascending order
      bunch_of_history_index.index_map.set(item, bunch_of_history_index.insert_into_array(original, timestamp));
      // bunch_of_history_index.index_map.get(item)?.push(timestamp);
    }
  }

  /**
   * Inserts a number into given array in ascending order
   * @param arr the array
   * @param new_num the new number
   * @returns a new array of result
   * @author Generated by DeepSeek on 14th May, 2025, modified by awa_Liny
   * */
  static insert_into_array(arr: collections.Array<number>, new_num: number): collections.Array<number> {
    let left = 0;
    let right = arr.length;

    // 二分查找插入位置
    while (left < right) {
      const mid = Math.floor((left + right) / 2);
      if (arr[mid] < new_num) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    // 创建新数组（原数组保持不变）
    return new collections.Array<number>(...arr.slice(0, left), new_num, ...arr.slice(left));
  }

  /**
   * Returns the intersection of two array of unique, ascending numbers, in O(m+n)
   *
   * 双指针法求两个有序数组的交集（O(m+n)）
   * @param a the first number[]
   * @param b the other number[]
   * @returns their intersection
   * @author Generated by DeepSeek on 14th May, 2025, modified by awa_Liny
   * */
  static intersect(a: number[], b: number[]): number[] {
    let res: number[] = [];
    let i = 0, j = 0;

    while (i < a.length && j < b.length) {
      if (a[i] === b[j]) {
        // 确保不重复（根据题意数组本身无重复）
        res.push(a[i]);
        i++;
        j++;
      } else if (a[i] < b[j]) {
        i++;
      } else {
        j++;
      }
    }

    return res;
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
    for (const val of baseArray) {
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