import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { bunch_of_history_index } from '../hosts/bunch_of_history_index';
import { sandbox_save, sandbox_unlink_sync } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  // receive getContext().filesDir from main thread
  // history_index_host = event.data;
  if (typeof event.data == "string") {
    let filesDir = event.data as string;
    // Execution
    rebuild_full_history_index_sync(filesDir);
    // worker线程向宿主线程发送信息
    workerPort.postMessageWithSharedSendable(bunch_of_history_index.index_map);
  }
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessageerror = (event: MessageEvents) => {
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param event error message
 */
workerPort.onerror = (event: ErrorEvent) => {
};


/**
 * Builds index for all history and saves (overwrites) the index file onto disk.
 *
 * THIS IS A SYNC FUNCTION
 * */
function rebuild_full_history_index_sync(context_filesDir?: string) {
  let s = Date.now();
  console.log(bunch_of_history_index.log_head_worker() + ' Start rebuilding full index! Start: ' +
  new Date(s).toString())

  // Remove original
  try {
    sandbox_unlink_sync('history-index/index.txt', context_filesDir);
  } catch (e) {
  }
  bunch_of_history_index.clear();

  // Get all months
  let months = get_history_months_no_create_this_month(context_filesDir);

  for (let index = 0; index < months.length; index++) {
    const month = months[index];
    bunch_of_history_index.add_index_file(history_path_of_month(month[0], month[1]), context_filesDir);

    // Report status
    const progress = index / months.length * 100;
    workerPort.postMessage((Date.now() - s).toString() + "ms, " + progress.toFixed(2) + "%");
    // console.log("[Meow][bunch_of_history_index] Index progress: " + progress.toFixed(2) + "%");
  }

  // for (let i = 0; i < 10e7; i++) {
  // }

  // Save to disk
  console.log(bunch_of_history_index.log_head_worker() + " Map size: " +
  bunch_of_history_index.index_map.size.toString());
  save_index_ext(bunch_of_history_index.index_map, context_filesDir);
  sandbox_save('history-index/indexer_version.txt', "1", context_filesDir);

  // Timer & logs
  console.log(bunch_of_history_index.log_head_worker() + ' Finish full index! Time used: ' +
  ((Date.now() - s) / 1000).toString() + "s.")
  workerPort.postMessage((Date.now() - s).toString() + "ms, 100%");
}


// Functions borrowed from bunch_of_history
// to avoid error when bunch_of_history is not even initialized
// TODO: Find a more elegant way of doing this

/**
 * Lists all the months in which ther are history records made, in ascending order.
 * @returns A number[][] array, e.g. [[2023, 2], [2023, 3], [2023, 4], ...].
 * */
function get_history_months_no_create_this_month(context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
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
  result = result.sort((a, b) => (a[0] * 12 + a[1]) - (b[0] * 12 + b[1]));
  console.log(bunch_of_history_index.log_head_worker() + ' Got_available_months. Result: ' + result.join(' ') + '.')
  return result;
}

/**
 * Constructs the file name of history records in which history in [year, month] should be.
 * @param year A number, the year, like 2024.
 * @param month A number, the month, like 12.
 * @returns A string, 'history/history_year_month.txt'
 * */
function history_path_of_month(year: number, month: number) {
  let month_unified = month.toString();
  if (month_unified.length == 1) {
    month_unified = '0' + month_unified;
  }
  return 'history/history_' + year.toString() + "_" + month_unified + '.txt';
}

/**
 * Saves index set to sandbox
 * @param set
 * @param context_filesDir
 * */
function save_index_ext(set: collections.Map<string, collections.Array<number>>, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let result: string[] = [];
  set.forEach((value, key) => {
    result.push(key)
    result.push(value.join("_"));
  })
  // console.log("qwq " + result.toString())
  sandbox_save('history-index/index.txt', result.join('\n'), filesDir);
}