import lazy { webview } from "@kit.ArkWeb";
import lazy { BusinessError } from "@kit.BasicServicesKit";
import lazy { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextButton } from "../../../components/common/MooTextButton";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
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
  @Local WebStorage: [string, number, number][] = []; // [Domain, Usage, Quota]
  @Local searchKey: string = '';
  searchInputId: string = `WoofWebStorage_search_${Date.now().toString(16)}`;
  listScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    // If with params (Opened this when browsing something)
    if (this.myUi.myDialog.lastRequest?.param) {
      this.searchKey = this.myUi.myDialog.lastRequest.param as string;
    }
    this.getAll().then(() => {
      setTimeout(() => {
        this.search();
      }, 10);
    });
  }

  build() {
    Stack() {
      // WebStorage
      List({ space: standardSpacing, scroller: this.listScroller }) {
        if (this.WebStorage.length > 0) {
          Repeat(this.WebStorage)
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
                          this.WebStorage.splice(item.index, 1);
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
      .margin({ bottom: standardComponentHeight * 2 + standardSpacing * 2 });

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
            // this.search();
          },
          onSubmit: () => {
            this.search();
            setTimeout(() => {
              this.focusInput();
            }, 10);
          }
        });

        // Clear
        MooCapsuleButton({
          text: $r('app.string.WebStorage_clearAll'),
          needDoubleConfirm: true,
          clickAction: () => {
            // Clear all WebStorage
            webview.WebStorage.deleteAllData();
            this.WebStorage = [];
            meow(`webview.WebStorage.deleteAllData(true) succeeded`, 'WoofWebStorageDialog', meowLevel.INFO);
          }
        });
      }.alignItems(HorizontalAlign.Start);
    }
    .onAppear(() => {
      this.focusInput();
    })
    .padding(standardSpacing)
    .alignContent(Alignment.Bottom);
  }

  /**
   * Search!
   */
  async search() {
    let index = 0;
    for (const storage of this.WebStorage) {
      if (storage[0].includes(this.searchKey)) {
        this.listScroller.scrollToIndex(index, true);
        break;
      }
      index += 1;
    }
  }

  async getAll() {
    const newWebStorageList: [string, number, number][] = [];
    await webview.WebStorage.getOrigins()
      .then((results) => {
        for (const ori of results) {
          newWebStorageList.push([ori.origin, ori.usage, ori.quota]);
        }
      })
      .catch((e: BusinessError) => {
        meow(`webview.WebStorage.getOrigins() failed: ${e.code}: ${e.message}`, 'WoofWebStorageDialog', meowLevel.ERROR);
      });
    setTimeout(() => {
      animateToImmediately(defaultAnimation(), () => {
        this.WebStorage = newWebStorageList;
      });
    });
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
