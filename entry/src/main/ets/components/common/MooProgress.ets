import { meowThemeColorType, standardSpacing } from "../constants";
import { defaultAnimation, getColor } from "../settings";

@ComponentV2
export struct MooProgress {
  @Param show: boolean = false;
  @Param percentage: number = 0; // 0 ~ 100
  @Param barHeight: number = standardSpacing;
  @Param rounded: boolean = false;

  build() {
    Row() {
      Row().height('100%').width(`${this.percentage}%`).animation(defaultAnimation()).backgroundColor(getColor(meowThemeColorType.FONT)).borderRadius(this.rounded ? standardSpacing / 2 : 0).opacity(0.9);
    }
    .borderRadius(this.rounded ? standardSpacing / 2 : 0)
    .visibility(this.show ? Visibility.Visible : Visibility.None)
    .animation(defaultAnimation())
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .justifyContent(FlexAlign.Start)
    .height(this.barHeight)
    .width('100%');
  }
}
