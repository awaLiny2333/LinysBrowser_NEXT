import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowTabsBunch } from "../../../hosts/app/tabs/classes/meowTabsBunch";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooSymbolButtonSmall } from "../../common/MooSymbolButtonSmall";
import { MooTextModifier } from "../../common/MooTextModifier";
import { defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, meowThemeColorType, standardSpacing } from "../../constants";
import { defaultAnimation, getColor, sideAreaShrinkButton, sidebarShouldBeOnTheRight, titleBarPositionBottom, useEffects } from "../../settings";
import { shrinkButton } from "../Sidebar/SidebarShrinkButton";

@ComponentV2
struct MeowTabsVertical {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;
  @Param @Require myTabs: meowTabsBunch;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      // Shrink button
      if (this.showShrinkButton && !titleBarPositionBottom()) {
        shrinkButton(this.myUi);
      }

      Column() {
        List({ space: standardSpacing * 0.75 }) {
          Repeat(this.myTabs.tabs)
            .each((item) => {
              ListItem() {
                // Tab item
                Row({ space: standardSpacing * 0.75 }) {
                  Text(item.item.title || 'Meow').attributeModifier(new MooTextModifier()).maxLines(1).wordBreak(WordBreak.BREAK_ALL).layoutWeight(1).padding(standardSpacing * 0.5);
                  MooSymbolButtonSmall($r('sys.symbol.xmark'), () => {
                    animateToImmediately(defaultAnimation(), () => {
                      this.myTabs.closeTab(item.index);
                    });
                  });
                }
                .opacity(item.item.isActive ? 1 : 0.5)
                .hoverEffect(HoverEffect.Highlight)
                .padding(standardSpacing * 0.5)
                .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
                .border(this.myTabs.currentTab == item.item
                  ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultInnerRadius }
                  : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
                .onClick(() => {
                  animateToImmediately(defaultAnimation(), () => {
                    this.myTabs.switchTo(item.index);
                  });
                });
              };
            });
        }
        .borderRadius(defaultInnerRadius)
        .width('100%')
        .height('auto');
      }
      .justifyContent(FlexAlign.End)
      .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
      .width(this.verticalTabsWidth)
      .layoutWeight(1);

      Row() {
        // Shrink button
        if (this.showShrinkButton && titleBarPositionBottom()) {
          shrinkButton(this.myUi);
        }
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.myTabs.newTabWrapped();
            });
          }
        });
      }
      .width('100%')
      .justifyContent(sidebarShouldBeOnTheRight() ? FlexAlign.End : FlexAlign.Start);
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
