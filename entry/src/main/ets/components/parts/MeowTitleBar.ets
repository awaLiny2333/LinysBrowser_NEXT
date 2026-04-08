import { meowAvoid } from "../../catstypicalframework/utils/ui";
import { AppStorageV2 } from "@kit.ArkUI";
import { MooSymbolButton } from "../common/MooSymbolButton";
import { defaultAnimation } from "../common/constants";
import { meowUiStatuses } from "../../hosts/ui/meowUiStatuses";

@ComponentV2
struct MeowTitleBar {
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local meowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  build() {
    Row({ space: 1 }) {
      MooSymbolButton({ icon: $r('sys.symbol.arrow_left') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_right') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_clockwise') });
      MooSymbolButton({ icon: $r('sys.symbol.house') });

      Text('MeowTitleBar')
        .textAlign(TextAlign.Center)
        .layoutWeight(1);

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
      MooSymbolButton({ icon: $r('sys.symbol.gearshape') });
    }
    .height(heightMeowTitleBar)
    .animation(defaultAnimation())
    .width('100%')
    .padding({ left: this.myMeowAvoid.left, right: this.myMeowAvoid.right });
  }
}

export { MeowTitleBar };

export const heightMeowTitleBar = 32;
