import { AppStorageV2 } from "@kit.ArkUI";
import { meowAvoid } from "../../catstypicalframework/hosts/meowAvoid";
import { meowLayoutModeStatus } from "../../catstypicalframework/hosts/meowLayoutModeStatus";
import { openDialogRequestType, requestDialog } from "../../hosts/env/classes/meowDialogManager";
import { meowUiStatuses } from "../../hosts/env/classes/meowUiStatuses";
import { MooSymbolButton } from "../common/MooSymbolButton";
import { MeowSearchBar } from "./MeowSearchBar";

@ComponentV2
struct MeowTitleBar {
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect(meowAvoid)!;
  @Local meowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus)!;

  build() {
    Row({ space: 1 }) {
      MooSymbolButton({ icon: $r('sys.symbol.arrow_left') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_right') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_clockwise') });
      MooSymbolButton({ icon: $r('sys.symbol.house') });

      if (this.myMeowLayout.wideMode) {
        MeowSearchBar().layoutWeight(1);
      } else {
        Blank();
      }

      MooSymbolButton({
        icon: $r('sys.symbol.dot_grid_2x2'),
        onHold: this.meowUiStatuses.showMore,
        clickAction: () => {
          this.meowUiStatuses.showMore = !this.meowUiStatuses.showMore;
        }
      });
      /**
       * TODO: Custom buttons.
       */
      MooSymbolButton({ icon: $r('sys.symbol.rectangle_stack') });
      MooSymbolButton({ icon: $r('sys.symbol.bookmark') });
      MooSymbolButton({ icon: $r('sys.symbol.download') });
      MooSymbolButton({
        icon: $r('sys.symbol.gearshape'),
        clickAction: () => {
          requestDialog(openDialogRequestType.SETTINGS);
        }
      });
    }
    // .direction(preferRightHand() ? Direction.Ltr : Direction.Rtl)
    .height(heightMeowTitleBar)
    .width('100%')
    .padding({ left: this.myMeowAvoid.left, right: this.myMeowAvoid.right });
  }
}

export { MeowTitleBar };

export const heightMeowTitleBar = 36;
