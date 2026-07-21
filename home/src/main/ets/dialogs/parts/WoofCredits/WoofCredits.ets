import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";
import { UserCredits } from "./parts/Credit";

@CustomDialog
struct WoofCreditsDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({
      controller: this.controller, myUi: this.myUi, shiftBackgroundColor: true,
      title: $r('app.string.UserCredits'),
    }) {
      UserCredits({
        myUi: this.myUi,
        requestVisit: (url) => {
          meow(`Visit [${url}]!`, 'WoofCreditsDialog', meowLevel.WARN);
          this.myUi.myDialog.closeAll();
        }
      });
    };
  }
}

export { WoofCreditsDialog };
