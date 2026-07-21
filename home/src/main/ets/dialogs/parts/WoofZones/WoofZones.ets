import { MeowZones } from "../../../components/parts/Zones/MeowZones";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@CustomDialog
export struct WoofZonesDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Zones_title'), myUi: this.myUi }) {
      MeowZones({ myUi: this.myUi });
    };
  }
}
