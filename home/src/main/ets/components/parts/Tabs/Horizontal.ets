import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowTabsBunch } from "../../../hosts/app/tabs/classes/meowTabsBunch";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooSymbolButtonSmall } from "../../common/MooSymbolButtonSmall";
import { MooTextModifier } from "../../common/MooTextModifier";
import { defaultMooSymbolSize, meowThemeColorType, standardComponentHeight, standardSpacing, textInputSlimHeight } from "../../constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../../settings";

@ComponentV2
struct MeowTabsHorizontal {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;
  @Param @Require myTabs: meowTabsBunch;
  // Local
  @Local myWidth: number = this.myLayout.width;
  mySpacing = standardSpacing * 0.75;

  build() {
    Row({ space: this.mySpacing }) {
      if (this.myTabs.tabs.length == 0) {
        Text($r('app.string.General_empty')).attributeModifier(new MooTextModifier()).opacity(0.75).padding(standardSpacing * 0.5);
      } else {
        List({ space: this.mySpacing }) {
          Repeat(this.myTabs.tabs)
            .each((item) => {
              ListItem() {
                // Tab item
                Row() {
                  // Show the title, unless is the selected tab in a tight situation
                  if (!(this.tight && this.myTabs.currentTab == item.item)) {
                    Text(item.item.title || 'Meow').attributeModifier(new MooTextModifier()).maxLines(1).wordBreak(WordBreak.BREAK_ALL).layoutWeight(1).textOverflow({ overflow: TextOverflow.Clip }).padding(standardSpacing * 0.6);
                  }
                  // Show the close button if not in tight button,
                  // Or is the selected tab (even if in a tight situation)
                  if (!this.tight || this.myTabs.currentTab == item.item) {
                    // Web state saving / history punching indicator
                    if (item.item.saveWebStateTimeoutId != undefined || item.item.saveHistoryTimeoutId != undefined) {
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
                }
                .opacity(item.item.isActive ? 1 : 0.5)
                .height(textInputSlimHeight)
                .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
                .width(this.widthEachTab - this.mySpacing)
                .hoverEffect(HoverEffect.Highlight)
                .padding(this.tight ? 1 : standardSpacing * 0.25)
                .backgroundColor(getColor(meowThemeColorType.PRIMARY))
                .border(this.myTabs.currentTab == item.item
                  ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultInnerRadius }
                  : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
                .onClick(() => {
                  animateToImmediately(defaultAnimation(), () => {
                    this.myTabs.switchTo(item.index);
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
        .scrollBar(BarState.Off)
        .alignListItem(ListItemAlign.Center)
        .height('100%')
        .width('auto')
        .listDirection(Axis.Horizontal);
      }
      // New tab
      MooSymbolButton({
        icon: $r('sys.symbol.plus_square'),
        clickAction: () => {
          animateToImmediately(defaultAnimation(), () => {
            this.myTabs.newTabWrapped();
          });
        }
      });
    }
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl)
    .justifyContent(FlexAlign.End)
    .onAreaChange((o, n) => {
      if (o.width != n.width) {
        animateToImmediately(defaultAnimation(), () => {
          this.myWidth = n.width as number;
        });
      }
    })
    .height(textInputSlimHeight)
    .width('100%')
    .onDrop((event) => {
      this.myTabs.receiveTabFromMyAppTunnel();
      event.setResult(DragResult.DRAG_SUCCESSFUL);
    });
  }

  @Computed
  get widthEachTab() {
    return (this.myWidth - defaultMooSymbolSize) / this.myTabs.tabs.length;
  }

  get tight() {
    return this.widthEachTab < standardComponentHeight;
  }
}

export { MeowTabsHorizontal };
