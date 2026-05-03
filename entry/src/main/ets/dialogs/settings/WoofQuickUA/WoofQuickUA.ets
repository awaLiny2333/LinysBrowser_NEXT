import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowAppStatuses } from "../../../hosts/system/windows/classes/meowAppStatuses";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQuickUAPanel {
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  // Local
  @Local selectedIndexUA: number = this.getCurrentWebUAIndex();
  @Local refreshFlagUA: boolean = false;
  // Event
  @Event onSelect: (n: number) => void;

  getCurrentWebUAIndex() {
    if (this.myDialog.lastRequest) {
      return this.myDialog.lastRequest.param as number;
    };
    return 0;
  }

  build() {
    MooStringPairArrayList({
      defaultItem: ['HarmonyOS', ''], // TODO: set this to the real default UA.
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
    return Array.from(this.mySettings.settingsData[41].value as string[][]);
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

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.QuickUA'), myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofQuickUAPanel({
        myDialog: this.myDialog,
        onSelect: (n) => {
          // Apply to current web.
          meow(`Apply user agent #${n} from QuickUA!`, 'WoofQuickUA', meowLevel.WARN);
          this.controller.close();
        }
      });
    };
  }
}

export { WoofQuickUADialog };
