import { defaultRoundedRadius } from "../../catstypicalframework/utils/ui";
import { AppStorageV2 } from "@kit.ArkUI";
import { MooSymbolButton } from "../common/MooSymbolButton";
import { meowUiStatuses } from "../../hosts/env/classes/meowUiStatuses";
import { WoofSettingsDialog } from "../dialogs/WoofSettings/WoofSettings";
import { meowAvoid } from "../../catstypicalframework/hosts/meowAvoid";

@ComponentV2
struct MeowTitleBar {
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local meowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  catsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSettingsDialog(),
    alignment: DialogAlignment.Center,
    width: '95%',
    height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });

  build() {
    Row({ space: 1 }) {
      MooSymbolButton({ icon: $r('sys.symbol.arrow_left') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_right') });
      MooSymbolButton({ icon: $r('sys.symbol.arrow_clockwise') });
      MooSymbolButton({ icon: $r('sys.symbol.house') });

      Text('MeowTitleBar')
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

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
        icon: $r('sys.symbol.gearshape'), clickAction: () => {
          this.catsDevDialogController.open();
        }
      });
    }
    .height(heightMeowTitleBar)
    .width('100%')
    .padding({ left: this.myMeowAvoid.left, right: this.myMeowAvoid.right });
  }
}

export { MeowTitleBar };

export const heightMeowTitleBar = 32;
