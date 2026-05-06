import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { getColor, meowThemeColorType } from '../settings';

/**
 * Once this is made a Builder, icon updates won't trigger UI refresh. My bad.
 * @param icon The icon.
 * @param clickAction The action.
 */
@Builder
export function MooSymbolButtonSmall(icon: Resource, clickAction?: () => void) {
  SymbolGlyph(icon)
    .padding(7)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight)
    .onClick(() => clickAction?.())
    .fontColor([getColor(meowThemeColorType.FONT)]);
}
