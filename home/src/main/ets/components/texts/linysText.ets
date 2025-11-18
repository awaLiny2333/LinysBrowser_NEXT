import lazy { animation_default } from '../../hosts/bunch_of_defaults';
import { click_effect_default, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { LengthMetrics } from '@kit.ArkUI';

// @Reusable  // Will this affect anything?
@Component
struct linysText {
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop font_weight: FontWeight = FontWeight.Regular;
  is_description: boolean = false;
  max_lines: number = 1;
  overflow_type: TextOverflow = TextOverflow.Ellipsis;
  // UI
  @Prop is_expanded: boolean = false;
  can_hover: boolean = false;
  @State isHov: boolean = false;

  build() {
    if (this.is_description) {
      Scroll() {
        Text(this.text)
          .fontColor(this.color == "" ? this.color_current_font : this.color)
          .fontSize(fontSize_Normal())
          .fontWeight(this.font_weight)
          .maxLines(!this.is_expanded ? 1 : undefined)
          .lineSpacing(LengthMetrics.vp(4))
          .textOverflow({ overflow: this.overflow_type })
          .animation(animation_default())
      }
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
      .align(Alignment.TopStart)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      // .edgeEffect(EdgeEffect.Spring)
      .constraintSize(this.is_expanded ? {} : { maxHeight: 40 })
      .brightness(this.isHov ? 1.1 : 1)
      .animation(animation_default())
      .borderRadius(12)
      .padding(10)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width('100%')
      .onClick(() => {
        this.is_expanded = !this.is_expanded;
      })
      .clickEffect(click_effect_default())
      .onHover((isHv) => {
        this.isHov = isHv;
      })
    } else {
      Text(this.text)
        .brightness(this.isHov ? 1.1 : 1)
        .animation(this.can_hover ? animation_default() : { duration: 0 })
        .padding(this.can_hover ? {
          left: 7,
          right: 7,
          top: 5,
          bottom: 5
        } : 0)
        .borderRadius(this.can_hover ? 7.5 : 0)
        .fontColor(this.color == "" ? this.color_current_font : this.color)
        .fontSize(fontSize_Normal())
        .fontWeight(this.font_weight)
        .maxLines(this.max_lines)
        .lineSpacing(LengthMetrics.vp(4))
        .textOverflow({ overflow: this.overflow_type })
        .onHover((isHv) => {
          if (this.can_hover) {
            this.isHov = isHv;
          }
        })
    }
  }
}

export default linysText;