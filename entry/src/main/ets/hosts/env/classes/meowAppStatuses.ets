import { meowBookmarkItem } from "../../bookmarks/classes/meowBookmarkItem";
import { meowAppMessage } from "./meowAppMessage";

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
  @Trace dataTunnelForBookmarks: (number | undefined | meowBookmarkItem[])[] = [];
  @Trace crossAppMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for cross-window messaging! *TEMPORARY* but not cleared after reception.
}
