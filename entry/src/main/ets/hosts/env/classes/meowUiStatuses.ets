/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiStatuses {
  @Trace windowId: string;
  @Trace windowAlias: string;
  @Trace showMore: boolean = false;
  @Trace showTabs: boolean = false;
  @Trace sidebarShrunk: boolean = true;

  constructor(windowId: string, windowAlias: string = 'Meowy window alias!') {
    this.windowId = windowId;
    this.windowAlias = windowAlias;
  }
}
