import { defaultItemRadius } from '../../../../catstypicalframework/utils/ui';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, useEffects } from '../../../../components/settings';

@ComponentV2
struct MonthButton {
  @Param @Require year: number;
  @Param @Require month: number;
  @Param isSelected: boolean = false;
  // Events
  @Event clickAction: () => void;

  build() {
    Column() {
      Text(this.year.toString()).attributeModifier(new MooTextModifier());
      Text(this.month.toString()).attributeModifier(new MooTextModifier());
    }
    .border(this.isSelected
      ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultItemRadius }
      : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultItemRadius })
    .padding(standardSpacing)
    .animation(defaultAnimation())
    .alignItems(HorizontalAlign.Start)
    .hoverEffect(HoverEffect.Highlight)
    .height(defaultMonthButtonHeight - 2)
    .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
    .onClick(() => {
      this.clickAction();
    });
  }
}

export { MonthButton };

export const defaultMonthButtonHeight = 2 * 20 + 2 * standardSpacing;
