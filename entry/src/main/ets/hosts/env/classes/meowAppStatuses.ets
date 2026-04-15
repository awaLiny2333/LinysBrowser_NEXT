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
  @Trace crossAppDataTunnel: (object | boolean | string | number | undefined)[] = []; // The great tunnel for the entire app! *TEMPORARY*
}
