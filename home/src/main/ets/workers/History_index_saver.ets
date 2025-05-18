import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { bunch_of_history_index } from '../hosts/bunch_of_history_index';
import { sandbox_save } from '../utils/storage_tools';
import { fileIo } from '@kit.CoreFileKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let map: collections.Map<string, collections.Array<number>>;
let file_name: string;
let filesDir: string;
/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  if (typeof event.data == "string") {
    // receive information from main thread.
    const data = event.data.split(":");
    const header = data[0];
    const content = data[1];
    // set options
    if (header == 'filesDir') {
      filesDir = content;
    } else if (header == 'file_name') {
      file_name = content;
    }
  } else {
    // Receives the map. LETS GOO!~
    map = event.data;

    // Save to disk
    save_index_ext(file_name, map, filesDir);

    // Report finish
    workerPort.postMessage("done");
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
 * @param map
 * @param context_filesDir
 * */
function save_index_ext(file_name: string, map: collections.Map<string, collections.Array<number>>, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let result: string[] = [];
  let index = 0;

  // TODO: Update this worker to adapt to the monthly division style of maps.
  // Clear all previous index
  try {
    fileIo.rmdirSync(context_filesDir + "/history-index");
    fileIo.mkdirSync(context_filesDir + "/history-index");
  } catch (e) {

  }

  // Timer
  let s = Date.now();
  console.log(bunch_of_history_index.log_head_worker() + '[Save] Start to save map "' + file_name + '"! Map size: ' + map.size.toString() + ".")

  map.forEach((value, key) => {
    result.push(key)
    result.push(value.join("_"));
    // Report status
    if (index % 1000 == 0) {
      const progress = index / map.size * 100;
      workerPort.postMessage((Date.now() - s).toString() + " ms, " + (progress.toFixed(2) + "%"));
    }
    index += 1;
  })

  console.log(bunch_of_history_index.log_head_worker() + '[Save] Finish forEach traversal! Time used: ' + (Date.now() - s).toString() + " ms.")

  // console.log("qwq " + result.toString())
  sandbox_save('history-index/' + file_name, result.join('\n'), filesDir);
  workerPort.postMessage((Date.now() - s).toString() + " ms, 100%");

  // Timer end
  console.log(bunch_of_history_index.log_head_worker() + "[Save] Finished saving to disk in " + (Date.now() - s).toString() + " ms.")
}