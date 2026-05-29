@ObservedV2
export class meowLayout {
  @Trace wideMode: boolean;
  @Trace shortMode: boolean;
  @Trace width: number;
  @Trace height: number;
  @Trace heightTitleArea: number = 10;
  @Trace heightTitleBar: number = 10;

  constructor(wideMode: boolean, shortMode: boolean, width: number, height: number) {
    this.wideMode = wideMode;
    this.shortMode = shortMode;
    this.width = width;
    this.height = height;
  }
}
