import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { meowThemeColorType, standardComponentHeight } from "../constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../settings";

@ComponentV2
struct MooCapsuleButton {
  // Config
  @Param @Once needDoubleConfirm: boolean = false;
  @Param text: ResourceStr = 'Meow ~';
  @Param isEnabled: boolean = true;
  // Local
  @Local lastChance: boolean = false;
  lastChanceTimeout: number | undefined;
  // Event
  @Event clickAction: () => void;

  build() {
    Button(this.lastChance ? $r('app.string.General_confirm') : this.text)
      .fontColor(this.adjustedColorFont())
      .height(standardComponentHeight)
      .alignSelf(isPreferRightHand() ? ItemAlign.End : ItemAlign.Start)
      .border({
        width: this.lastChance ? 2 : (useEffects() ? 1 : 0),
        color: this.lastChance ? this.adjustedColorFont() : $r('sys.color.icon_fourth'),
        radius: defaultInnerRadius
      })
      .enabled(this.isEnabled)
      .brightness(this.lastChance ? 1.1 : 1)
      // .animation(defaultAnimation())
      .backgroundColor(this.adjustedColorBackground())
      .onClick(() => {
        // No double confirm
        if (!this.needDoubleConfirm) {
          this.clickAction();
          return;
        }

        // Need double confirm.
        clearTimeout(this.lastChanceTimeout);
        if (this.lastChance) {
          this.clickAction();
          animateToImmediately(defaultAnimation(), () => {
            this.lastChance = false;
          });
          return;
        }
        // First confirm.
        animateToImmediately(defaultAnimation(), () => {
          this.lastChance = true;
        });
        this.lastChanceTimeout = setTimeout(() => {
          animateToImmediately(defaultAnimation(), () => {
            this.lastChance = false;
          });
        }, 2000);
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
