import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
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
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;

  build() {
    Row({ space: 10 }) {
      // left button(s)
      if (this.myLayout.freeWindow) {
        MooSymbolButtonSmall({
          icon: $r('sys.symbol.square_stack_3d'),
          clickAction: () => {
            // TODO: Open zones panel.
          }
        });
      }

      // Window Title Text
      Text(showWindowTitle(this.myLayout) ? $r('app.string.EntryAbility_label') : '')
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
          requestDialog(this.myDialog, openDialogRequestType.DEV);
        });

      // right button(s)
      if (this.myLayout.freeWindow) {
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
    .height(this.myAvoid.top)
    .width('100%')
    .padding(this.myLayout.freeWindow ? { right: windowTopAvoidRight, left: windowTopAvoidLeft, top: 6 } : { top: 6 });
  }
}

export { MeowTitleTop };
