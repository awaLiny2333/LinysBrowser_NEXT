import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowTabsBunch } from "../../../hosts/app/tabs/classes/meowTabsBunch";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooSymbolButtonSmall } from "../../common/MooSymbolButtonSmall";
import { MooTextModifier } from "../../common/MooTextModifier";
import { defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, meowThemeColorType, standardSpacing } from "../../constants";
import { defaultAnimation, getColor, sideAreaShrinkButton, sideareaShouldBeOnTheRight, titleBarPositionBottom, useEffects } from "../../settings";
import { shrinkButton } from "../Sidebar/SidebarShrinkButton";

@ComponentV2
struct MeowTabsVertical {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;
  @Param @Require myTabs: meowTabsBunch;
  // Local
  listController: ListScroller = new ListScroller();
  // Event
  @Event onDropMe: () => void;
  @Event onDragLeaveSidebar: () => void;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      // Shrink button
      if (sideAreaShrinkButton() && !titleBarPositionBottom()) {
        shrinkButton(this.myUi);
      }

      Column() {
        List({ space: standardSpacing * 0.75, scroller: this.listController }) {
          Repeat(this.myTabs.tabs)
            .each((item) => {
              ListItem() {
                // Tab item
                Row() {
                  Text(item.item.title || 'Meow').attributeModifier(new MooTextModifier()).maxLines(1).wordBreak(WordBreak.BREAK_ALL).layoutWeight(1).padding(standardSpacing * 0.5);

                  // Web state saving / history punching indicator
                  if (item.item.wsBackupReqTmId != undefined || item.item.saveHistoryTimeoutId != undefined) {
                    MooSymbolButtonSmall($r('sys.symbol.cup'), () => {
                      animateToImmediately(defaultAnimation(), () => {
                        this.myTabs.closeTab(item.index);
                      });
                    }, undefined, 6);
                  } else {
                    // Close
                    MooSymbolButtonSmall($r('sys.symbol.xmark'), () => {
                      animateToImmediately(defaultAnimation(), () => {
                        this.myTabs.closeTab(item.index);
                      });
                    }, undefined, 6);
                  }
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
                    if (!this.myLayout.wideMode) {
                      this.myUi.sideAreaShrinkExpect = true;
                    }
                  });
                });
              }
              .draggable(!item.item.restoringWebState)
              .onDragStart((event) => {
                const unifiedData = this.myTabs.dropTabIntoMyAppTunnel(item.item);
                event.setData(unifiedData);
              })
              .onDragEnd(() => {
                this.myTabs.sendFinish();
              });
            })
            .key((item) => item.webStateId);
        }
        .direction(sideareaShouldBeOnTheRight() ? Direction.Rtl : Direction.Ltr)
        .borderRadius(defaultInnerRadius)
        .width('100%')
        .height('auto');
      }
      .justifyContent(FlexAlign.End)
      .alignItems(sideareaShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
      .width(this.verticalTabsWidth)
      .layoutWeight(1);

      Row() {
        // Shrink button
        if (sideAreaShrinkButton() && titleBarPositionBottom()) {
          shrinkButton(this.myUi);
        }
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.myTabs.newTabWrapped();
              if (!this.myLayout.wideMode) {
                this.myUi.sideAreaShrinkExpect = true;
              }
              this.listController.scrollToIndex(this.myTabs.tabs.length - 1);
            });
          }
        });
      }
      .width('100%')
      .justifyContent(sideareaShouldBeOnTheRight() ? FlexAlign.End : FlexAlign.Start);
    }
    .clip(true)
    .alignItems(sideareaShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .height('100%')
    .width(this.myUi.sideAreaShrunkSummarized ? defaultTabsVerticalShrunkWidth : this.verticalTabsWidth)
    .onDragLeave(() => {
      this.onDragLeaveSidebar();
    })
    .onDrop((event) => {
      this.myTabs.receiveTabFromMyAppTunnel();
      event.setResult(DragResult.DRAG_SUCCESSFUL);
      this.onDropMe();
    });
  }

  /**
   * The width of the vertical tab.
   */
  get verticalTabsWidth() {
    return this.myLayout.wideMode ? defaultTabsVerticalWidth : Math.round((this.myLayout.width - 2 * standardSpacing) * 0.9);
  }
}

export { MeowTabsVertical };
