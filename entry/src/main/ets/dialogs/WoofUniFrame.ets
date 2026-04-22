import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { defaultInnerRadius } from '../catstypicalframework/utils/ui';
import { MooSymbolButton } from '../components/common/MooSymbolButton';
import { MooTextModifier } from '../components/common/MooTextModifier';
import { UniContentCard } from '../components/common/UniContentCard';
import { defaultAnimation, getColor, meowThemeColorType, mooTextType, standardSpacing, useEffects } from '../components/settings';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';

@ComponentV2
struct WoofUniFrame {
  // Config
  @Param @Once shiftBackgroundColor: boolean = false;
  @Param @Once tutorial: ResourceStr | undefined = undefined;
  // Env
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // This
  @Param @Require controller: CustomDialogController;
  @Param title: ResourceStr = 'Title';
  @BuilderParam contentsBuilder: () => void;
  // UI
  @Local showTutorial: boolean = false;

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
        // Tutorial. TODO: This nesting is ugly.
        if (this.showTutorial && !this.myLayout.shortMode) {
          Column() {
            UniContentCard({ roundedRadius: defaultInnerRadius }) {
              Text(this.tutorial).attributeModifier(new MooTextModifier()).width('100%');
            };
          }.padding({ left: standardSpacing, right: standardSpacing, top: standardSpacing });
        }

        this.contentsBuilder();
      }
      .padding({ top: this.myLayout.shortMode ? 0 : 43 })
      .animation(defaultAnimation());

      // Title bar
      if (!this.myLayout.shortMode) {
        Row({ space: standardSpacing * 0.125 }) {
          Text(this.title)
            .attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .maxLines(1)
            .wordBreak(WordBreak.BREAK_ALL)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1);
          if (this.tutorial) {
            MooSymbolButton({
              icon: $r('sys.symbol.questionmark_circle'),
              onHold: this.showTutorial,
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.showTutorial = !this.showTutorial;
                });
              }
            });
          }
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
        .backgroundColor(getColor(this.shiftBackgroundColor && !useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY))
        .useEffect(useEffects(), EffectType.WINDOW_EFFECT);
      }
    }
    .width('auto')
    .alignContent(Alignment.Top)
    .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
    .backgroundColor(getColor(this.shiftBackgroundColor && !useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY));
  }
}

export { WoofUniFrame };
