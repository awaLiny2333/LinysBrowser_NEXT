import { common } from '@kit.AbilityKit';
import { meowAvoid } from '../../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { windowTopAvoidLeft, windowTopAvoidRight } from '../../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { newWindow } from '../../../hosts/system/windows/scripts/multiwindows';
import { MooSymbolButtonSmall } from '../../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../../common/MooTextModifier';
import { showWindowTitle, windowTitlePosition } from '../../settings';


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
  @Param @Require myUi: meowUiStatuses;

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
      Text(showWindowTitle(this.myLayout) ? `${this.myUi.windowAlias} (${this.myUi.windowId})` : '')
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
          icon: this.myUi.pin ? $r('sys.symbol.pin_vertical_fill') : $r('sys.symbol.pin'),
          clickAction: () => {
            this.myUi.togglePin();
            // TODO: Pin window.
          }
        });
        MooSymbolButtonSmall({
          icon: $r('sys.symbol.plus'),
          clickAction: () => {
            newWindow(this.getUIContext().getHostContext() as common.UIAbilityContext);
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
