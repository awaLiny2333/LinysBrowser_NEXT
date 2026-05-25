import { MeowBookmarkDragInfo } from "../../../userdata/bookmarks/classes/meowBookmarkStash";
import { meowAppMessage } from "./meowAppMessage";

/**
 * The statuses that is shared across the entire app, across different windows / instances.
 */
@ObservedV2
export class meowAppHost {
  @Trace windowIds: string[] = [];
  @Trace windowFocusHistory: string[] = [];
  // Background tasks
  @Trace refreshingWebCacheSize: boolean = false;
  @Trace refreshingHistoryIndexSize: boolean = false;
  // UI / Experiences
  @Trace dark: boolean = true;
  @Trace powerSave: boolean = false;
  @Trace smartReachabilitySaysWeShouldPreferRightHand: boolean = true; // What a long name
  @Trace freeWindow: boolean = false; // Free window mode
  // Messaging (Shared)
  @Trace crossAppMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for cross-window messaging! *TEMPORARY* but not cleared after reception.
  // Messaging (Dedicated)
  @Trace dataTunnelForBookmarks: MeowBookmarkDragInfo | undefined = undefined;

  /**
   * Report window focus event.
   * @param windowId The window ID.
   */
  reportWindowFocus(windowId: string) {
    const idxInHistory = this.windowFocusHistory.indexOf(windowId);
    if (idxInHistory !== -1) {
      this.windowFocusHistory.splice(idxInHistory, 1);
    }
    this.windowFocusHistory.push(windowId);
  }

  /**
   * Report window close event. Deletes the windowId from the id main list and focus history list.
   * @param windowId The window ID.
   */
  reportWindowClose(windowId: string) {
    const idxInHistory = this.windowFocusHistory.indexOf(windowId);
    if (idxInHistory !== -1) {
      this.windowFocusHistory.splice(idxInHistory, 1);
    }
    const idxInList = this.windowIds.indexOf(windowId);
    if (idxInList !== -1) {
      this.windowIds.splice(idxInList, 1);
    }
  }

  /**
   * Get the last focused window ID.
   */
  get lastFocusedWindowId() {
    return this.windowFocusHistory[this.windowFocusHistory.length - 1];
  }
}
