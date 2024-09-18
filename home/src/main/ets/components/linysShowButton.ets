import { animation_default, click_effect_default, fontSize_Large } from '../hosts/bunch_of_settings';
import linysSymbol from './linysSymbol';

@Component
struct linysShowButton {
  @Prop show: boolean = false;
  @Prop symbol_glyph_target: string = "sys.symbol.square_grid_2x2";
  @Prop color_false: ResourceStr = $r('app.color.font_color_title');
  @Prop color_true: ResourceStr = $r('app.color.start_window_background');
  @Prop text: ResourceStr = $r('app.string.Index_tabs_title');

  build() {
    Row() {
      linysSymbol({
        symbol_glyph_target: this.symbol_glyph_target,
        color: this.show ?
        this.color_true : this.color_false
      })

      Scroll() {
        Text(this.text)
          .fontSize(fontSize_Large() - 2)
          .fontColor($r('app.color.start_window_background'))
          .margin({ left: 4, right: 3 })
      }
      .width(this.show ? undefined : 0)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .animation(animation_default())
    }
    .padding(this.show ? 5 : 0)
    .backgroundColor(this.show ? this.color_false : "transparent")
    .borderRadius(10)
    .clickEffect(click_effect_default())
    .animation(animation_default())

  }
}

export default linysShowButton;