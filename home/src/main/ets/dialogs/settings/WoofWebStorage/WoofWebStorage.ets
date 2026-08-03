import lazy { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextButton } from "../../../components/common/MooTextButton";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { UniRowOfCapsuleButtons } from "../../../components/common/UniRowOfCapsuleButtons";
import { standardComponentHeight, standardSpacing } from "../../../components/constants";
import { defaultAnimation } from "../../../components/settings";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WebStoragePanel {
  // Hosts
  @Param @Require myUi: meowUiHost;
  // Local
  @Local webStorageList: [string, number, number][] = []; // [Domain, Usage, Quota]
  @Local searchKey: string = '';
  searchInputId: string = `WoofWebStorage_search_${Date.now().toString(16)}`;
  listScroller: Scroller = new Scroller();
  firstVisibleIndex: number = 0; // The index of the currently topmost visible item, updated by List.onScrollIndex.

  aboutToAppear(): void {
    // If with params (Opened this when browsing something)
    if (this.myUi.myDialog.lastRequest?.param) {
      this.searchKey = this.myUi.myDialog.lastRequest.param as string;
    }
    this.getAll().then(() => {
      // Locate the current site from the list head when opening; stay put on empty key.
      this.jumpToFirst();
    });
  }

  build() {
    Stack() {
      // WebStorage
      List({ space: standardSpacing, scroller: this.listScroller }) {
        if (this.webStorageList.length > 0) {
          Repeat(this.webStorageList)
            .each((item) => {
              ListItem() {
                UniContentCard({ title: item.item[0], icon: $r('sys.symbol.archivebox'), expanded: true }) {
                  Text(`${addUnitsToSize(item.item[1])} / ${addUnitsToSize(item.item[2])} (${(item.item[1] / item.item[2] * 100).toFixed(2)}%)`).attributeModifier(new MooTextModifier());
                  MooCapsuleButton({
                    text: $r('app.string.General_delete'),
                    needDoubleConfirm: true,
                    clickAction: () => {
                      // Clear web storage of this origin.
                      try {
                        webview.WebStorage.deleteOrigin(item.item[0]);
                        animateToImmediately(defaultAnimation(), () => {
                          this.webStorageList.splice(item.index, 1);
                        });
                      } catch (e) {
                        meow(`webview.WebStorage.deleteOrigin("${item.item[0]}"); failed! ${e}`, 'WoofWebStorageDialog', meowLevel.ERROR);
                      }
                    }
                  });
                };
              };
            });
        } else {
          MooTextButton({ text: $r('app.string.General_empty') });
        }
      }
      .borderRadius(defaultRoundedRadius)
      .height('auto')
      .width('100%')
      .margin({ bottom: (standardComponentHeight + standardSpacing) * (this.myUi.myLayout.wideMode ? 2 : 3) })
      .onScrollIndex((start: number) => {
        this.firstVisibleIndex = start; // Keep the topmost visible item up to date.
      });

      // Bottom bar
      Column({ space: standardSpacing }) {
        // Address bar
        MooTextInputV2({
          icon: $r('sys.symbol.magnifyingglass'),
          text: this.searchKey,
          placeholder: '',
          myId: this.searchInputId,
          onChange: (value) => {
            this.searchKey = value;
            // this.searchNext();
          },
          onSubmit: () => {
            this.searchNext();
            setTimeout(() => {
              this.focusInput();
            }, 10);
          }
        });

        UniRowOfCapsuleButtons() {
          // Next
          MooCapsuleButton({
            text: $r('app.string.General_next'),
            clickAction: () => {
              this.searchNext();
            }
          });
          // Last
          MooCapsuleButton({
            text: $r('app.string.General_last'),
            clickAction: () => {
              this.searchLast();
            }
          });
          if (this.myUi.myLayout.wideMode) {
            // Clear
            this.clearAllButton();
          }
        };

        if (!this.myUi.myLayout.wideMode) {
          // Clear
          this.clearAllButton();
        }
      }.alignItems(HorizontalAlign.Start);
    }
    .onAppear(() => {
      this.focusInput();
    })
    .padding(standardSpacing)
    .alignContent(Alignment.Bottom);
  }

  /**
   * The "Clear ALL web storage" button, with double confirm.
   */
  @Builder
  clearAllButton() {
    MooCapsuleButton({
      text: $r('app.string.WebStorage_clearAll'),
      needDoubleConfirm: true,
      clickAction: () => {
        // Clear all WebStorage
        webview.WebStorage.deleteAllData();
        this.webStorageList = [];
        meow(`webview.WebStorage.deleteAllData(true) succeeded`, 'WoofWebStorageDialog', meowLevel.INFO);
      }
    });
  }

  /**
   * Search for the next match below the currently topmost visible item.
   * Does nothing when the search key is empty or no further match exists.
   */
  searchNext() {
    if (!this.searchKey) {
      return;
    }
    const startFrom = this.firstVisibleIndex + 1;
    for (let i = startFrom; i < this.webStorageList.length; i++) {
      if (this.webStorageList[i][0].includes(this.searchKey)) {
        this.listScroller.scrollToIndex(i, true, ScrollAlign.START);
        return;
      }
    }
    // No further match: do nothing.
  }

  /**
   * Search for the previous match above the currently topmost visible item.
   * Does nothing when the search key is empty or no further match exists.
   */
  searchLast() {
    if (!this.searchKey) {
      return;
    }
    const startFrom = this.firstVisibleIndex - 1;
    for (let i = startFrom; i >= 0; i--) {
      if (this.webStorageList[i][0].includes(this.searchKey)) {
        this.listScroller.scrollToIndex(i, true, ScrollAlign.START);
        return;
      }
    }
    // No previous match: do nothing.
  }

  /**
   * Locate the first match from the list head. Used when the dialog opens with a domain param.
   * Does nothing when the search key is empty.
   */
  jumpToFirst() {
    if (!this.searchKey) {
      return;
    }
    for (let i = 0; i < this.webStorageList.length; i++) {
      if (this.webStorageList[i][0].includes(this.searchKey)) {
        this.listScroller.scrollToIndex(i, true, ScrollAlign.START);
        return;
      }
    }
  }

  /**
   * Get all origins and their statuses, and replace the current WebStorageList with the new list.
   */
  async getAll() {
    const newWebStorageList: [string, number, number][] = [];
    try {
      const results = await webview.WebStorage.getOrigins();
      for (const ori of results) {
        newWebStorageList.push([ori.origin, ori.usage, ori.quota]);
      }
    } catch (e) {
      meow(`webview.WebStorage.getOrigins() failed: ${e.code}: ${e.message}`, 'WoofWebStorageDialog', meowLevel.ERROR);
    }
    // Sort by usage descending (largest first).
    newWebStorageList.sort((a, b) => b[1] - a[1]);
    this.webStorageList = newWebStorageList;
  }

  /**
   * Focus input!
   */
  focusInput() {
    try {
      if (getCreateMyApp().freeWindow) {
        this.getUIContext().getFocusController().requestFocus(this.searchInputId);
      }
    } catch (e) {
      meow(`this.getUIContext().getFocusController().requestFocus("${this.searchInputId}"); failed: ${e}`, 'WoofHistory][Panel', meowLevel.ERROR);
    }
  }
}

@CustomDialog
struct WoofWebStorageDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.WebStorage'), shiftBackgroundColor: true, myUi: this.myUi, }) {
      WebStoragePanel({ myUi: this.myUi });
    };
  }
}

export { WoofWebStorageDialog };
