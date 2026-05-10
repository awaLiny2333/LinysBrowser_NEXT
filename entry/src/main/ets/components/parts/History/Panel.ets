import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { defaultInnerRadius, defaultItemRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooTextInputV2 } from "../../common/MooTextInputV2";
import { MooTextModifier } from "../../common/MooTextModifier";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../../settings";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { globalMessage, meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowHistorian } from "../../../hosts/userdata/history/classes/meowHistorian";
import { meowHistoryChunk } from "../../../hosts/userdata/history/classes/meowHistoryChunk";
import { meowHistoryEntry } from "../../../hosts/userdata/history/classes/meowHistoryEntry";
import { groupByDates } from "../../../hosts/userdata/history/scripts/helpers";
import { DayCard } from "./parts/DayCard";
import { defaultMonthButtonHeight, MonthButton } from "./parts/MonthButton";
import { standardSpacing, meowThemeColorType } from "../../constants";
import { getMyApp } from "../../../hosts/system/windows/scripts/helpers";

@ComponentV2
struct HistoryPanel {
  // Config
  @Param @Once allowEdit: boolean = true;
  @Param @Once needPadding: boolean = true;
  // Host
  @Param @Require myLayout: meowLayout;
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!;
  @Local myApp: meowAppHost = getMyApp();
  // Display
  @Local myHistoryChunk: meowHistoryChunk | undefined;
  @Local myEntries: meowHistoryEntry[] = [];
  @Local myEntriesGrouped: meowHistoryEntry[][] = [];
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
        Repeat(this.myEntriesGrouped)
          .each((obj: RepeatItem<meowHistoryEntry[]>) => {
            DayCard({
              myLayout: this.myLayout,
              obj: obj.item,
              selectedTimeStamps: this.selectedTimeStamps,
              isSelecting: this.isSelecting,
              requestVisit: (url) => {
                this.requestVisit(url);
              },
            });
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
              if (this.myApp.freeWindow) {
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
            this.myEntriesGrouped = groupByDates(this.myEntries);
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
        // Do nothing.
        return;
      }

      meow(`About to sync.`, 'Panel][WoofHistory', meowLevel.INFO);

      // Sync.
      const startTime = Date.now();

      // Optimistic update.
      animateToImmediately(defaultAnimation(), () => {
        this.myEntries = this.myEntries.filter((entry) => !(msg.payload as Set<number>).has(entry.time));
        this.myEntriesGrouped = groupByDates(this.myEntries);
      });

      // Report
      const duration = Date.now() - startTime;
      this.refreshInfo(duration);
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
      this.myEntriesGrouped = groupByDates(res);
      this.isSearching = false;
    });
    const duration = Date.now() - startTime;
    this.refreshInfo(duration);
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
