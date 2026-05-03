import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { userCredits } from "./creditDetails";
import { CreditUser } from "./CreditUser";

@ComponentV2
struct UserCredits {
  @Param @Require myLayout: meowLayout;

  build() {
    // The list
    List({ space: standardSpacing }) {
      ListItem(); // push the padding
      Repeat(userCredits)
        .each((item) => {
          CreditUser({
            myLayout: this.myLayout,
            details: item.item
          });
        })
        .virtualScroll();
      ListItem(); // push the padding
    }
    .width('100%')
    .height('auto');
  }
}

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
      UserCredits({ myLayout: this.myLayout });
    };
  }
}

export { WoofCreditsDialog };
