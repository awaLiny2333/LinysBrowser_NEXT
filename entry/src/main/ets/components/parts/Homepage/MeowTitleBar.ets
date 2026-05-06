import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { standardSpacing } from "../../settings";
import { meowButtonsType } from "../Buttons/constants";
import { MeowButtonsSlot } from "../Buttons/MeowButtonsSlot";
import { MeowAddressBar } from "./MeowAddressBar";

// const mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // meowManagedSettings is not initialized until the process in flow is done. This would crash the app.

@Builder
export function MeowTitleBar(myUi: meowUiHost, myLayout: meowLayout, myDialog: meowDialogManager, mySettings: meowManagedSettings) {
  Row({ space: standardSpacing * 0.125 }) {
    if ((mySettings.settingsData[76].value as meowButtonsType[]).length > 0) {
      MeowButtonsSlot(myUi, myDialog, 76);
    }

    if (myLayout.wideMode) {
      MeowAddressBar({
        myUi: myUi,
        myLayout: myLayout,
        myDialog: myDialog,
      });
    } else {
      Blank();
    }

    if ((mySettings.settingsData[79].value as meowButtonsType[]).length > 0) {
      MeowButtonsSlot(myUi, myDialog, 79);
    }
  }
  .height(MeowTitleBarHeight)
  .width('100%');
}

export const MeowTitleBarHeight = 36;
