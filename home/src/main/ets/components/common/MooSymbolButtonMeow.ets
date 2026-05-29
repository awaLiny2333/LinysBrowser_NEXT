import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { defaultMooSymbolSize, fontSizeSymbol, meowThemeColorType } from "../constants";
import { defaultAnimation, getColor, useEffects } from "../settings";

/**
 * Symbol buttons that changes into another state for a while after being clicked.
 */
@ComponentV2
export struct MooSymbolButtonMeow {
  @Param icon: Resource = $r('sys.symbol.square_stack_3d');
  @Param iconMeow: Resource = $r('sys.symbol.checkmark');
  @Param tips: TipsMessageType | undefined = undefined;
  @Param isEnabled: boolean = true;
  @Param meowDurationMs: number = 1000;
  // Events
  @Event clickAction: () => void;
  // Local
  @Local isMeowing: boolean = false;
  meowingTimeoutId: number | undefined = undefined;

  build() {
    SymbolGlyph(this.isMeowing ? this.iconMeow : this.icon)
      .width(defaultMooSymbolSize)
      .height(defaultMooSymbolSize)
      .opacity(this.isEnabled ? 1 : 0.4)
      .enabled(this.isEnabled)
      .brightness(this.isMeowing && useEffects() ? 1.1 : 1)
      .backgroundColor(this.isMeowing && !useEffects() ? getColor(meowThemeColorType.FONT) : Color.Transparent)
      .animation(defaultAnimation())
      .padding(3.5)
      .borderRadius(defaultInnerRadius)
      .fontSize(fontSizeSymbol)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
        this.isMeowing = true;
        clearTimeout(this.meowingTimeoutId);
        this.meowingTimeoutId = setTimeout(() => {
          this.isMeowing = false;
        }, this.meowDurationMs);
      })
      .fontColor([this.isMeowing && !useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.FONT)])
      .bindTips(this.tips);
  }
}
