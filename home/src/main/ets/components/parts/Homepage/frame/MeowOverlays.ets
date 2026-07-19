/**
 * This is the overlay layer that would show up in the top-right corner
 * when windowed fullscreen is on.
 * This overlay layer ensures the readability of window control buttons
 * and provides a handler to drag the window around.
 */
import { defaultRoundedRadius, windowTopAvoidRight } from "../../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { meowThemeColorType, standardSpacing } from "../../../constants";
import { defaultAnimation, getColor, useEffects } from "../../../settings";

@Builder
export function MeowOverlays(myUi: meowUiHost) {
  Row({ space: standardSpacing * 1.5 }) {
    Row() {
      SymbolGlyph($r('sys.symbol.move')).fontColor([getColor(meowThemeColorType.FONT)]);
    }
    .brightness(0.96)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(useEffects() ? undefined : getColor(meowThemeColorType.SECONDARY))
    .backdropBlur(useEffects() ? 60 : 0)
    .border({ radius: defaultRoundedRadius, width: useEffects() ? 1.2 : 0, color: getColor(meowThemeColorType.PRIMARY) })
    .hitTestBehavior(HitTestMode.BLOCK_HIERARCHY)
    .width(42)
    .height(32)
    .hoverEffect(HoverEffect.Highlight)
    .shadow(useEffects() ? ShadowStyle.OUTER_DEFAULT_LG : ShadowStyle.OUTER_FLOATING_SM);

    Row()
      .brightness(0.96)
      .backgroundColor(useEffects() ? undefined : getColor(meowThemeColorType.SECONDARY))
      .backdropBlur(useEffects() ? 60 : 0)
      .border({ radius: defaultRoundedRadius, width: useEffects() ? 1.2 : 0, color: getColor(meowThemeColorType.PRIMARY) })
      .hitTestBehavior(HitTestMode.BLOCK_HIERARCHY)
      .width(windowTopAvoidRight - 16)
      .height(32)
      .shadow(useEffects() ? ShadowStyle.OUTER_DEFAULT_LG : ShadowStyle.OUTER_FLOATING_SM);
  }
  .visibility(myUi.windowFocused ? Visibility.Visible : Visibility.Hidden)
  .animation(defaultAnimation())
  .padding({
    right: standardSpacing * 1.5,
    top: standardSpacing * 1.25,
  })
  .justifyContent(FlexAlign.End)
  .hitTestBehavior(HitTestMode.None)
  .width('100%');
}
