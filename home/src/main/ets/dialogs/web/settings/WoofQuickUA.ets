import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { standardSpacing } from "../../../components/constants";
import { meowTabInfo } from "../../../hosts/app/tabs/classes/meowTabInfo";
import { userAgentList, userAgentSelected } from "../../../hosts/app/tabs/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQuickUAPanel {
  @Param @Require myDialog: meowDialogManager;
  @Local myApp: meowAppHost = getCreateMyApp();
  // Local
  @Local selectedIndexUA: number = this.getCurrentWebUAIndex();
  @Local refreshFlagUA: boolean = false;
  // Event
  @Event onSelect: (n: number) => void;

  getCurrentWebUAIndex(): number {
    if (!this.myDialog.lastRequest) {
      return userAgentSelected();
    };
    const tabInfo = this.myDialog.lastRequest.param as meowTabInfo;
    if (tabInfo.overrideUA) {
      return userAgentList().findIndex((ua) => ua[1] == tabInfo.overrideUA);
    } else {
      return userAgentSelected();
    }
  }

  build() {
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
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  // TabInfo
  targetTabInfo: meowTabInfo | undefined;

  aboutToAppear(): void {
    // Get the meowTabInfo from the tunnel
    const req = this.myDialog.lastRequest;
    this.targetTabInfo = req?.param as meowTabInfo;
  }

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.QuickUA'), shiftBackgroundColor: true, myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofQuickUAPanel({
        myDialog: this.myDialog,
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
    };
  }
}

export { WoofQuickUADialog };
