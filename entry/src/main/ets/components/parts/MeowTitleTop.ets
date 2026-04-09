import { meowFreeWindowModeStatus, meowAvoid, windowTopAvoidRight, meowLayoutModeStatus, windowTopAvoidLeft, defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { AppStorageV2 } from '@kit.ArkUI';
import { CatsDevDialog } from '../dialogs/CatsDev/CatsDevCards';
import { MooSymbolButtonSmall } from '../common/MooSymbolButtonSmall';
import { MooTextModifier } from '../common/MooTextModifier';
import { meowDialogManager } from '../../hosts/env/meowDialogManager';

/**
 * The window top bar. Holds the buttons on window top, as well as the name of window / zone.
 *
 * Note that if the window is not in free window mode, the extra buttons won't be displayed.
 */
@ComponentV2
struct MeowTitleTop {
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect(meowFreeWindowModeStatus)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect(meowAvoid)!;
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus)!;
  @Local myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager)!;

  catsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: CatsDevDialog(),
    alignment: DialogAlignment.Center,
    width: '90%',
    // height: '90%',
    cornerRadius: defaultRoundedRadius + 4,
  });

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
      Text(this.myMeowFreeWindowModeStatus.on || this.myMeowLayout.wideMode ? $r('app.string.EntryAbility_label') : '')
        .attributeModifier(new MooTextModifier())
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .opacity(0.75)
        .margin({ top: 4 })
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick(() => {
          // Open
          if (this.myMeowDialogManager.isEmpty()) {
            this.catsDevDialogController.open();
          }
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

  /**
   * Builder of CatsDevDialog.
   */
  @Builder
  CatsDevDialogBuilder(): void {
    CatsDevDialog();
  }
}

export { MeowTitleTop };
