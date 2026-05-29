import { defaultMenuItemRadius } from "../../catstypicalframework/utils/ui";
import { standardSpacing } from "../constants";
import { MooTextModifier } from "./MooTextModifier";

@ComponentV2
struct mooMenuButton {
  @Param @Require text: ResourceStr;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
      .attributeModifier(new MooTextModifier())
      .onClick(() => {
        if (this.clickAction) {
          this.clickAction();
        }
      })
      .padding(standardSpacing)
      .hoverEffect(HoverEffect.Highlight)
      .borderRadius(defaultMenuItemRadius);
  }
}

export default mooMenuButton;
