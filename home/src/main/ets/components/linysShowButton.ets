import { animation_default, click_effect_default, fontSize_Large } from '../hosts/bunch_of_defaults';
import linysSymbol from './linysSymbol';

@Component
struct linysShowButton {
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop show: boolean = false;
  @Prop symbol_glyph_target: string = "sys.symbol.square_grid_2x2";
  @Prop color_false: ResourceColor = "";
  @Prop color_true: ResourceColor = "";
  @Prop text: ResourceStr = $r('app.string.Index_tabs_title');

  build() {
    Row() {
      linysSymbol({
        symbol_glyph_target: this.symbol_glyph_target,
        color: this.show ?
          (this.color_true == "" ? this.color_current_primary : this.color_current_font) :
          (this.color_false == "" ? this.color_current_font : this.color_false)
      })

      Scroll() {
        Text(this.text)
          .fontSize(fontSize_Large() - 2)
          .fontColor(this.color_current_primary)
          .margin({ left: 4, right: 3 })
      }
      .width(this.show ? undefined : 0)
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .animation(animation_default())
    }
    .padding(this.show ? 5 : 0)
    .backgroundColor(this.show ? (this.color_false == "" ? this.color_current_font : this.color_false) : "transparent")
    .borderRadius(10)
    .clickEffect(click_effect_default())
    .animation(animation_default())
    .accessibilityText(this.text as string)
    .accessibilityDescription($r('app.string.Accessibility_desc_linysShowButton'))
    .accessibilityGroup(true)
  }
}

export default linysShowButton;