import { AppStorageV2 } from "@kit.ArkUI";
import lazy { webview } from "@kit.ArkWeb";
import lazy { BusinessError } from "@kit.BasicServicesKit";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import lazy { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { defaultMooCapsuleButtonHeight, MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextButton } from "../../../components/common/MooTextButton";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowAppStatuses } from "../../../hosts/system/windows/classes/meowAppStatuses";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct CookiesPanel {
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  // Local
  @Local cookies: string | undefined = undefined;
  @Local searchKey: string = '';
  searchInputId: string = `WoofCookies_search_${Date.now().toString(16)}`;

  aboutToAppear(): void {
    // If with params (Opened this when browsing something)
    if (this.myDialog.lastRequest && this.myDialog.lastRequest.param) {
      this.searchKey = this.myDialog.lastRequest.param as string;
      this.search();
    }
  }

  build() {
    Stack() {
      // Cookies
      List() {
        ListItem() {
          if (this.cookies) {
            Text(this.cookies).attributeModifier(new MooTextModifier());
          } else {
            MooTextButton({
              text: $r('app.string.General_empty'),
            });
          }
        };
      }
      .height('auto')
      .width('100%')
      .margin({ bottom: defaultMooCapsuleButtonHeight * 2 + standardSpacing * 2 });

      // Bottom bar
      Column({ space: standardSpacing }) {
        // Search bar
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
          text: $r('app.string.Cookies_clearAll'),
          needDoubleConfirm: true,
          clickAction: () => {
            // Clear all cookies
            webview.WebCookieManager.clearAllCookiesSync();
            this.cookies = undefined;
            meow(`webview.WebCookieManager.clearAllCookiesSync() succeeded`, 'WoofCookiesDialog', meowLevel.INFO);
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
  search() {
    webview.WebCookieManager.fetchCookie(this.searchKey)
      .then((cookies) => {
        this.cookies = cookies;
        meow(`webview.WebCookieManager.fetchCookie("${this.searchKey}") succeeded: ${cookies}`, 'WoofCookiesDialog', meowLevel.INFO);
      })
      .catch((e: BusinessError) => {
        meow(`webview.WebCookieManager.fetchCookie("${this.searchKey}") failed: ${e.code}: ${e.message}`, 'WoofCookiesDialog', meowLevel.ERROR);
      });
  }

  /**
   * Focus input!
   */
  focusInput() {
    try {
      if (this.myApp.freeWindow) {
        this.getUIContext().getFocusController().requestFocus(this.searchInputId);
      }
    } catch (e) {
      meow(`this.getUIContext().getFocusController().requestFocus("${this.searchInputId}"); failed: ${e}`, 'WoofHistory][Panel', meowLevel.ERROR);
    }
  }
}

@CustomDialog
struct WoofCookiesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller,
      title: $r('app.string.Cookies'),
      shiftBackgroundColor: true,
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      CookiesPanel({ myDialog: this.myDialog, myLayout: this.myLayout });
    };
  }
}

export { WoofCookiesDialog };
