import { getColor, meowThemeColorType, useEffects } from './constants';
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
        Text(this.text)
          .attributeModifier(new MooTextModifier())
          .textAlign(TextAlign.End)
          .layoutWeight(1);
      }
      Toggle({ isOn: this.isOn, type: ToggleType.Switch })
        .onChange((c) => {
          this.onChange(c);
        })
        .switchStyle({
          unselectedColor: useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY)
        })
        .selectedColor(useEffects() ? $r('app.color.effects_emphasize') : getColor(meowThemeColorType.FONT))
        .switchPointColor(useEffects() ? getColor(meowThemeColorType.FONT) : getColor(meowThemeColorType.PRIMARY));
    };
  }
}

export { MooSwitch };
