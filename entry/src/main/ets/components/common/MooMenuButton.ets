import { defaultMenuItemRadius } from "../../catstypicalframework/utils/ui";
import { standardSpacing } from "../settings";

@ComponentV2
struct mooMenuButton {
  @Param @Require text: ResourceStr;
  @Event clickAction: () => void;

  build() {
    Text(this.text)
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