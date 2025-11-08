import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { arrayBuffer_2_sendable_pixelMap, sandbox_read_arrayBuffer } from '../utils/storage_tools';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let pathDir: string = '';

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = async (event: MessageEvents) => {
  if (typeof event.data == 'string') {
    // Is pathDir
    pathDir = event.data as string;
  }
  // Start
  console.log("[Meow][meowAppSettings] Start loading homepage background!");
  sandbox_read_arrayBuffer('homepage_background_arrayBuffer', pathDir)?.then((homepage_background_array_buffer) => {
    console.log("[Meow][meowAppSettings] Finished reading homepage background!");
    if (homepage_background_array_buffer) {
      arrayBuffer_2_sendable_pixelMap(homepage_background_array_buffer).then((pm) => {
        console.log("[Meow][meowAppSettings] Finished processing homepage background!");
        workerPort.postMessageWithSharedSendable(pm);
      })
    }
  });
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