import { resourceColor2Metrics } from '../../catstypicalframework/utils/ui';
import { useEffects, getColor, meowThemeColorType } from './constants';
import { TabSegmentButtonV2, SegmentButtonV2Items } from '@kit.ArkUI';

/**
 * The encapsulated TabSegmentButtonV2 component.
 *
 * If initSelected is not provided, the first item will be selected by default.
 */
@ComponentV2
struct MooTabSegmentV2 {
  @Param @Once initSelected: number = 0;
  @Param @Require items: SegmentButtonV2Items;
  @Event onSelected: (index: number) => void;

  build() {
    TabSegmentButtonV2({
      items: this.items,
      selectedIndex: this.initSelected!!,
      itemSelectedFontWeight: FontWeight.Bold,
      itemFontWeight: FontWeight.Normal,
      buttonBackgroundColor: resourceColor2Metrics(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY)),
      itemFontColor: resourceColor2Metrics(getColor(meowThemeColorType.FONT)),
      itemSelectedBackgroundColor: resourceColor2Metrics(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.FONT)),
      itemSelectedFontColor: useEffects() ? undefined : resourceColor2Metrics(getColor(meowThemeColorType.PRIMARY)),
      onItemClicked: (index) => {
        this.onSelected(index);
      }
    }).border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: 22 } : { width: 0 });
  }
}

export { MooTabSegmentV2 };
