import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { defaultAnimation } from "../../settings";

@Builder
export function shrinkButton(myUi: meowUiHost) {
  SymbolButton({
    icon: myUi.sideAreaShrunkSummarized ? $r('sys.symbol.arrow_up_left_and_arrow_down_right') : $r('sys.symbol.arrow_down_right_and_arrow_up_left'),
    clickAction: () => {
      if (myUi.sideAreaShrinkBlock) {
        return;
      }
      animateToImmediately(defaultAnimation(), () => {
        myUi.sideAreaShrunkExpect = !myUi.sideAreaShrunkExpect;
      });
    }
  })
    .opacity(myUi.sideAreaShrinkBlock ? 0.5 : 1);
}
