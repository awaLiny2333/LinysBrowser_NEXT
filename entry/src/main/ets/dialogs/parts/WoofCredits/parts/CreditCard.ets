import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import { defaultInnerRadius, defaultRoundedRadius, measureTextWidth } from '../../../../catstypicalframework/utils/ui';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { fontSizeSmall, getColor, meowThemeColorType, minimumCardWidth, mooTextType, standardSpacing, useEffects } from '../../../../components/settings';
import { Contribution } from '../creditDetails';

@ReusableV2
@ComponentV2
struct CreditCard {
  @Param @Require item: Contribution;
  @Param @Require myLayout: meowLayout;
  maxLines = 3;

  build() {
    Column({ space: standardSpacing }) {
      Text(`#${this.item.id}`).attributeModifier(new MooTextModifier(mooTextType.TITLE)).opacity(0.9);
      Text(this.item.desc).attributeModifier(new MooTextModifier()).layoutWeight(this.myLayout.wideMode ? 1 : undefined);

      // Tags
      Row({ space: standardSpacing }) {
        Repeat(this.item.tags).each((tag) => {
          Text(tag.item).attributeModifier(new MooTextModifier())
            .padding(standardSpacing * 0.75)
            .backgroundColor(getColor(meowThemeColorType.PRIMARY))
            .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') });
        });
      };
    }
    .width(this.cardWidth())
    .height(this.cardHeight())
    .alignItems(HorizontalAlign.Start)
    .padding(standardSpacing)
    .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
    .border({ radius: defaultRoundedRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') });
  }

  @Computed
  get widthMultiplier(): number {
    const textWidth = measureTextWidth(this.item.desc, this.getUIContext(), fontSizeSmall, FontWeight.Normal) / this.maxLines;
    return Math.max(1, Math.ceil(textWidth / (minimumCardWidth / 2)));
  }

  cardWidth() {
    if (this.myLayout.wideMode) {
      return minimumCardWidth / 2 * this.widthMultiplier + standardSpacing * (this.widthMultiplier - 1);
    } else {
      return '100%';
    }
  }

  cardHeight() {
    if (this.myLayout.wideMode) {
      return minimumCardWidth * 0.3;
    } else {
      return undefined;
    }
  }
}

export { CreditCard };
