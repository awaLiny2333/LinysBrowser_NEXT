import { common } from '@kit.AbilityKit';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { windowTopAvoidLeft, windowTopAvoidRight } from '../../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { newWindow } from '../../../hosts/system/windows/scripts/multiwindows';
import { MooSymbolButtonSmall } from '../../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../../common/MooTextModifier';
import { showWindowTitle, windowTitlePosition } from '../../settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowAppStatuses } from '../../../hosts/system/windows/classes/meowAppStatuses';

const myApp = AppStorageV2.connect(meowAppStatuses)!;

/**
 * The window top bar. Holds the buttons on window top, as well as the name of window / zone.
 *
 * Note that if the window is not in free window mode, the extra buttons won't be displayed.
 */
@Builder
export function MeowTitleTop(
  myLayout: meowLayout,
  myDialog: meowDialogManager,
  myUi: meowUiStatuses,
  context: UIContext
) {
  Row({ space: 10 }) {
    // left button(s)
    if (myApp.freeWindow) {
      MooSymbolButtonSmall({
        icon: $r('sys.symbol.square_stack_3d'),
        clickAction: () => {
          // TODO: Open zones panel.
        }
      });
    }

    // Window Title Text
    Text(showWindowTitle(myLayout) ? `${myUi.windowAlias} (${myUi.windowId})` : '')
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
        requestDialog(myDialog, openDialogRequestType.DEV);
      });

    // right button(s)
    if (myApp.freeWindow) {
      MooSymbolButtonSmall({
        icon: myUi.pin ? $r('sys.symbol.pin_vertical_fill') : $r('sys.symbol.pin'),
        clickAction: () => {
          myUi.togglePin();
          // TODO: Pin window.
        }
      });
      MooSymbolButtonSmall({
        icon: $r('sys.symbol.plus'),
        clickAction: () => {
          newWindow(context.getHostContext() as common.UIAbilityContext);
        }
      });
    }
  } // Title bar
  .alignItems(VerticalAlign.Top)
  .width('100%')
  .padding(myApp.freeWindow
    ? { right: windowTopAvoidRight, left: windowTopAvoidLeft, top: 6 }
    : { top: 6 }
  );
}
