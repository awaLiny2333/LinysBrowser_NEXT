import { meowBookmarkItem } from "../../../userdata/bookmarks/classes/meowBookmarkItem";
import { meowAppMessage } from "./meowAppMessage";
import { window } from "@kit.ArkUI";

/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiStatuses {
  // Window info
  @Trace windowId: string;
  @Trace windowAlias: string;
  @Trace windowObj: window.Window | undefined;
  // UI
  @Trace showMore: boolean = false;
  @Trace showTabs: boolean = false;
  @Trace sidebarShrunk: boolean = true;
  // MeowBookmarksPanel
  @Trace openedStack: meowBookmarkItem[] = [];
  @Trace openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // Messaging (Shared)
  @Trace localMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for local window messaging! *TEMPORARY* but often NOT cleared after reception.

  constructor(windowId: string, windowAlias: string = 'Meowy window alias!') {
    this.windowId = windowId;
    this.windowAlias = windowAlias;
  }
}
