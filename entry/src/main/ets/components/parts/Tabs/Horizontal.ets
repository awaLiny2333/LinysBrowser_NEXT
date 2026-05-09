import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { standardSpacing, meowThemeColorType, standardComponentHeight } from "../../constants";
import { getColor, useEffects } from "../../settings";

@ComponentV2
struct MeowTabsHorizontal {
  build() {
    Row() {
      Text('Meow Horizontal Tabs!')
        .padding(standardSpacing)
        .width('100%')
        .height('100%')
        .backgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius });
    }
    .height(standardComponentHeight)
    .width('100%');
  }
}

export { MeowTabsHorizontal };
