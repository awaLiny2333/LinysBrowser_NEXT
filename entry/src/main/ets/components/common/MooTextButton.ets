import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { standardSpacing } from '../settings';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooTextButton {
  @Param @Require text: ResourceStr;
  @Param radius: number = defaultItemRadius;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
      .attributeModifier(new MooTextModifier())
      .padding(standardSpacing * 0.75)
      .borderRadius(this.radius)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      });
  }
}

export { MooTextButton };
