import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { bunch_of_history_index } from '../hosts/bunch_of_history_index';
import { sandbox_save } from '../utils/storage_tools';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let map: collections.Map<string, collections.Array<number>>;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  if (typeof event.data == "string") {
    // receive getContext().filesDir from main thread. LETS GOO!~
    let filesDir = event.data as string;

    // Timer start
    let s = Date.now();

    // Save to disk
    console.log(bunch_of_history_index.log_head_worker() + " Map size: " + map.size.toString());

    save_index_ext(map, filesDir);

    // Timer end
    console.log(bunch_of_history_index.log_head_worker() + "[Save] Finished saving to disk in " +
    (Date.now() - s).toString() + "ms.")

    workerPort.postMessage("done");
  } else {
    map = event.data;
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
 * Saves index set to sandbox
 * @param set
 * @param context_filesDir
 * */
function save_index_ext(set: collections.Map<string, collections.Array<number>>, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let result: string[] = [];
  let index = 0;

  // Timer
  let s = Date.now();

  set.forEach((value, key) => {
    result.push(key)
    result.push(value.join("_"));
    // Report status
    if (index % 1000 == 0) {
      const progress = index / set.size * 100;
      workerPort.postMessage((Date.now() - s).toString() + "ms, " + (progress.toFixed(2) + "%"));
    }
    index += 1;
  })
  // console.log("qwq " + result.toString())
  sandbox_save('history-index/index.txt', result.join('\n'), filesDir);
  workerPort.postMessage((Date.now() - s).toString() + "ms, 100%");
}