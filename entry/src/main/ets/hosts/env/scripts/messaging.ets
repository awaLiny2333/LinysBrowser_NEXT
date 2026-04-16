import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meowAppMessageType, meowAppMessage, meowAppStatuses } from "../classes/meowAppStatuses";

/**
 * Send a global message to the entire app.
 * @param type The type of the message.
 * @param content The content of the message.
 */
export function globalMessage(type: meowAppMessageType, content: string = '') {
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  myApp.crossAppMessageTunnel = new meowAppMessage(type, content);
}
