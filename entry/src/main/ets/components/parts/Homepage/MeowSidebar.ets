import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { standardSpacing, useEffects, getColor, meowThemeColorType } from "../../settings";
import { sidebarWidth } from "../../statuses";

@ComponentV2
struct MeowSidebar {
  @Param @Require myLayout: meowLayout;

  build() {
    Column() {
      Text('Meow Sidebar!')
        .padding(standardSpacing)
        .width('100%')
        .height('100%')
        .backgroundColor(useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY))
        .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: useEffects() ? defaultInnerRadius : 0 });
    }
    .width(sidebarWidth(this.myLayout))
    .height('100%');
  }
}

export { MeowSidebar };
