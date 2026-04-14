import { defaultAnimation, getColor, meowThemeColorType, summarizedPreferRightHand, useEffects } from './constants';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooSwitch {
  @Param text: ResourceStr = '';
  @Param isOn: boolean = false;
  // Events
  @Event onChange: (value: boolean) => void;

  build() {
    Row({ space: 8 }) {
      if (this.text) {
        Text(this.text).attributeModifier(new MooTextModifier())
          .layoutWeight(1)
          .textAlign(summarizedPreferRightHand() ? TextAlign.End : TextAlign.Start)
          // .animation(defaultAnimation());
      }
      Toggle({ isOn: this.isOn, type: ToggleType.Switch })
        .onChange((c) => {
          this.onChange(c);
        })
        .switchStyle({
          unselectedColor: useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY)
        })
        .selectedColor(useEffects() ? $r('app.color.effects_emphasize') : getColor(meowThemeColorType.FONT))
        .switchPointColor(useEffects() ? getColor(meowThemeColorType.FONT) : getColor(meowThemeColorType.PRIMARY))
        .opacity(0.9);
    }
    .width('100%')
    .direction(summarizedPreferRightHand() ? Direction.Ltr : Direction.Rtl)
    .animation(defaultAnimation());
  }
}

export { MooSwitch };
