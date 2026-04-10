import { meowDialogManager } from '../../../../hosts/env/meowDialogManager';
import { MooSymbolButton } from '../../../common/MooSymbolButton';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { getColor, meowThemeColorType, mooTextType, useEffects } from '../../../common/constants';

@ComponentV2
struct WoofUniFrame {
  // Env
  @Local myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager)!;
  // This
  @Param @Require controller: CustomDialogController;
  @Param title: ResourceStr = 'Title';
  @BuilderParam contentsBuilder: () => void;
  // Info
  @Local dialogHeight: number = -1;

  aboutToAppear(): void {
    if (this.controller) {
      this.myMeowDialogManager.openDialog(this.controller, this.title);
    }
  }

  aboutToDisappear(): void {
    if (this.controller) {
      this.myMeowDialogManager.closeDialog(this.controller, this.title);
    }
  }

  build() {
    Stack() {
      this.contentsBuilder();

      // Title bar
      Row() {
        Text(this.title)
          .attributeModifier(new MooTextModifier(mooTextType.TITLE))
          .layoutWeight(1);
        MooSymbolButton({
          icon: $r('sys.symbol.xmark'),
          clickAction: () => {
            if (this.controller) {
              this.controller.close();
            }
          }
        });
      }
      .padding({ left: 12, right: 10, top: 10, bottom: 7 })
      .backgroundColor(getColor(meowThemeColorType.SECONDARY))
      .useEffect(useEffects(), EffectType.WINDOW_EFFECT);
    }
    .onAreaChange((oldValue, newValue) => {
      if (oldValue.height as number == newValue.height as number) {
        return;
      }
      this.dialogHeight = newValue.height as number;
    })
    .alignContent(Alignment.Top)
    .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
    .backgroundColor(getColor(meowThemeColorType.SECONDARY));
  }
}

export { WoofUniFrame };
