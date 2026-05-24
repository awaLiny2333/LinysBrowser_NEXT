import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { mooTextType, standardSpacing } from '../constants';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooTextButton {
  @Param @Require text: ResourceStr;
  @Param radius: number = defaultItemRadius;
  @Param opacityMe: number = 1;
  @Param style: mooTextType = mooTextType.NORMAL;
  @Param maxLines: number = 1;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
      .attributeModifier(new MooTextModifier(this.style))
      .padding(standardSpacing * 0.75)
      .borderRadius(this.radius)
      .maxLines(this.maxLines)
      .opacity(this.opacityMe)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      });
  }
}

export { MooTextButton };
