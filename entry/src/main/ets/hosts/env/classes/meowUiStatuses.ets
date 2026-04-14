/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiStatuses {
  @Trace windowId: string;
  @Trace showMore: boolean = false;

  constructor(windowId: string) {
    this.windowId = windowId;
  }
}
