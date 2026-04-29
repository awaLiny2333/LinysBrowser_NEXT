import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { defaultInnerRadius, defaultItemRadius } from "../../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../../components/common/MooCapsuleButton";
import { MooSymbolButton } from "../../../../components/common/MooSymbolButton";
import { MooTextInputV2 } from "../../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../../components/common/MooTextModifier";
import { defaultAnimation, getColor, isPreferRightHand, meowThemeColorType, standardSpacing, useEffects } from "../../../../components/settings";
import { meowHistorian } from "../../../../hosts/userdata/history/classes/meowHistorian";
import { meowHistoryChunk } from "../../../../hosts/userdata/history/classes/meowHistoryChunk";
import { meowHistoryEntry } from "../../../../hosts/userdata/history/classes/meowHistoryEntry";
import { EntryButton } from "./EntryButton";
import { defaultMonthButtonHeight, MonthButton } from "./MonthButton";

@ComponentV2
struct WoofHistoryPanel {
  // Host
  @Param @Require myLayout: meowLayout;
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!; // Should be initialized by flow.
  // Display
  @Local myHistoryChunk: meowHistoryChunk | undefined;
  @Local myEntries: meowHistoryEntry[] = [];
  @Local isSelecting: boolean = false;
  // Search
  @Local searchKey: string = ''; // The key to search in current month's index.
  @Local isSearching: boolean = false;
  searchInputId: string = `WoofHistory_search_${Date.now().toString(16)}`;
  // Select
  @Local selectedTimeStamps: Set<number> = new Set();
  // Events
  @Event requestVisit: (url: string) => void;
  // Obj
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    // Load latest month
    this.myHistoryChunk = this.myMeowHistorian.getChunk(0);
    this.myMeowHistorian.getHistoryEntries(0).then((result) => {
      this.myEntries = result;
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom); // Scroll to latest
      }, 1);
    });
  }

  build() {
    Column({ space: defaultInnerRadius }) {
      if (!this.isSelecting) {
        Text(`${this.myHistoryChunk?.year}-${this.myHistoryChunk?.month} (${this.myEntries.length})`).attributeModifier(new MooTextModifier());
      }
      
      // Entries
      List({ scroller: this.scroller }) {
        Repeat(this.myEntries)
          .each((obj: RepeatItem<meowHistoryEntry>) => {
            EntryButton({
              item: obj.item,
              isSelecting: this.isSelecting,
              isSelected: this.selectedTimeStamps.has(obj.item.time),
              clickAction: () => {
                if (!this.isSelecting) {
                  // Request visit
                  this.requestVisit(obj.item.url);
                  return;
                }

                // Select / Deselect
                if (this.selectedTimeStamps.has(obj.item.time)) {
                  this.selectedTimeStamps.delete(obj.item.time);
                } else {
                  this.selectedTimeStamps.add(obj.item.time);
                }
              }
            });
          })
          .virtualScroll();
        if (this.myEntries.length == 0) {
          ListItem() {
            Text(this.isSearching ? $r('app.string.General_wait') : 'No history found. ヽ（´ー｀）┌')
              .attributeModifier(new MooTextModifier())
              .opacity(0.7)
              .padding(standardSpacing * 0.75)
              .borderRadius(defaultItemRadius)
              .hoverEffect(HoverEffect.Highlight);
          };
        }
      }
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
      .padding(standardSpacing * 0.75)
      .height('auto')
      .layoutWeight(1)
      .width('100%');

      // Months
      if (!this.isSelecting) {
        List({ space: standardSpacing * 0.75 }) {
          Repeat(this.myMeowHistorian.getChunks())
            .each((obj: RepeatItem<meowHistoryChunk>) => {
              ListItem() {
                MonthButton({
                  year: obj.item.year,
                  month: obj.item.month,
                  isSelected: this.myHistoryChunk?.year == obj.item.year && this.myHistoryChunk?.month == obj.item.month,
                  clickAction: () => {
                    this.myHistoryChunk = this.myMeowHistorian.getChunk(obj.index);
                    this.search();
                  }
                });
              };
            })
            .virtualScroll();
        }
        .alignListItem(ListItemAlign.Center)
        .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
        .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
        .padding(standardSpacing * 0.75)
        .listDirection(Axis.Horizontal)
        .height(defaultMonthButtonHeight + standardSpacing * 1.5)
        .width('auto');
      }

      // Bottom
      Row({ space: standardSpacing }) {
        // Search
        MooTextInputV2({
          icon: $r('sys.symbol.magnifyingglass'),
          placeholder: '',
          myId: this.searchInputId,
          onChange: (value) => {
            this.searchKey = value;
            this.search();
          },
          onSubmit: () => {
            this.search();
          }
        })
          .onAppear(() => {
            try {
              this.getUIContext().getFocusController().requestFocus(this.searchInputId);
            } catch (e) {
              meow(`this.getUIContext().getFocusController().requestFocus("${this.searchInputId}"); failed: ${e}`, 'WoofHistory][Panel', meowLevel.ERROR);
            }
          })
          .layoutWeight(1);
        // Text(`[Result] of ${this.searchKey} (${this.searchResult.length}) (${this.searchTime} ms):${'\n\n'}${this.searchResult.join(',\n\n')}`);

        // Edit
        MooSymbolButton({
          icon: this.isSelecting ? $r('sys.symbol.square_and_pencil_fill') : $r('sys.symbol.square_and_pencil'),
          onHold: this.isSelecting,
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.deselectAll();
              this.isSelecting = !this.isSelecting;
            });
          }
        });

        if (this.isSelecting) {
          Text(this.selectedTimeStamps.size.toString()).attributeModifier(new MooTextModifier()).padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });

          MooCapsuleButton({
            text: (this.myEntries.length == this.selectedTimeStamps.size) ? $r('app.string.General_unselect') : $r('app.string.General_selectall'),
            clickAction: () => {
              if (this.myEntries.length == this.selectedTimeStamps.size) {
                this.deselectAll();
              } else {
                this.selectAll();
              }
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_delete'),
            isEnabled: this.selectedTimeStamps.size > 0,
            needDoubleConfirm: true,
            clickAction: () => {
              animateToImmediately(defaultAnimation(), () => {
                this.myEntries = this.myEntries.filter((entry) => !this.selectedTimeStamps.has(entry.time));
              });
              this.myMeowHistorian.deleteHistory(this.selectedTimeStamps);
              // Splice all delete targets from myHistoryChunkEntries
              this.selectedTimeStamps = new Set();
            }
          });
        }
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
    }
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .padding(standardSpacing);
  }

  /**
   * Submit search search.
   */
  async search() {
    if (this.myHistoryChunk == undefined) {
      return;
    }
    animateToImmediately(defaultAnimation(), () => {
      this.isSearching = true;
    });
    this.myEntries = [];
    const res = await this.myHistoryChunk.lookUpHistoryEntries(this.searchKey, Number.MAX_VALUE);
    // this.myEntries = await this.myMeowHistorian.lookUpHistoryEntries(this.searchKey, Number.MAX_VALUE) ?? [];
    animateToImmediately(defaultAnimation(), () => {
      this.myEntries = res;
      this.isSearching = false;
    });
  }

  deselectAll() {
    this.selectedTimeStamps.clear();
  }

  selectAll() {
    this.selectedTimeStamps = new Set(this.myEntries.map((entry) => entry.time));
  }
}

export { WoofHistoryPanel };

export const defaultTextHeight = 32;
