import { defaultItemRadius } from "../../catstypicalframework/utils/ui";
import { getColor, meowThemeColorType } from "../settings";
// import { AppStorageV2 } from "@kit.ArkUI";
// import { meowFreeWindowModeStatus } from "../../catstypicalframework/hosts/meowFreeWindowModeStatus";

/**
 * Small symbol buttons, usually for window control buttons.
 *
 * @see entry/src/main/ets/components/parts/MeowTitleTop.ets
 */
// @ReusableV2
@ComponentV2
struct MooSymbolButtonSmall {
  // @Local myFree: meowFreeWindowModeStatus = AppStorageV2.connect(meowFreeWindowModeStatus)!;
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
      // .opacity(this.myFree.onFocus ? 1 : 0.3)
      .fontColor([getColor(meowThemeColorType.FONT)]);
  }
}

export { MooSymbolButtonSmall };
