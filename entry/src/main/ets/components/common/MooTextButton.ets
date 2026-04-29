import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { standardSpacing } from '../settings';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooTextButton {
  @Param @Require text: ResourceStr;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
      .attributeModifier(new MooTextModifier())
      .padding(standardSpacing * 0.75)
      .borderRadius(defaultItemRadius)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      });
  }
}

export { MooTextButton };
