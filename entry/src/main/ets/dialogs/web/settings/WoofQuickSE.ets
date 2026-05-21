import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { MooStringPairArrayList } from "../../../components/common/MooStringPairArrayList";
import { standardSpacing } from "../../../components/constants";
import { concatSearchWithEngine, concatSeStatus } from "../../../hosts/app/tabs/scripts/searchEngines";
import { searchEngineList } from "../../../hosts/app/tabs/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { getMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { defaultSearchEngine } from "../../../hosts/userdata/settings/scripts/defaultSettingsValues";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQuickSEPanel {
  @Param @Require myDialog: meowDialogManager;
  @Local myApp: meowAppHost = getMyApp();
  // Local
  @Local selectedIndexSE: number = -2; // show no selection
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
    return Array.from(searchEngineList());
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
      tutorial: `󰀩  ${this.searchQuery()}`, showTutorial: true
    }) {
      WoofQuickSEPanel({
        myDialog: this.myDialog,
        onSelect: (n) => {
          const targetSE = n >= 0 ? searchEngineList()[n][1] : undefined;
          const concatSearchR = concatSearchWithEngine(this.searchQuery(), targetSE);
          if (concatSearchR.status == concatSeStatus.SUCCESS) {
            meow(`Apply Search Engine #${n} - [${targetSE}] from QuickSE!`, 'WoofQuickSE', meowLevel.WARN);
            this.myUi.submitSearchOrLoad(concatSearchR.result);
          }
          this.controller.close();
        }
      });
    };
  }

  searchQuery() {
    return this.myUi.searchKeywordEntries.length > 0 ? this.myUi.searchKeywordEntries[0][1] : this.myUi.addressBarContentMajor;
  }
}

export { WoofQuickSEDialog };
