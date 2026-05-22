import { meowLayout } from "../../../../catstypicalframework/hosts/meowLayout";
import { meowDialogManager } from "../../../../hosts/system/dialogs/classes/meowDialogManager";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardComponentHeight, standardSpacing, textInputSlimHeight } from "../../../constants";
import { meowButtonsControl, meowButtonsTitle } from "../../../settings";
import { MeowButtonsSlot } from "../../MeowButtons/MeowButtonsSlot";
import { MeowAddressBar } from "../addressBar/MeowAddressBar";

@Builder
export function MeowTitleBar(myUi: meowUiHost, myLayout: meowLayout, myDialog: meowDialogManager) {
  Row({ space: standardSpacing * 0.125 }) {
    if (meowButtonsControl().length > 0) {
      MeowButtonsSlot(myUi, myDialog, 76);
    }

    if (myLayout.wideMode && !myUi.dropHover) {
      MeowAddressBar({
        myUi: myUi,
        myLayout: myLayout,
        myDialog: myDialog,
      });
    } else {
      if (myLayout.wideMode && myUi.dropHover) {
        Text($r('app.string.ScratchingBoard_drop')).attributeModifier(new MooTextModifier()).layoutWeight(1).textAlign(TextAlign.Center).height(standardComponentHeight);
      } else {
        Blank();
      }
    }

    if (meowButtonsTitle().length > 0) {
      MeowButtonsSlot(myUi, myDialog, 79);
    }
  }
  .height(textInputSlimHeight)
  .width('100%');
}
