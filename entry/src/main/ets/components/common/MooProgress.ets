import { meowThemeColorType, standardSpacing } from "../constants";
import { defaultAnimation, getColor } from "../settings";

@ComponentV2
export struct MooProgress {
  @Param show: boolean = false;
  @Param percentage: number = 0; // 0 ~ 100
  @Param barHeight: number = standardSpacing;

  build() {
    Row() {
      Row().height('100%').width(`${this.percentage}%`).animation(defaultAnimation()).backgroundColor(getColor(meowThemeColorType.FONT));
    }
    .visibility(this.show ? Visibility.Visible : Visibility.None)
    .animation(defaultAnimation())
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .justifyContent(FlexAlign.Start)
    .height(this.barHeight)
    .width('100%');
  }
}
