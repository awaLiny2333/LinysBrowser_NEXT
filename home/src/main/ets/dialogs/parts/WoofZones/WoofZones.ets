import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MeowZones } from "../../../components/parts/Zones/MeowZones";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@CustomDialog
export struct WoofZonesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Zones_title'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      MeowZones({ myLayout: this.myLayout });
    };
  }
}
