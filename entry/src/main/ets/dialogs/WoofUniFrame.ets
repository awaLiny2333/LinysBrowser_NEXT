import { MooSymbolButton } from '../components/common/MooSymbolButton';
import { MooTextModifier } from '../components/common/MooTextModifier';
import { defaultAnimation, getColor, meowThemeColorType, mooTextType, useEffects } from '../components/settings';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';

@ComponentV2
struct WoofUniFrame {
  // Env
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // This
  @Param @Require controller: CustomDialogController;
  @Param title: ResourceStr = 'Title';
  @BuilderParam contentsBuilder: () => void;
  // Info
  @Local dialogHeight: number = -1;

  aboutToAppear(): void {
    if (this.controller) {
      this.myDialog.registerOpenDialog(this.controller, this.title);
    }
  }

  aboutToDisappear(): void {
    if (this.controller) {
      this.myDialog.registerCloseDialog(this.controller, this.title);
    }
  }

  build() {
    Stack() {
      Column() {
        this.contentsBuilder();
      }
      .padding({ top: this.myLayout.shortMode ? 0 : 43 })
      .animation(defaultAnimation());

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
        })
      }
      .visibility(this.myLayout.shortMode ? Visibility.None : Visibility.Visible) // Save space for short contents
      .animation(defaultAnimation())
      .padding({ left: 12, right: 10, top: 10, bottom: 7 })
      .backgroundColor(getColor(meowThemeColorType.SECONDARY))
      .useEffect(useEffects(), EffectType.WINDOW_EFFECT);

    }
    .width('auto')
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
