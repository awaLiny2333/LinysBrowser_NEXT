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
      Blank().layoutWeight(1)
      if (this.text) {
        Text(this.text).attributeModifier(new MooTextModifier());
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
    .direction(summarizedPreferRightHand() ? Direction.Ltr : Direction.Rtl)
    .animation(defaultAnimation());
  }
}

export { MooSwitch };
