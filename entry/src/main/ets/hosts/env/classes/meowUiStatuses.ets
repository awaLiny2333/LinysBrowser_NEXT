import { meowBookmarkItem } from "../../bookmarks/classes/meowBookmarkItem";
import { meowAppMessage } from "./meowAppMessage";

/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiStatuses {
  // Window info
  @Trace windowId: string;
  @Trace windowAlias: string;
  // UI
  @Trace showMore: boolean = false;
  @Trace showTabs: boolean = false;
  @Trace sidebarShrunk: boolean = true;
  // MeowBookmarksPanel
  @Trace openedStack: meowBookmarkItem[] = [];
  @Trace openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // Data
  @Trace crossAppMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for cross-window messaging! *TEMPORARY* but not cleared after reception.

  constructor(windowId: string, windowAlias: string = 'Meowy window alias!') {
    this.windowId = windowId;
    this.windowAlias = windowAlias;
  }
}
