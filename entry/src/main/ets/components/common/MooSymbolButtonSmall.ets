import { defaultMenuItemRadius } from "../../catstypicalframework/utils/ui";
import { getColor, meowThemeColorType } from "../settings";
import { AppStorageV2 } from "@kit.ArkUI";
import { meowFreeWindowModeStatus } from "../../catstypicalframework/hosts/meowFreeWindowModeStatus";

/**
 * Small symbol buttons, usually for window control buttons.
 *
 * @see entry/src/main/ets/components/parts/MeowTitleTop.ets
 */
@ComponentV2
struct MooSymbolButtonSmall {
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus)!;
  @Param icon: Resource = $r('sys.symbol.square_stack_3d');
  @Event clickAction: () => void;

  build() {
    SymbolGlyph(this.icon)
      .padding(7)
      .borderRadius(defaultMenuItemRadius)
      .hoverEffect(HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      })
      .opacity(this.myMeowFreeWindowModeStatus.onFocus ? 1 : 0.3)
      .fontColor([getColor(meowThemeColorType.FONT)]);
  }
}

export { MooSymbolButtonSmall };
