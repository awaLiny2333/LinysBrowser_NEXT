import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { resource2String } from '../catstypicalframework/utils/resource';
import { defaultInnerRadius } from '../catstypicalframework/utils/ui';
import { MooCapsuleButton } from '../components/common/MooCapsuleButton';
import { MooSymbolButton } from '../components/common/MooSymbolButton';
import { MooTextModifier } from '../components/common/MooTextModifier';
import { UniContentCard } from '../components/common/UniContentCard';
import { meowThemeColorType, mooTextType, standardComponentHeight, standardSpacing } from '../components/constants';
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from '../components/settings';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';

@ComponentV2
struct WoofUniFrame {
  // Config
  @Param @Once shiftBackgroundColor: boolean = false;
  @Param @Once tutorial: ResourceStr | undefined = undefined;
  @Param @Once showConfirmButton: boolean = false;
  @Param @Once showCancelButton: boolean = false;
  @Param @Once doubleConfirm: boolean = false;
  // Env
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // This
  @Param @Require controller: CustomDialogController;
  @Param title: ResourceStr = 'Title';
  @BuilderParam contentsBuilder: () => void;
  // UI
  @Param @Once showTutorial: boolean = false;
  @Local tutorialHeight: number = 0;
  @Local frameHeight: number = 0;
  // Events
  @Event onConfirm: () => void;
  @Event onCancel: () => void;
  @Event aboutToClose: () => void;

  aboutToAppear(): void {
    if (this.controller) {
      if (typeof this.title == 'string') {
        this.myDialog.registerOpenDialog(this.controller, this.title);
      } else {
        this.myDialog.registerOpenDialog(this.controller, resource2String(this.title, this.getUIContext().getHostContext()!));
      }
    }
  }

  aboutToDisappear(): void {
    this.aboutToClose();
    if (this.controller) {
      if (typeof this.title == 'string') {
        this.myDialog.registerCloseDialog(this.controller, this.title);
      } else {
        this.myDialog.registerCloseDialog(this.controller, resource2String(this.title, this.getUIContext().getHostContext()!));
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (!this.myLayout.shortMode) {
        Column() {
          // Title bar
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
          // Tutorial. This nesting is ugly :O but we have no other simpler ways to put paddings here.
          if (this.showTutorial) {
            Column() {
              UniContentCard({ roundedRadius: defaultInnerRadius, shiftBackgroundColor: this.shiftBackgroundColor }) {
                Text(this.tutorial).attributeModifier(new MooTextModifier()).width('100%');
              };
            }
            .padding({ left: standardSpacing, right: standardSpacing })
            .onAreaChange((oldValue, newValue) => {
              if (oldValue.height != newValue.height) {
                animateToImmediately(defaultAnimation(), () => {
                  this.tutorialHeight = newValue.height as number;
                });
              }
            });
          }
        };
      }

      // Contents
      Column() {
        this.contentsBuilder();
      }
      .margin({ top: this.myLayout.shortMode ? 0 : (41 + (this.showTutorial ? this.tutorialHeight + standardSpacing : 0)), bottom: this.showConfirmButton ? standardComponentHeight + standardSpacing + 1 : 0 });

      // Confirm / Deny buttons
      if (this.showConfirmButton) {
        Row({ space: standardSpacing }) {
          if (this.showCancelButton) {
            MooCapsuleButton({
              text: $r('app.string.General_cancel'),
              needDoubleConfirm: this.doubleConfirm,
              clickAction: () => {
                this.onCancel();
              }
            });
          }
          MooCapsuleButton({
            text: $r('app.string.General_confirm'),
            needDoubleConfirm: this.doubleConfirm,
            clickAction: () => {
              this.onConfirm();
            }
          });
        }
        .translate({ y: this.frameHeight - standardComponentHeight - standardSpacing * 2 })
        .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
        .width('100%')
        .backgroundColor(getColor(this.shiftBackgroundColor && !useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY))
        .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
        .padding(standardSpacing);
      }
    }
    .width('auto')
    .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
    .backgroundColor(getColor(this.shiftBackgroundColor && !useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY))
    .onAreaChange((oldValue, newValue) => {
      if (oldValue.height != newValue.height) {
        this.frameHeight = newValue.height as number;
      }
    });
  }
}

export { WoofUniFrame };
