import lazy { webview } from "@kit.ArkWeb";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { standardSpacing } from "../../../components/constants";
import { meowTabInfo } from "../../../hosts/app/tabs/classes/meowTabInfo";
import { userAgentList, userAgentSelected } from "../../../hosts/app/tabs/settings";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQuickUAPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  @Local myApp: meowAppHost = getCreateMyApp();
  // Local
  @Local selectedIndexUA: number = -2;
  @Local refreshFlagUA: boolean = false;
  @Local tabUa: string = '';
  // Event
  @Event onSelect: (n: number) => void;

  async getCurrentWebUAIndex(): Promise<number> {
    // This won't happen, will it?
    if (!this.myUi.myDialog.lastRequest) {
      return userAgentSelected();
    };

    // 99.9% of cases
    const tabInfo = this.myUi.myDialog.lastRequest.param as meowTabInfo;
    this.tabUa = await tabInfo.myUa();
    if (this.tabUa) {
      // See which CUSTOM UA is selected.
      const findIdx = userAgentList().findIndex((ua) => ua[1] == this.tabUa);
      if (findIdx == -1) {
        // Compare with the ArkWeb default.
        const defaultUA = webview.WebviewController.getDefaultUserAgent(); // Is this method efficient enough?
        if (this.tabUa == defaultUA) {
          return -1;
        }
        // NOT FOUND, return -2 so that none of them is highlighted.
        return -2;
      } else {
        return findIdx;
      }
    } else {
      // Is this ever gonna happen?
      return -2;
    }
  }

  aboutToAppear(): void {
    this.getCurrentWebUAIndex().then((idx) => {
      this.selectedIndexUA = idx;
    });
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.QuickUA'), shiftBackgroundColor: true, myUi: this.myUi,
      tutorial: `󰈈  ${this.tabUa}`, showTutorial: true
    }) {
      MooStringPairArrayList({
        defaultItem: ['HarmonyOS', ''], // Leaving this empty is good enough. You can see below there is special treatment for n < 0.
        selectedIndex: this.selectedIndexUA,
        array: this.getUAs(),
        maxheight: undefined,
        allowAdd: false,
        allowEdit: false,
        allowSelect: true,
        onSelect: (n) => {
          this.onSelect(n);
        },
      })
        .padding(standardSpacing);
    };
  }

  getUAs() {
    this.refreshFlagUA;
    return Array.from(userAgentList());
  }

  /**
   * Syncing the panels across windows.
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.SETTINGS_UA_REFRESH) {
      const newIdx = this.myApp.crossAppMessageTunnel?.payload as number;
      if (newIdx != this.selectedIndexUA) {
        this.refreshFlagUA = !this.refreshFlagUA;
        this.selectedIndexUA = newIdx;
      }
    }
  }
}

@CustomDialog
struct WoofQuickUADialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;
  // TabInfo
  targetTabInfo: meowTabInfo | undefined;
  @State ua: string = '';

  aboutToAppear(): void {
    // Get the meowTabInfo from the tunnel
    const req = this.myUi.myDialog.lastRequest;
    this.targetTabInfo = req?.param as meowTabInfo;
    // Get UA.
    this.targetTabInfo.myUa().then((ua) => {
      this.ua = ua;
    });
  }

  build() {
    WoofQuickUAPanel({
      controller: this.controller,
      myUi: this.myUi,
      onSelect: (n) => {
        if (this.targetTabInfo) {
          if (n < 0) {
            this.targetTabInfo.resetTabUA(); // Reset to default.
          } else {
            this.targetTabInfo.overrideTabUA(userAgentList()[n][1]); // Apply to current web.
          }
        }
        this.controller.close();
      }
    });
  }
}

export { WoofQuickUADialog };
