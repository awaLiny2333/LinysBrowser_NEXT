import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { defaultAnimation, getColor, meowThemeColorType, summarizedPreferRightHand, useEffects } from "./constants";

@ComponentV2
struct MooCapsuleButton {
  @Param @Once doubleConfirm: boolean = false;
  @Local lastChance: boolean = false;
  @Param text: ResourceStr = 'Meow ~';
  @Event clickAction: () => void;

  build() {
    Button(this.text)
      .alignSelf(summarizedPreferRightHand() ? ItemAlign.End : ItemAlign.Start)
      .border({
        width: this.lastChance ? 2 : (useEffects() ? 1 : 0),
        color: this.lastChance ? this.adjustedColorFont() : $r('sys.color.icon_fourth'),
        radius: defaultInnerRadius
      })
      .brightness(this.lastChance ? 1.1 : 1)
      .animation(defaultAnimation())
      .backgroundColor(this.adjustedColorBackground())
      .fontColor(this.adjustedColorFont())
      .onClick(() => {
        if (this.doubleConfirm) {
          if (this.lastChance) {
            this.clickAction();
          }
          this.lastChance = true;
          setTimeout(() => {
            this.lastChance = false;
          }, 2000);
        } else {
          this.clickAction();
        }
      })
      .opacity(0.9);
  }

  adjustedColorFont() {
    if (useEffects()) {
      return getColor(meowThemeColorType.FONT);
    }
    return getColor(this.lastChance ? meowThemeColorType.FONT : meowThemeColorType.PRIMARY);
  }

  adjustedColorBackground() {
    if (useEffects()) {
      return getColor(meowThemeColorType.PRIMARY);
    }
    return getColor(this.lastChance ? meowThemeColorType.PRIMARY : meowThemeColorType.FONT);
  }
}

export { MooCapsuleButton };
