import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, standardSpacing } from "../../constants";
import { sideAreaShrinkButton, sidebarShouldBeOnTheRight, titleBarPositionBottom } from "../../settings";
import { shrinkButton } from "../Sidebar/SidebarShrinkButton";

@ComponentV2
struct MeowTabsVertical {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      // Shrink button
      if (this.showShrinkButton && !titleBarPositionBottom()) {
        shrinkButton(this.myUi);
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
        shrinkButton(this.myUi);
      }
    }
    .clip(true)
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .height('100%')
    .width(this.myUi.sideAreaShrunkSummarized && this.myLayout.wideMode ? defaultTabsVerticalShrunkWidth : this.verticalTabsWidth);
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
}

export { MeowTabsVertical };
