import { AppStorageV2 } from "@kit.ArkUI";
import { meowAvoid } from "../../../catstypicalframework/hosts/meowAvoid";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowUiStatuses } from "../../../hosts/system/windows/classes/meowUiStatuses";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { isPreferRightHand, standardSpacing } from "../../settings";
import { meowButtons } from "../Buttons/constants";
import { MeowButtonsSlot } from "../Buttons/MeowButtonsSlot";
import { MeowSearchBar } from "./MeowSearchBar";

@ComponentV2
struct MeowTitleBar {
  @Param @Require myUi: meowUiStatuses;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Row({ space: standardSpacing * 0.125 }) {
      if ((this.mySettings.settingsData[76].value as meowButtons[]).length > 0) {
        MeowButtonsSlot({
          myUi: this.myUi,
          myDialog: this.myDialog,
          buttons: this.mySettings.settingsData[76].value as meowButtons[]
        });
      }

      if (this.myLayout.wideMode) {
        MeowSearchBar({
          myUi: this.myUi,
          myDialog: this.myDialog,
          myAvoid: this.myAvoid,
        }).layoutWeight(1).padding(isPreferRightHand() ? { left: standardSpacing * 0.75 } : { right: standardSpacing * 0.75 });
      } else {
        Blank();
      }

      if ((this.mySettings.settingsData[79].value as meowButtons[]).length > 0) {
        MeowButtonsSlot({
          myUi: this.myUi,
          myDialog: this.myDialog,
          buttons: this.mySettings.settingsData[79].value as meowButtons[]
        });
      }
    }
    .height(MeowTitleBarHeight)
    .width('100%')
    .padding({ left: this.myAvoid.left, right: this.myAvoid.right });
  }
}

export { MeowTitleBar };

export const MeowTitleBarHeight = 36;
