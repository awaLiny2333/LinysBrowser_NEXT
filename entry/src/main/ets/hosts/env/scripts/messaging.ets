import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meowAppMessage } from "../classes/meowAppMessage";
import lazy { meowAppStatuses } from "../classes/meowAppStatuses";
import lazy { meowUiStatuses } from "../classes/meowUiStatuses";

export enum meowAppMessageType {
  BOOKMARKS_REFRESH, // See entry/src/main/ets/components/parts/Bookmarks/MeowBookmarksPanel.ets
  BOOKMARKS_PICKED
}

/**
 * Send a global message to the entire app.
 * @param type The type of the message.
 * @param content The content of the message.
 */
export function globalMessage(type: meowAppMessageType, content: object | string | boolean | number | undefined = undefined) {
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  myApp.crossAppMessageTunnel = new meowAppMessage(type, content);
}

// Example use of global messaging:
// Inside entry/src/main/ets/components/parts/Bookmarks/BookmarksColumn.ets

// @Monitor('myApp.crossAppMessageTunnel')
// receiveMessage() {
//   if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.BOOKMARKS_REFRESH) {
//     this.refreshRoot();
//   }
// }

/**
 * Send a local message to the current window.
 * @param type The type of the message.
 * @param content The content of the message.
 */
export function localMessage(myUi: meowUiStatuses, type: meowAppMessageType, content: object | string | boolean | number | undefined = undefined) {
  myUi.crossAppMessageTunnel = new meowAppMessage(type, content);
}

// Example use of local messaging:
// Sending from entry/src/main/ets/components/parts/MeowPlaceForDialogs.ets
// Listening on entry/src/main/ets/dialogs/WoofHomepage/WoofHomepage.ets

// @Monitor('myUi.crossAppMessageTunnel')
// receiveMessage() {
//   if (this.myUi.crossAppMessageTunnel?.type == meowAppMessageType.BOOKMARKS_PICKED) {
//     meow(`Received folder! ${this.myUi.crossAppMessageTunnel.content}`, 'WoofHomepage][receiveMessage');
//   }
// }
