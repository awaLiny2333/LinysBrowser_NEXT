@ObservedV2
export class meowLayoutModeStatus {
  @Trace wideMode: boolean;
  @Trace shortMode: boolean;
  @Trace width: number;
  @Trace height: number;
  @Trace dark: boolean;
  @Trace powerSave: boolean;
  @Trace smartReachabilitySaysWeShouldPreferRightHand: boolean; // What a long name

  constructor(wideMode: boolean, shortMode: boolean, width: number, height: number, dark: boolean, powerSave: boolean, smartReachabilitySaysWeShouldPreferRightHand: boolean) {
    this.wideMode = wideMode;
    this.shortMode = shortMode;
    this.width = width;
    this.height = height;
    this.dark = dark;
    this.powerSave = powerSave;
    this.smartReachabilitySaysWeShouldPreferRightHand = smartReachabilitySaysWeShouldPreferRightHand;
  }
}
