@ObservedV2
export class meowFreeWindowModeStatus {
  @Trace on: boolean;
  @Trace onFocus: boolean = true;

  constructor(on: boolean) {
    this.on = on;
  }
}
