import { defaultItemRadius } from '../../../../catstypicalframework/utils/ui';
import { standardSpacing, mooTextType, meowThemeColorType, typicalTextHeightNormal } from '../../../constants';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { defaultAnimation, getColor, useEffects } from '../../../settings';

@ComponentV2
struct MonthButton {
  @Param year: number = -1;
  @Param month: number = -1;
  @Param desc: ResourceStr | undefined = undefined;
  @Param isSelected: boolean = false;
  // Events
  @Event clickAction: () => void;

  build() {
    Column() {
      if (this.year > 0) {
        Text(this.year.toString()).attributeModifier(new MooTextModifier()).opacity(0.75);
        Text(this.month.toString()).attributeModifier(new MooTextModifier());
      } else if (this.desc) {
        Text(this.desc).attributeModifier(new MooTextModifier(mooTextType.TITLE));
      }
    }
    .border(this.isSelected
      ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultItemRadius }
      : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultItemRadius })
    .padding(standardSpacing)
    .animation(defaultAnimation())
    .alignItems(this.desc ? HorizontalAlign.Center : HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .aspectRatio(this.desc ? 1 : undefined)
    .hoverEffect(HoverEffect.Highlight)
    .height(defaultMonthButtonHeight - 2)
    .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
    .onClick(() => {
      this.clickAction();
    });
  }
}

export { MonthButton };

export const defaultMonthButtonHeight = 2 * typicalTextHeightNormal + 2 * standardSpacing;
