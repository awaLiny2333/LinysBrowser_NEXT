import { meowAvoid } from "../../catstypicalframework/hosts/meowAvoid";
import { meowLayoutModeStatus } from "../../catstypicalframework/hosts/meowLayoutModeStatus";
import { meowDialogManager, openDialogRequestType } from "../../hosts/env/classes/meowDialogManager";
import { meowUiStatuses } from "../../hosts/env/classes/meowUiStatuses";
import { requestDialog } from "../../hosts/env/scripts/dialog";
import { MooSymbolButton } from "../common/MooSymbolButton";
import { MeowSearchBar } from "./MeowSearchBar";

@ComponentV2
struct MeowTitleBar {
  @Param @Require myMeowUiStatuses: meowUiStatuses;
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowLayout: meowLayoutModeStatus;
  @Param @Require myMeowDialogManager: meowDialogManager;

  build() {
    Row({ space: 1 }) {
      MooSymbolButton({ icon: $r('sys.symbol.arrow_left') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_right') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_clockwise') });
      MooSymbolButton({ icon: $r('sys.symbol.house') });

      if (this.myMeowLayout.wideMode) {
        MeowSearchBar({
          myMeowAvoid: this.myMeowAvoid,
        })
          .layoutWeight(1);
      } else {
        Blank();
      }

      MooSymbolButton({
        icon: $r('sys.symbol.dot_grid_2x2'),
        onHold: this.myMeowUiStatuses.showMore,
        clickAction: () => {
          this.myMeowUiStatuses.showMore = !this.myMeowUiStatuses.showMore;
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
          requestDialog(this.myMeowDialogManager, openDialogRequestType.SETTINGS);
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
