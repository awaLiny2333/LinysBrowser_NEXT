/**
 * The statuses that is shared across the entire app, across different windows / instances.
 */
@ObservedV2
export class meowAppStatuses {
  @Trace windowNames: string[] = [];
  @Trace refreshingWebCacheSize: boolean = false;
  @Trace refreshingHistoryIndexSize: boolean = false;
  @Trace dark: boolean = true;
  @Trace powerSave: boolean = false;
  @Trace smartReachabilitySaysWeShouldPreferRightHand: boolean = true; // What a long name
  // Messaging
  @Trace crossAppDataTunnel: (object | boolean | string | number | undefined)[] = []; // The great tunnel for the entire app! *TEMPORARY* and is ofter cleared after reception.
  @Trace crossAppMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for cross-window messaging! *TEMPORARY* but not cleared after reception.
}

export enum meowAppMessageType {
  BOOKMARKS_REFRESH = 0, // See entry/src/main/ets/components/parts/Bookmarks/MeowBookmarksPanel.ets
}

/**
 * The message that can be shared across the entire app, across different windows / instances.
 */
@ObservedV2
export class meowAppMessage {
  @Trace type: meowAppMessageType;
  @Trace content: string;
  @Trace timestamp: number = Date.now();

  constructor(type: meowAppMessageType, content: string = '') {
    this.type = type;
    this.content = content;
  }
}

// Example use of global messaging:
// From entry/src/main/ets/components/parts/Bookmarks/BookmarksColumn.ets

// @Monitor('myApp.crossAppMessageTunnel')
// receiveMessage() {
//   if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.BOOKMARKS_REFRESH) {
//     this.refreshRoot();
//   }
// }
