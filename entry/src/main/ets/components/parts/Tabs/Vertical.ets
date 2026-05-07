import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { standardSpacing, getColor, meowThemeColorType, useEffects, defaultSidebarWidth } from "../../settings";

@ComponentV2
struct MeowTabsVertical {
  build() {
    Row() {
      Text('Meow Side / Vertical Tabs!')
        .padding(standardSpacing)
        .width('100%')
        .height('100%')
        .backgroundColor(useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY))
        .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: useEffects() ? defaultInnerRadius : 0 });
    }
    .height('100%')
    .width(defaultSidebarWidth);
  }
}

export { MeowTabsVertical };
