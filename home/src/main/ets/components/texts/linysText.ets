import { animation_default, click_effect_default, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { LengthMetrics } from '@kit.ArkUI';

@Component
struct linysText {
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  @Prop font_weight: FontWeight = FontWeight.Regular;
  @Prop is_description: boolean = false;
  @Prop is_expanded: boolean = false;

  build() {
    if (this.is_description) {
      Scroll() {
        Text(this.text)
          .fontColor(this.color == "" ? this.color_current_font : this.color)
          .fontSize(fontSize_Normal())
          .fontWeight(this.font_weight)
          .maxLines(!this.is_expanded ? 1 : undefined)
          .lineSpacing(LengthMetrics.vp(4))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .animation(animation_default())
      }
      .nestedScroll({scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
      .align(Alignment.TopStart)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      // .edgeEffect(EdgeEffect.Spring)
      .constraintSize(this.is_expanded ? {} : { maxHeight: 40 })
      .animation(animation_default())
      .borderRadius(12)
      .padding(10)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width('100%')
      .onClick(() => {
        this.is_expanded = !this.is_expanded;
      })
      .clickEffect(click_effect_default())
    } else {
      Text(this.text)
        .fontColor(this.color == "" ? this.color_current_font : this.color)
        .fontSize(fontSize_Normal())
        .fontWeight(this.font_weight)
        .maxLines(this.max_lines)
        .lineSpacing(LengthMetrics.vp(4))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }
}

export default linysText;