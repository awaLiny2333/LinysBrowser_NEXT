import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { standardSpacing } from '../constants';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooTextButton {
  @Param @Require text: ResourceStr;
  @Param radius: number = defaultItemRadius;
  @Param maxLines: number = 1;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
      .attributeModifier(new MooTextModifier())
      .padding(standardSpacing * 0.75)
      .borderRadius(this.radius)
      .maxLines(this.maxLines)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      });
  }
}

export { MooTextButton };
