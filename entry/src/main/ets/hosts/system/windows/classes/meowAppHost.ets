import { MeowBookmarkDragInfo } from "../../../userdata/bookmarks/classes/meowBookmarkStash";
import { meowAppMessage } from "./meowAppMessage";

/**
 * The statuses that is shared across the entire app, across different windows / instances.
 */
@ObservedV2
export class meowAppHost {
  @Trace windowIds: string[] = [];
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
}
