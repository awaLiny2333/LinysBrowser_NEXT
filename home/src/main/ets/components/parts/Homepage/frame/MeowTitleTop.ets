import lazy { common } from '@kit.AbilityKit';
import { windowTopAvoidLeft, windowTopAvoidRight } from '../../../../catstypicalframework/utils/ui';
import lazy { openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialogOnMostRecent } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowAppHost } from '../../../../hosts/system/windows/classes/meowAppHost';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';
import lazy { newWindow } from '../../../../hosts/system/windows/scripts/multiwindows';
import { MooSymbolButtonSmall } from '../../../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { showWindowTitle, windowTitleOnAddressBar, windowTitlePosition } from '../../../settings';

/**
 * The window top bar. Holds the buttons on window top, as well as the name of window / zone.
 *
 * Note that if the window is not in free window mode, the extra buttons won't be displayed.
 */
@Builder
export function MeowTitleTop(myUi: meowUiHost, myApp: meowAppHost, context: UIContext) {
  Row({ space: 10 }) {
    // left button(s)
    if (myApp.freeWindow) {
      if (myUi.isZone) {
        MooSymbolButtonSmall($r('sys.symbol.briefcase'), () => {
          requestDialogOnMostRecent(openDialogRequestType.ZONES);
        }, HitTestMode.BLOCK_HIERARCHY);
      } else {
        MooSymbolButtonSmall($r('sys.symbol.square_stack_3d'), () => {
          requestDialogOnMostRecent(openDialogRequestType.ZONES);
        }, HitTestMode.BLOCK_HIERARCHY);
      }
    }

    // Window Title Text
    Text(showWindowTitle(myUi) && !windowTitleOnAddressBar() ? `${myUi.myTabs.currentTab?.title || 'Meow'}｜${myUi.windowAlias}` : '')
      .attributeModifier(new MooTextModifier())
      .textAlign(windowTitlePosition())
      .layoutWeight(1)
      .opacity(0.75)
      .margin({ top: 4, left: 10, right: 10 })
      .maxLines(1)
      .wordBreak(WordBreak.BREAK_ALL)
      .textOverflow({ overflow: TextOverflow.Ellipsis });

    // right button(s)
    if (myApp.freeWindow) {
      if (myUi.pin) {
        MooSymbolButtonSmall($r('sys.symbol.pin_vertical_fill'), () => {
          myUi.togglePin();
        }, HitTestMode.BLOCK_HIERARCHY);
      } else {
        MooSymbolButtonSmall($r('sys.symbol.pin'), () => {
          myUi.togglePin();
        }, HitTestMode.BLOCK_HIERARCHY);
      }
      MooSymbolButtonSmall($r('sys.symbol.plus'), () => {
        newWindow(context.getHostContext() as common.UIAbilityContext);
      }, HitTestMode.BLOCK_HIERARCHY);
    }
  } // Title bar
  .hitTestBehavior(HitTestMode.None)
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Top)
  .width('100%')
  .padding(myApp.freeWindow ? { right: windowTopAvoidRight, left: windowTopAvoidLeft, top: 11.5 } : { top: 11.5 });
}
