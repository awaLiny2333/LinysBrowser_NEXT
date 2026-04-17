import { defaultMenuItemRadius, defaultRoundedRadius, defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { MooCapsuleButton } from '../../../components/common/MooCapsuleButton';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { standardSpacing, getColor, meowThemeColorType } from '../../../components/settings';

@ComponentV2
struct DemoPanel {
  @Param @Require hex: string;

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        Row() {
          Text('ヽ（´ー｀）┌').attributeModifier(new MooTextModifier());
        }
        .padding(2 * standardSpacing)
        .backgroundColor(getColor(meowThemeColorType.SECONDARY))
        .borderRadius(defaultMenuItemRadius);

        // Color block
        Row() {
        }
        .padding(standardSpacing)
        .alignItems(VerticalAlign.Bottom)
        .height(120)
        .border({
          width: 2,
          color: getColor(meowThemeColorType.FONT),
          radius: defaultRoundedRadius
        })
        .width('60%')
        .backgroundColor(this.hex);

        MooCapsuleButton({
          text: '／(=∵=)＼'
        });
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%');
    }
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .padding(standardSpacing)
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .borderRadius(defaultInnerRadius);
  }
}

export { DemoPanel };
