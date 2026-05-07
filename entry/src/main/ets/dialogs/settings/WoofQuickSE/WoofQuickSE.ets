import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowAppStatuses } from "../../../hosts/system/windows/classes/meowAppStatuses";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { defaultSearchEngine } from "../../../hosts/userdata/settings/scripts/defaultSettingsValues";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQuickSEPanel {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  // Local
  @Local selectedIndexSE: number = this.getCurrentWebSEIndex();
  @Local refreshFlagSE: boolean = false;
  // Event
  @Event onSelect: (n: number) => void;

  getCurrentWebSEIndex() {
    if (this.myDialog.lastRequest) {
      return this.myDialog.lastRequest.param as number;
    };
    return 0;
  }

  build() {
    MooStringPairArrayList({
      defaultItem: ['Bing', defaultSearchEngine()],
      selectedIndex: this.selectedIndexSE,
      array: this.getSEs(),
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

  getSEs() {
    this.refreshFlagSE;
    return Array.from(this.mySettings.settingsData[43].value as string[][]);
  }

  /**
   * Syncing the panels across windows.
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.SETTINGS_SE_REFRESH) {
      const newIdx = this.myApp.crossAppMessageTunnel?.payload as number;
      if (newIdx != this.selectedIndexSE) {
        this.refreshFlagSE = !this.refreshFlagSE;
        this.selectedIndexSE = newIdx;
      }
    }
  }
}

@CustomDialog
struct WoofQuickSEDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myUi: meowUiHost;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.QuickSE'), shiftBackgroundColor: true, myLayout: this.myLayout, myDialog: this.myDialog,
      tutorial: `󰀩 ${this.myUi.searchKeywordEntries.length > 0 ? this.myUi.searchKeywordEntries[0][1] : this.myUi.addressBarContent}`, showTutorial: true
    }) {
      WoofQuickSEPanel({
        myLayout: this.myLayout,
        myDialog: this.myDialog,
        myUi: this.myUi,
        onSelect: (n) => {
          // Apply to current web.
          meow(`Apply Search Engine #${n} from QuickSE!`, 'WoofQuickSE', meowLevel.WARN);
          this.controller.close();
        }
      });
    };
  }
}

export { WoofQuickSEDialog };
