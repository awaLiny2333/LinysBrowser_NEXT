import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { defaultAnimation, fontSizeSymbol, getColor, meowThemeColorType, standardSpacing, useEffects } from "../settings";

/**
 * Normal symbol buttons.
 */
@ComponentV2
struct MooSymbolButton {
  @Param icon: Resource = $r('sys.symbol.square_stack_3d');
  @Param onHold: boolean = false;
  @Param tips: TipsMessageType | undefined = undefined;
  // Events
  @Event clickAction: () => void;

  build() {
    SymbolGlyph(this.icon)
      .margin(this.onHold ? { left: standardSpacing / 4, right: standardSpacing / 4 } : 0)
      .brightness(this.onHold && useEffects() ? 1.1 : 1)
      .backgroundColor(this.onHold && !useEffects() ? getColor(meowThemeColorType.FONT) : Color.Transparent)
      .animation(defaultAnimation())
      .padding(3.5)
      .borderRadius(defaultInnerRadius)
      .fontSize(fontSizeSymbol)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      })
      .fontColor([this.onHold && !useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.FONT)])
      .bindTips(this.tips);
  }
}

export { MooSymbolButton };
