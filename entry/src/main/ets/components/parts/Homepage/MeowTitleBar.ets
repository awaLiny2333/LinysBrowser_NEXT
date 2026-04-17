import { meowAvoid } from "../../../catstypicalframework/hosts/meowAvoid";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meowDialogManager, openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowUiStatuses } from "../../../hosts/system/windows/classes/meowUiStatuses";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { defaultAnimation } from "../../settings";
import { MeowSearchBar } from "./MeowSearchBar";

@ComponentV2
struct MeowTitleBar {
  @Param @Require myUi: meowUiStatuses;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;

  build() {
    Row({ space: 1 }) {
      MooSymbolButton({ icon: $r('sys.symbol.arrow_left') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_right') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_clockwise') });
      MooSymbolButton({ icon: $r('sys.symbol.house') });

      if (this.myLayout.wideMode) {
        MeowSearchBar({
          myAvoid: this.myAvoid,
        })
          .layoutWeight(1);
      } else {
        Blank();
      }

      MooSymbolButton({
        icon: $r('sys.symbol.dot_grid_2x2'),
        onHold: this.myUi.showMore,
        clickAction: () => {
          animateToImmediately(defaultAnimation(), () => {
            this.myUi.showMore = !this.myUi.showMore;
          });
        }
      });
      /**
       * TODO: Custom buttons.
       */
      MooSymbolButton({
        icon: $r('sys.symbol.rectangle_stack'),
        onHold: this.myUi.showTabs,
        clickAction: () => {
          this.myUi.showTabs = !this.myUi.showTabs;
        }
      });
      MooSymbolButton({
        icon: $r('sys.symbol.bookmark'),
        clickAction: () => {
          requestDialog(this.myDialog, openDialogRequestType.BOOKMARKS);
        }
      });
      MooSymbolButton({ icon: $r('sys.symbol.download') });
      MooSymbolButton({
        icon: $r('sys.symbol.gearshape'),
        clickAction: () => {
          requestDialog(this.myDialog, openDialogRequestType.SETTINGS);
        }
      });
    }
    // .direction(preferRightHand() ? Direction.Ltr : Direction.Rtl)
    .height(heightMeowTitleBar)
    .width('100%')
    .padding({ left: this.myAvoid.left, right: this.myAvoid.right });
  }
}

export { MeowTitleBar };

export const heightMeowTitleBar = 36;
