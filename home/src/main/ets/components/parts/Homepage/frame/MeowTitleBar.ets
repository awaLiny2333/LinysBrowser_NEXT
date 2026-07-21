import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardComponentHeight, standardSpacing, textInputSlimHeight, titleTopLeftRightMargin } from "../../../constants";
import { meowButtonsControl, meowButtonsTitle, titleBarPositionBottom } from "../../../settings";
import { MeowButtonsSlot } from "../../MeowButtons/MeowButtonsSlot";
import { MeowAddressBar } from "../addressBar/MeowAddressBar";

@Builder
export function MeowTitleBar(myUi: meowUiHost) {
  Row({ space: standardSpacing * 0.125 }) {
    if (meowButtonsControl().length > 0) {
      MeowButtonsSlot(myUi, 76);
    }

    if (myUi.myLayout.wideMode && !myUi.dropHover) {
      MeowAddressBar({ myUi: myUi });
    } else {
      if (myUi.myLayout.wideMode && myUi.dropHover) {
        Text($r('app.string.ScratchingBoard_drop')).attributeModifier(new MooTextModifier()).layoutWeight(1).textAlign(TextAlign.Center).height(standardComponentHeight);
      } else {
        Blank();
      }
    }

    if (meowButtonsTitle().length > 0) {
      MeowButtonsSlot(myUi, 79);
    }
  }
  .padding(myUi.titleTopCanShift && !titleBarPositionBottom() && (!myUi.showTabs || myUi.showingVerticalTabs) ? titleTopLeftRightMargin : 0)
  .height(textInputSlimHeight)
  .width('100%');
}
