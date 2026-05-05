import { defaultItemRadius } from "../../catstypicalframework/utils/ui";
import { getColor, meowThemeColorType } from "../settings";

/**
 * Small symbol buttons, usually for window control buttons.
 *
 * @see entry/src/main/ets/components/parts/MeowTitleTop.ets
 */
@ComponentV2
struct MooSymbolButtonSmall {
  @Param icon: Resource = $r('sys.symbol.square_stack_3d');
  @Event clickAction: () => void;

  build() {
    SymbolGlyph(this.icon)
      .padding(7)
      .borderRadius(defaultItemRadius)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      })
      .fontColor([getColor(meowThemeColorType.FONT)]);
  }
}

export { MooSymbolButtonSmall };
