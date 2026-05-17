import { common } from '@kit.AbilityKit';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../../../catstypicalframework/hosts/meowMisc';
import { windowTopAvoidLeft, windowTopAvoidRight } from '../../../catstypicalframework/utils/ui';
import { meowAppHost } from '../../../hosts/system/windows/classes/meowAppHost';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { newWindow } from '../../../hosts/system/windows/scripts/multiwindows';
import { MooSymbolButtonSmall } from '../../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../../common/MooTextModifier';
import { showWindowTitle, windowTitlePosition } from '../../settings';

/**
 * The window top bar. Holds the buttons on window top, as well as the name of window / zone.
 *
 * Note that if the window is not in free window mode, the extra buttons won't be displayed.
 */
@Builder
export function MeowTitleTop(
  myLayout: meowLayout,
  myUi: meowUiHost,
  myApp: meowAppHost,
  myMisc: meowMisc,
  // onDrop: (event: DragEvent) => void,
  // onDragEnter: (event: DragEvent) => void,
  // onDragLeave: (event: DragEvent) => void,
  context: UIContext
) {
  Row({ space: 10 }) {
    // left button(s)
    if (myApp.freeWindow) {
      MooSymbolButtonSmall($r('sys.symbol.square_stack_3d'), () => {
        // TODO: Open zones panel.
      });
    }

    // Window Title Text
    Text(showWindowTitle(myLayout) ? `${myUi.windowAlias} (${myUi.windowId}) (${myMisc.launchEndTime - myMisc.launchStartTime} ms)` : '')
      .attributeModifier(new MooTextModifier())
      .textAlign(windowTitlePosition())
      .layoutWeight(1)
      .opacity(0.75)
      .margin({ top: 4, left: 10, right: 10 })
      .maxLines(1)
      .wordBreak(WordBreak.BREAK_ALL)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

    // right button(s)
    if (myApp.freeWindow) {
      if (myUi.pin) {
        MooSymbolButtonSmall($r('sys.symbol.pin_vertical_fill'), () => {
          myUi.togglePin();
        });
      } else {
        MooSymbolButtonSmall($r('sys.symbol.pin'), () => {
          myUi.togglePin();
        });
      }
      MooSymbolButtonSmall($r('sys.symbol.plus'), () => {
        newWindow(context.getHostContext() as common.UIAbilityContext);
      });
    }
  } // Title bar
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Top)
  .width('100%')
  .padding(myApp.freeWindow ? { right: windowTopAvoidRight, left: windowTopAvoidLeft, top: 6 } : { top: 6 });
}
