import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, standardSpacing } from "../../constants";
import { defaultAnimation, sideAreaShrinkButton, sidebarShouldBeOnTheRight, titleBarPositionBottom } from "../../settings";

@ComponentV2
struct MeowTabsVertical {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      // Shrink button
      if (this.showShrinkButton && !titleBarPositionBottom()) {
        this.shrinkButton();
      }

      Column() {
        Text('Meow Vertical Tabs!');
      }
      .padding(standardSpacing)
      .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
      .width(this.verticalTabsWidth)
      .layoutWeight(1);

      // Shrink button
      if (this.showShrinkButton && titleBarPositionBottom()) {
        this.shrinkButton();
      }
    }
    .clip(true)
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .height('100%')
    .width(this.myUi.sideAreaShrunk && !this.myUi.sideAreaShrinkBlock && this.myLayout.wideMode ? defaultTabsVerticalShrunkWidth : this.verticalTabsWidth);
  }

  /**
   * The width of the vertical tab.
   */
  get verticalTabsWidth() {
    return this.myLayout.wideMode ? defaultTabsVerticalWidth : (this.myLayout.width - 2 * standardSpacing) * 0.9;
  }

  get showShrinkButton() {
    return sideAreaShrinkButton() && this.myLayout.wideMode;
  }

  @Builder
  shrinkButton() {
    SymbolButton({
      icon: this.myUi.sideAreaShrunk ? $r('sys.symbol.arrow_up_left_and_arrow_down_right') : $r('sys.symbol.arrow_down_right_and_arrow_up_left'),
      clickAction: () => {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.sideAreaShrunk = !this.myUi.sideAreaShrunk;
        });
      }
    });
  }
}

export { MeowTabsVertical };
