import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { meowThemeColorType } from '../constants';
import { getColor } from '../settings';

/**
 * Once this is made a Builder, icon updates won't trigger UI refresh. My bad.
 * @param icon The icon.
 * @param clickAction The action.
 */
@Builder
export function MooSymbolButtonSmall(icon: Resource, clickAction?: () => void, myHitTestMode?: HitTestMode, myPadding?: Padding | number) {
  SymbolGlyph(icon)
    .padding(myPadding || 6.5)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight)
    .onClick(() => {
      clickAction?.();
    })
    .fontColor([getColor(meowThemeColorType.FONT)])
    .hitTestBehavior(myHitTestMode || HitTestMode.Default);
}
