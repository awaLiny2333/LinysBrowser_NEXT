import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { UserCredits } from "./parts/Credit";

@CustomDialog
struct WoofCreditsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.UserCredits'),
    }) {
      UserCredits({
        myLayout: this.myLayout,
        requestVisit: (url) => {
          meow(`Visit [${url}]!`, 'WoofCreditsDialog', meowLevel.WARN);
          this.myDialog.closeAll();
        }
      });
    };
  }
}

export { WoofCreditsDialog };
