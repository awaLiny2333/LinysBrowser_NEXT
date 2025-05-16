import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { bunch_of_history_index } from '../hosts/bunch_of_history_index';
import { sandbox_open_sync } from '../utils/storage_tools';

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
 * Loads built index from disk.
 * */
function sandbox_load_index_sync(context_filesDir?: string) {
  let data_raw = sandbox_open_sync('history-index/index.txt', context_filesDir);
  if (data_raw == 'undefined') {
    console.log(bunch_of_history_index.log_head_worker() + ' No index found. ')
    // console.log(bunch_of_history_index.log_head_worker() + ' Rebuilding... ')
    // history_index_full_rebuild_worker();
    return;
  }
  let s = Date.now();
  console.log(bunch_of_history_index.log_head_worker() + ' Start loading from sandbox! Start: ' +
  new Date(s).toString())
  let data = data_raw.split("\n");
  // replace
  bunch_of_history_index.clear();
  // read and load
  for (let index = 0; index < data.length - 1; index = index + 2) {
    const key = data[index];
    let values = data[index+1].split("_");
    let num_values = new collections.Array<number>();
    for (let i = 0; i < values.length; i++) {
      num_values.push(parseInt(values[i]));
    }
    bunch_of_history_index.index_map.set(key, num_values);

    // Report status
    if (index % 1000 == 0) {
      const progress = index / data.length * 100;
      workerPort.postMessage((Date.now() - s).toString() + "ms, " + progress.toFixed(2) + "%");
      // console.log(bunch_of_history_index.log_head_worker() + " Loading from sandbox progress: " + progress.toFixed(2) + "%");
    }
  }
  console.log(bunch_of_history_index.log_head_worker() + ' Finish loading from sandbox! Time used: ' +
  (Date.now() - s).toString() + "ms. Index map size: " + bunch_of_history_index.index_map.size.toString());

  workerPort.postMessage((Date.now() - s).toString() + "ms, 100%");
}