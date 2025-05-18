import { sandbox_open_sync } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';
import { collections } from '@kit.ArkTS';
import { divide_string } from './bunch_of_history_index_x_functions';

export class bunch_of_history_index_add_history_only {
  static index_map: collections.Map<string, collections.Array<number>> = new collections.Map<string, collections.Array<number>>();

  constructor() {
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
    bunch_of_history_index_add_history_only.index_map = new collections.Map<string, collections.Array<number>>();
  }

  static add_index_history_file(path: string, context_filesDir?: string) {
    let imp = sandbox_open_sync(path, context_filesDir);
    let import_list: string[] = imp.split("\n");
    if (import_list.length <= 1) {
      console.info(bunch_of_history_index_add_history_only.log_head() + " Import history SKIPPED: Too short. (" + path + ").");
      return;
    }
    if (import_list.length % 3 > 0) {
      console.error("[ERROR]" + bunch_of_history_index_add_history_only.log_head() + " Import history Error: not 3*n length. Raw string: \n" + imp);
      return;
    }
    for (let index = 0; index < import_list.length; index += 3) {
      let access_time = parseInt(import_list[index+2]);
      bunch_of_history_index_add_history_only.add_index_string(import_list[index] + " " + import_list[index+1], access_time);
    }
  }

  static add_index_string(str: string, timestamp: number) {
    // Divide into words
    let all_words = divide_string(str.toUpperCase());
    for (const item of all_words) {
      if (bunch_of_history_index_add_history_only.index_map.has(item)) {
        // console.log(bunch_of_history_index_indexer_only.index_map.get(item)?.toString());
        bunch_of_history_index_add_history_only.index_map.get(item)!.push(timestamp);
      } else {
        bunch_of_history_index_add_history_only.index_map.set(item, new collections.Array<number>(timestamp));
      }
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