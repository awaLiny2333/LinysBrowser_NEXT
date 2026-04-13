import { defaultAnimation, getColor, meowThemeColorType, summarizedPreferRightHand, useEffects } from "./constants";
import { MooSymbolButtonSmall } from "./MooSymbolButtonSmall";
import { MooTextModifier } from "./MooTextModifier";

@ComponentV2
struct MooSlider {
  @Param @Once lock: boolean = true;
  // Data
  @Param @Require value: number;
  @Param @Require min: number;
  @Param @Require max: number;
  @Param @Require step: number;
  @Event onChange: (value: number) => void;
  // UI
  @Local locked: boolean = this.lock; // Prevent the slider from being accidentally slided.

  build() {
    Row() {
      if (this.lock) {
        MooSymbolButtonSmall({
          icon: this.locked ? $r('sys.symbol.lock') : $r('sys.symbol.lock_open'),
          clickAction: () => {
            // Unlock the slider.
            this.locked = !this.locked;
          }
        });
      }
      Slider({
        value: this.value,
        min: this.min,
        max: this.max,
        step: this.step,
        style: SliderStyle.InSet
      })
        .opacity(this.locked ? 0.5 : 0.9)
        .animation(defaultAnimation())
        .trackColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY))
        .selectedColor(useEffects() ? $r('app.color.effects_emphasize') : getColor(meowThemeColorType.FONT))
        .blockColor(useEffects() ? getColor(meowThemeColorType.FONT) : getColor(meowThemeColorType.PRIMARY))
        .layoutWeight(1)
        .enabled(!this.locked)
        .onChange((value: number) => {
          this.onChange(value);
        });
      Text(` ${this.value} `).attributeModifier(new MooTextModifier()).opacity(this.locked ? 0.5 : 1).animation(defaultAnimation());
    }
    .direction(summarizedPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .animation(defaultAnimation());
  }
}

export { MooSlider };
