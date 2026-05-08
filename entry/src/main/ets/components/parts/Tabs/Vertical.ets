import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { defaultAnimation, getColor, meowThemeColorType, sidebarShouldBeOnTheRight, standardSpacing, useEffects } from "../../settings";

@ComponentV2
struct MeowTabsVertical {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      if (this.mySettings.settingsData[15].value as boolean && this.myLayout.wideMode) {
        SymbolButton({
          icon: this.myUi.verticalTabsShrunk ? $r('sys.symbol.arrow_up_left_and_arrow_down_right') : $r('sys.symbol.arrow_down_right_and_arrow_up_left'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.myUi.verticalTabsShrunk = !this.myUi.verticalTabsShrunk;
            });
            this.mySettings.setByIndex(14, this.myUi.verticalTabsShrunk);
          }
        });
      }
      Column() {
        Text('Meow Vertical Tabs!');
      }
      .padding(standardSpacing)
      .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
      .width(defaultTabsVerticalWidth)
      .layoutWeight(1)
      .backgroundColor(useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY))
      .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: useEffects() ? defaultInnerRadius : 0 });
    }
    .clip(true)
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .height('100%')
    .width(this.myUi.verticalTabsShrunk && this.myLayout.wideMode ? 32 : defaultTabsVerticalWidth);
  }
}

export { MeowTabsVertical };

export const defaultTabsVerticalWidth = 260;
