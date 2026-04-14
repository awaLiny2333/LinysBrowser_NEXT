import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowFreeWindowModeStatus } from '../../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowLayoutModeStatus } from '../../catstypicalframework/hosts/meowLayoutModeStatus';
import { windowTopAvoidLeft, windowTopAvoidRight } from '../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../hosts/env/classes/meowDialogManager';
import { requestDialog } from '../../hosts/env/scripts/dialog';
import { showWindowTitle, windowTitlePosition } from '../settings';
import { MooSymbolButtonSmall } from '../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../common/MooTextModifier';

/**
 * The window top bar. Holds the buttons on window top, as well as the name of window / zone.
 *
 * Note that if the window is not in free window mode, the extra buttons won't be displayed.
 */
@ComponentV2
struct MeowTitleTop {
  @Param @Require myMeowFreeWindowModeStatus: meowFreeWindowModeStatus;
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowLayout: meowLayoutModeStatus;
  @Param @Require myMeowDialogManager: meowDialogManager;

  build() {
    Row({ space: 10 }) {
      // left button(s)
      if (this.myMeowFreeWindowModeStatus.on) {
        MooSymbolButtonSmall({
          icon: $r('sys.symbol.square_stack_3d'),
          clickAction: () => {
            // TODO: Open zones panel.
          }
        });
      }

      // Window Title Text
      Text(showWindowTitle(this.myMeowLayout) ? $r('app.string.EntryAbility_label') : '')
        .attributeModifier(new MooTextModifier())
        .textAlign(windowTitlePosition())
        .layoutWeight(1)
        .opacity(0.75)
        .margin({ top: 4, left: 10, right: 10 })
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick(() => {
          // Open
          requestDialog(this.myMeowDialogManager, openDialogRequestType.DEV);
        });

      // right button(s)
      if (this.myMeowFreeWindowModeStatus.on) {
        MooSymbolButtonSmall({
          icon: $r('sys.symbol.pin'),
          clickAction: () => {
            // TODO: Pin window.
          }
        });
        MooSymbolButtonSmall({
          icon: $r('sys.symbol.plus'),
          clickAction: () => {
            // TODO: Open new window.
          }
        });
      }
    } // Title bar
    .alignItems(VerticalAlign.Top)
    .height(this.myMeowAvoid.top)
    .width('100%')
    .padding(this.myMeowFreeWindowModeStatus.on ? { right: windowTopAvoidRight, left: windowTopAvoidLeft, top: 6 } : { top: 6 });
  }
}

export { MeowTitleTop };
