import lazy { webview } from "@kit.ArkWeb";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { MooSwitch } from "../../../components/common/MooSwitch";
import { standardComponentHeight, standardSpacing } from "../../../components/constants";
import { defaultAnimation } from "../../../components/settings";
import { meowTabInfo } from "../../../hosts/app/tabs/classes/meowTabInfo";
import { userAgentList } from "../../../hosts/app/tabs/settings";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { WoofUniFrame } from "../../WoofUniFrame";

const SYSTEM = -1; // The default HarmonyOS System UA.
const UNKNOWN = -2; // Unknown UA.

@ComponentV2
struct WoofQuickUAPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  @Param @Require tabInfo: meowTabInfo;
  @Local myApp: meowAppHost = getCreateMyApp();
  // Local
  @Local selectedIndexUA: number = -2;
  @Local refreshFlagUA: boolean = false;
  @Local tabUa: string = '';
  // Event
  @Event onSelect: (n: number, callClose: boolean) => void;
  @Event callClose: () => void;

  /**
   * Fetches the REAL UA from the tab using JS injection. And returns the index of that UA.
   * @returns index of that UA.
   */
  async getCurrentWebUAIndex(): Promise<number> {
    if (!this.tabInfo) {
      return UNKNOWN;
    }

    // Check
    this.tabUa = await this.tabInfo.myUa();
    if (this.tabUa) {
      // See which CUSTOM UA is selected.
      const findIdx = userAgentList().findIndex((ua) => ua[1] == this.tabUa);
      if (findIdx == -1) {
        // Real UA not found in user's custom list. Perhaps is the default system UA?
        // Compare with the ArkWeb default.
        const defaultUA = webview.WebviewController.getDefaultUserAgent(); // Is this method efficient enough?
        if (this.tabUa == defaultUA) {
          return SYSTEM;
        }
        // IS NOT the system UA. Then this UA is not in our knowledge.
        // Return -2 so that none of them is highlighted.
        return UNKNOWN;
      } else {
        return findIdx;
      }
    } else {
      // Cannot read UA or UA is empty.
      // Is this ever gonna happen?
      return UNKNOWN;
    }
  }

  aboutToAppear(): void {
    this.getCurrentWebUAIndex()
      .then((idx) => {
        this.selectedIndexUA = idx;
      });
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.QuickUA'), shiftBackgroundColor: true, myUi: this.myUi,
      tutorial: `󰈈  ${this.tabUa}`, showTutorial: true
    }) {
      Stack() {
        MooSwitch({
          text: $r('app.string.QuickUA_enableOverride'),
          isOn: this.tabInfo?.lockedOverrideUA !== undefined,
          onChange: (c) => {
            if (c) {
              // turn on.
              if (this.tabInfo?.lockedOverrideUA === undefined) {
                this.onSelect(SYSTEM, false);
                this.selectedIndexUA = SYSTEM;
              }
            } else {
              // turn off.
              if (this.tabInfo) {
                this.tabInfo.lockedOverrideUA = undefined;
                this.tabInfo.updateSlimOrHostUA();
              }
              this.callClose();
            }
          }
        })
          .padding({ left: standardSpacing, right: standardSpacing });

        // The list.
        MooStringPairArrayList({
          defaultItem: ['HarmonyOS', ''], // Leaving this empty is good enough. You can see below there is special treatment for n < 0.
          selectedIndex: this.tabInfo?.lockedOverrideUA === undefined ? UNKNOWN : this.selectedIndexUA,
          array: this.getUAs(),
          maxheight: undefined,
          allowAdd: false,
          allowEdit: false,
          allowSelect: true,
          onSelect: (n) => {
            this.onSelect(n, true);
            this.selectedIndexUA = n;
          },
        })
          .opacity(this.tabInfo?.lockedOverrideUA === undefined ? 0.6 : 1)
          .animation(defaultAnimation())
          .margin({ top: standardComponentHeight - standardSpacing })
          .padding(standardSpacing);
      }
      .alignContent(Alignment.Top);
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

  aboutToAppear(): void {
    // Get the meowTabInfo from the tunnel
    const req = this.myUi.myDialog.lastRequest;
    this.targetTabInfo = req?.param as meowTabInfo;
  }

  build() {
    WoofQuickUAPanel({
      controller: this.controller,
      myUi: this.myUi,
      tabInfo: this.targetTabInfo,
      onSelect: (n, callClose) => {
        if (this.targetTabInfo) {
          if (n < 0) {
            this.targetTabInfo.overrideTabUA(); // Override with default.
          } else {
            this.targetTabInfo.overrideTabUA(userAgentList()[n][1]); // Apply to current web.
          }
        }
        if (callClose) {
          this.closeMe();
        }
      },
      callClose: () => {
        this.closeMe();
      }
    });
  }

  closeMe() {
    setTimeout(() => {
      try {
        this.controller.close();
      } catch (e) {
        // ignore.
      }
    }, 200);
  }
}

export { WoofQuickUADialog };
