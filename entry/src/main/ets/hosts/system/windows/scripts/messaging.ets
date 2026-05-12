import lazy { meowAppMessage } from "../classes/meowAppMessage";
import lazy { meowUiHost } from "../classes/meowUiHost";
import lazy { getMyApp } from "./helpers";

export enum meowAppMessageType {
  SETTINGS_UA_REFRESH,
  SETTINGS_SE_REFRESH,
  SETTINGS_EASYLIST_REFRESH,
  SETTINGS_NAV_INDICATOR_UPDATE,
  BOOKMARKS_REFRESH, // See entry/src/main/ets/components/parts/Bookmarks/MeowBookmarksPanel.ets
  BOOKMARKS_PICKED,
  BOOKMARKS_DRAGGED,
  COLOR_PICKED,
  COLOR_PICKER_CLOSED,
  KEY_SHORTCUTS_PICKED, 
  HISTORY_DELETED,
}

/**
 * Send a global message to the entire app.
 * @param type The type of the message.
 * @param content The content of the message.
 */
export function globalMessage(type: meowAppMessageType, content: object | string | boolean | number | undefined = undefined) {
  getMyApp().crossAppMessageTunnel = new meowAppMessage(type, content);
}

// Example use of global messaging:
// Inside entry/src/main/ets/components/parts/Bookmarks/BookmarksColumn.ets

// @Monitor('myApp.crossAppMessageTunnel')
// receiveMessage() {
//   const msg = this.myApp.crossAppMessageTunnel!;
//   if (msg.type == meowAppMessageType.BOOKMARKS_REFRESH) {
//     this.refreshRoot();
//   }
// }

/**
 * Send a local message to the current window.
 * @param type The type of the message.
 * @param content The content of the message.
 */
export function localMessage(myUi: meowUiHost, type: meowAppMessageType, content: object | string | boolean | number | undefined = undefined) {
  myUi.localMessageTunnel = new meowAppMessage(type, content);
}

// Example use of local messaging:
// Sending from entry/src/main/ets/components/parts/MeowPlaceForDialogs.ets
// Listening on entry/src/main/ets/dialogs/WoofHomepage/WoofHomepage.ets

// @Monitor('myUi.localMessageTunnel')
// receiveMessage() {
//   if (this.myUi.localMessageTunnel?.type == meowAppMessageType.BOOKMARKS_PICKED) {
//     meow(`Received folder! ${this.myUi.localMessageTunnel.content}`, 'WoofHomepage][receiveMessage');
//   }
// }
