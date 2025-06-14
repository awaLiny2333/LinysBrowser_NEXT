import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { bunch_of_history_index } from '../hosts/bunch_of_history_index';
import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_history_index_lite as month_host } from '../hosts/bunch_of_history_index_lite';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  // receive getContext().filesDir from main thread
  if (typeof event.data == "string") {
    // Receive the filesDir
    let filesDir = event.data as string;
    // Execution
    sandbox_load_index_sync(filesDir);
    // Send back information
    let back = new collections.Array<collections.Map<string, collections.Array<number>>>();
    back.push(bunch_of_history_index.index_map);
    back.push(month_host.index_map);
    workerPort.postMessageWithSharedSendable(back);
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
 * Loads built index from disk.
 * */
function sandbox_load_index_sync(context_filesDir: string) {
  let s = Date.now();
  console.log(bunch_of_history_index.log_head_worker() + '[Load] Start loading from sandbox! Start: ' + new Date(s).toString() + '.')

  let all_index_files = fileIo.listFileSync(context_filesDir + '/history-index', { recursion: false }).sort();

  console.log(bunch_of_history_index.log_head_worker() + '[Load][listFileSync] all files: ' + all_index_files.join(", "));

  if (all_index_files.length == 0) {
    console.log(bunch_of_history_index.log_head_worker() + ' No index found. ')
    // console.log(bunch_of_history_index.log_head_worker() + ' Rebuilding... ')
    // history_index_full_rebuild_worker();
    return;
  }

  workerPort.postMessage((Date.now() - s).toString() + " ms, 0.01%");

  // clear
  bunch_of_history_index.clear();

  // Read every file under history-index
  for (let index = 0; index < all_index_files.length; index++) {
    const name = all_index_files[index];

    bunch_of_history_index.index_from_index_file('history-index/' + name, context_filesDir);

    workerPort.postMessage((Date.now() - s).toString() + " ms, " + (index / all_index_files.length * 90).toFixed(2) + "%");
    // console.log(bunch_of_history_index.log_head_worker() + '[Load] Finish loading: ' + name + '.');
  }

  // Load this month to a separate host
  month_host.clear();
  const current_year: number = new Date().getUTCFullYear();
  const current_month: number = new Date().getUTCMonth() + 1;
  month_host.index_from_index_month_file(current_year, current_month, context_filesDir);

  // End report
  console.log(bunch_of_history_index.log_head_worker() + '[Load] Finish loading from sandbox! Time used: ' + (Date.now() - s).toString() + ' ms. ' +
    'Map size: ' + bunch_of_history_index.index_map.size.toString() + '.');

  workerPort.postMessage((Date.now() - s).toString() + " ms, 100%");
}