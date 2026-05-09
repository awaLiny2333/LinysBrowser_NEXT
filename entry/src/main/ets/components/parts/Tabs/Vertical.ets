import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, standardSpacing } from "../../constants";
import { defaultAnimation, sidebarShouldBeOnTheRight } from "../../settings";

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
    }
    .clip(true)
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .height('100%')
    .width(this.myUi.verticalTabsShrunk && this.myLayout.wideMode ? defaultTabsVerticalShrunkWidth : defaultTabsVerticalWidth);
  }
}

export { MeowTabsVertical };
