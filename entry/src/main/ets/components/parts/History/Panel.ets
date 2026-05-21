import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { isBlank } from "../../../catstypicalframework/utils/strings";
import { defaultInnerRadius, defaultItemRadius } from "../../../catstypicalframework/utils/ui";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { getMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { globalMessage, meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowHistorian } from "../../../hosts/userdata/history/classes/meowHistorian";
import { meowHistoryChunk } from "../../../hosts/userdata/history/classes/meowHistoryChunk";
import { meowHistoryEntry } from "../../../hosts/userdata/history/classes/meowHistoryEntry";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooTextInputV2 } from "../../common/MooTextInputV2";
import { MooTextModifier } from "../../common/MooTextModifier";
import { meowThemeColorType, mooTextType, standardSpacing } from "../../constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../../settings";
import { HistoryEntry } from "./parts/HistoryEntry";
import { defaultMonthButtonHeight, MonthButton } from "./parts/MonthButton";

@ComponentV2
struct HistoryPanel {
  // Config
  @Param @Once autoFocus: boolean = true;
  @Param @Once allowEdit: boolean = true;
  @Param @Once lite: boolean = false;
  @Param @Once needPadding: boolean = true;
  // Host
  @Param @Require myLayout: meowLayout;
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!;
  @Local myApp: meowAppHost = getMyApp();
  // Display
  @Local myHistoryChunk: meowHistoryChunk | undefined;
  @Local myEntries: meowHistoryEntry[] = [];
  @Local isSelecting: boolean = false;
  // Search
  @Local searchKey: string = ''; // The key to search in current month's index.
  @Local isSearching: boolean = false;
  @Local useFastSearch: boolean = true;
  searchInputId: string = `WoofHistory_search_${Date.now().toString(16)}`;
  // Select
  @Local selectedTimeStamps: Set<number> = new Set();
  // Events
  @Event requestVisit: (url: string) => void;
  @Event requestRefreshTitle: (text: string) => void;
  // Obj
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    // Load latest month
    const startTime = Date.now();
    this.myHistoryChunk = this.myMeowHistorian.getChunk(0);
    this.search().then(() => {
      setTimeout(() => {
        const duration = Date.now() - startTime;
        this.refreshInfo(duration);
      }, 1);
    });
  }

  build() {
    Column({ space: defaultInnerRadius }) {
      // Entries
      List({ scroller: this.scroller, space: standardSpacing * 0.5 }) {
        Repeat(this.myEntries)
          .each((obj: RepeatItem<meowHistoryEntry>) => {
            if (obj.index == 0 || (obj.item.dateKey != this.myEntries[obj.index - 1]?.dateKey)) {
              // Title
              Column() {
                Text(`${new Date(obj.item.time).toLocaleDateString()}`)
                  .attributeModifier(new MooTextModifier(mooTextType.TITLE))
                  .padding(standardSpacing * 0.75);
                this.entry(obj);
              }
              .alignItems(HorizontalAlign.End);
            } else {
              this.entry(obj);
            }
          })
          .virtualScroll();

        // Placeholder for empty result
        if (this.myEntries.length == 0) {
          ListItem() {
            Text(this.isSearching ? $r('app.string.General_wait') : $r('app.string.General_empty'))
              .attributeModifier(new MooTextModifier())
              .opacity(0.7)
              .padding(standardSpacing * 0.75)
              .borderRadius(defaultItemRadius)
              .hoverEffect(HoverEffect.Highlight);
          };
        }
      }
      .borderRadius(defaultInnerRadius)
      .height('auto')
      .layoutWeight(1)
      .width('100%');

      // Months
      if (!this.isSelecting) {
        List({ space: standardSpacing * 0.75 }) {
          ListItem() {
            MonthButton({
              desc: '󰀩',
              isSelected: this.myHistoryChunk === undefined,
              clickAction: () => {
                this.myHistoryChunk = undefined;
                this.search();
              }
            });
          };
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
        .direction(isPreferRightHand() ? Direction.Rtl : Direction.Ltr)
        .listDirection(Axis.Horizontal)
        .padding(standardSpacing * 0.75)
        .height(defaultMonthButtonHeight + standardSpacing * 0.75 * 2)
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
              if (this.myApp.freeWindow && this.autoFocus) {
                this.getUIContext().getFocusController().requestFocus(this.searchInputId);
              }
            } catch (e) {
              meow(`this.getUIContext().getFocusController().requestFocus("${this.searchInputId}"); failed: ${e}`, 'WoofHistory][Panel', meowLevel.ERROR);
            }
          })
          .layoutWeight(1);

        // Switch mode
        MooCapsuleButton({
          text: this.useFastSearch ? $r('app.string.History_search_fast') : $r('app.string.History_search_full'),
          clickAction: () => {
            this.useFastSearch = !this.useFastSearch;
            this.search();
          }
        });

        // Edit button
        if (this.allowEdit) {
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
        }

        if (this.isSelecting && this.myLayout.wideMode) {
          this.editBar();
        }
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);

      if (this.isSelecting && !this.myLayout.wideMode) {
        this.editBar();
      }
    }
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .padding(this.needPadding ? standardSpacing : 0);
  }

  @Builder
  entry(obj: RepeatItem<meowHistoryEntry>) {
    if (this.lite) {
      // Lite, only title.
      Text(!isBlank(obj.item.title) ? obj.item.title : obj.item.url)
        .attributeModifier(new MooTextModifier())
        .wordBreak(WordBreak.BREAK_ALL)
        .width('100%')
        .opacity(0.75)
        .maxLines(1)
        .onClick(() => {
          this.selectDeselectItem(obj.item);
        })
        .padding(standardSpacing * 0.75)
        .borderRadius(defaultItemRadius)
        .hoverEffect(HoverEffect.Highlight);
    } else {
      HistoryEntry({
        myLayout: this.myLayout,
        isSelected: this.selectedTimeStamps.has(obj.item.time),
        isSelecting: this.isSelecting,
        item: obj.item,
        clickAction: () => {
          this.selectDeselectItem(obj.item);
        }
      });
    }
  }

  @Builder
  editBar() {
    Row({ space: standardSpacing }) {
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
          const startTime = Date.now();

          // Optimistic update.
          animateToImmediately(defaultAnimation(), () => {
            this.myEntries = this.myEntries.filter((entry) => !this.selectedTimeStamps.has(entry.time));
          });
          globalMessage(meowAppMessageType.HISTORY_DELETED, this.selectedTimeStamps);

          // Real job.
          this.myMeowHistorian.deleteHistory(this.selectedTimeStamps).then(() => {
            // Report
            const duration = Date.now() - startTime;
            this.refreshInfo(duration);
          });
          this.selectedTimeStamps = new Set();
        }
      });
    }
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msg = this.myApp.crossAppMessageTunnel!;
    if (msg.type == meowAppMessageType.HISTORY_DELETED) {
      if (this.isSelecting) {
        return; // Do nothing.
      }
      meow(`About to sync.`, 'Panel][WoofHistory', meowLevel.INFO);
      const startTime = Date.now(); // Sync.

      // Optimistic update.
      animateToImmediately(defaultAnimation(), () => {
        this.myEntries = this.myEntries.filter((entry) => !(msg.payload as Set<number>).has(entry.time));
      });

      // Report
      const duration = Date.now() - startTime;
      this.refreshInfo(duration);
      
    } else if (msg.type == meowAppMessageType.HISTORY_ADDED) {
      if (this.isSelecting) {
        return; // Do nothing.
      }
      meow(`About to sync for refresh.`, 'Panel][WoofHistory', meowLevel.INFO);
      this.search();
    }
  }

  /**
   * Submit search search. Only rely on this.myHistoryChunk.
   */
  async search() {
    const startTime = Date.now();
    const global = this.myHistoryChunk == undefined;
    animateToImmediately(defaultAnimation(), () => {
      this.isSearching = true;
    });

    // Search
    let res: meowHistoryEntry[];
    if (this.useFastSearch) {
      // Use index
      if (global) {
        res = await this.myMeowHistorian.lookUpHistoryEntries(this.searchKey, Number.MAX_VALUE, false) ?? [];
      } else {
        res = await this.myMeowHistorian.lookUpHistoryEntriesFromChunk(this.myHistoryChunk!, this.searchKey, Number.MAX_VALUE, false) ?? [];
      }
    } else {
      // Use brute force
      if (global) {
        res = await this.myMeowHistorian.lookUpHistoryEntries(this.searchKey, Number.MAX_VALUE, true, 0.8) ?? [];
      } else {
        res = await this.myMeowHistorian.lookUpHistoryEntriesFromChunk(this.myHistoryChunk!, this.searchKey, Number.MAX_VALUE, true, 0.8) ?? [];
      }
    }

    meow(`Looked up history: ["${this.searchKey}", ${Number.MAX_VALUE}], result length ${res.length} (${Date.now() - startTime} ms)`, 'WoofHistory][Panel', meowLevel.WARN);

    // this.myEntries = await this.myMeowHistorian.lookUpHistoryEntries(this.searchKey, Number.MAX_VALUE) ?? [];
    animateToImmediately(defaultAnimation(), () => {
      this.myEntries = res;
      this.isSearching = false;
    });
    const duration = Date.now() - startTime;
    this.refreshInfo(duration);
  }

  selectDeselectItem(item: meowHistoryEntry) {
    if (this.isSelecting) {
      if (this.selectedTimeStamps.has(item.time)) {
        this.selectedTimeStamps.delete(item.time);
      } else {
        this.selectedTimeStamps.add(item.time);
      }
    } else {
      this.requestVisit(item.url);
    }
  }

  deselectAll() {
    this.selectedTimeStamps.clear();
  }

  selectAll() {
    this.selectedTimeStamps = new Set(this.myEntries.map((entry) => entry.time));
  }

  /**
   * Refresh info of this month / current display information.
   * @param duration The duration of the last search process.
   * @returns A string.
   */
  refreshInfo(duration: number) {
    if (this.myHistoryChunk == undefined) {
      const info = `󰀩 (${this.myEntries.length}) (${duration} ms)`;
      this.requestRefreshTitle(info);
      return info;
    } else {
      const info = `${this.myHistoryChunk?.year}-${this.myHistoryChunk?.month} (${this.myEntries.length}/${this.myHistoryChunk?.getSize()}) (${duration} ms)`;
      this.requestRefreshTitle(info);
      return info;
    }
  }
}

export { HistoryPanel };
