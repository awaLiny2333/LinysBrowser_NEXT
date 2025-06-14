import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { sandbox_save } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';
import { bunch_of_history_index_lite as host } from '../hosts/bunch_of_history_index_lite';

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
    // Report done
    workerPort.postMessage('done');
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
function rebuild_full_history_index_sync(context_filesDir: string) {
  let s = Date.now();
  console.log(host.log_head_worker() + ' Start rebuilding full index! Start: ' + new Date(s).toString() + '.')

  // Clear all previous index
  try {
    fs.rmdirSync(context_filesDir + "/history-index");
    fs.mkdirSync(context_filesDir + "/history-index");
  } catch (e) {

  }

  // Get all months
  let months = get_history_months_no_create_this_month(context_filesDir);

  // Read month by month
  for (let index = 0; index < months.length; index++) {
    host.clear();

    // Index
    const year_month = months[index];
    // bunch_of_history_index.add_index_history_file(file_path, context_filesDir);
    host.index_from_history_month_file(year_month[0], year_month[1], context_filesDir);

    // Save to disk
    console.log(host.log_head_worker() + ' Indexing month: ' + year_month.toString() + '. Map size: ' + host.index_map.size.toString() + '.');

    let month_field: string = year_month[1].toString();
    if (year_month[1].toString().length == 1) {
      // is a single digit
      // This works until human have over 99 months a year, perhaps.
      month_field = "0" + year_month[1].toString();
    }
    save_index_ext("index_" + year_month[0] + "_" + month_field + "_00_00_00_00_000.txt", host.index_map, context_filesDir);

    // Report status
    const progress = index / months.length * 100;
    workerPort.postMessage((Date.now() - s).toString() + " ms, " + progress.toFixed(2) + "%");
    // console.log("[Meow][bunch_of_history_index] Index progress: " + progress.toFixed(2) + "%");
  }

  // save indexer version for future use
  // perhaps?
  sandbox_save('last_indexer_version.txt', "1", context_filesDir);

  // Timer & logs
  console.log(host.log_head_worker() + ' Finish full index! Time used: ' + ((Date.now() - s) / 1000).toString() + "s.")
  workerPort.postMessage((Date.now() - s).toString() + " ms, 100%");
}

// Functions borrowed from bunch_of_history
// to avoid error when bunch_of_history is not even initialized
// TODO: Find a more elegant way of doing this

/**
 * Lists all the months in which ther are history records made, in ascending order.
 * @returns A number[][] array, e.g. [[2023, 2], [2023, 3], [2023, 4], ...].
 * */
function get_history_months_no_create_this_month(context_filesDir: string) {
  let filesDir: string = context_filesDir;
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
  console.log(host.log_head_worker() + ' Got_available_months. Result: ' + result.join(' ') + '.')
  return result;
}

/**
 * Saves index set to sandbox
 * @param index_name the file name of this index slice. For example, 'index_2023_02_01_23_55_11_020.txt'.
 * @param set
 * @param context_filesDir
 * */
function save_index_ext(index_name: string, set: collections.Map<string, collections.Array<number>>, context_filesDir: string) {
  let filesDir: string = context_filesDir;
  let result: string[] = [];
  set.forEach((value, key) => {
    result.push(key)
    result.push(value.join("_"));
  })
  // console.log("qwq " + result.toString())
  sandbox_save('history-index/' + index_name, result.join('\n'), filesDir);
}