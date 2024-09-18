import { animation_default, click_effect_default, fontSize_Icon_Button } from '../hosts/bunch_of_settings';

@Component
struct linysSymbol {
  @Prop symbol_glyph_target: string = 'sys.symbol.arrow_left';
  @Prop color: ResourceStr = $r('app.color.font_color_title');

  build() {
    SymbolGlyph($r(this.symbol_glyph_target))
      .fontSize(fontSize_Icon_Button())
      .fontColor([this.color])
      .animation(animation_default())
      .clickEffect(click_effect_default())
  }
}

export default linysSymbol