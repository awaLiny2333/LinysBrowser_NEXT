import { animation_default, click_effect_default, fontSize_Icon_Button } from '../hosts/bunch_of_defaults';

@Component
struct linysSymbol {
  @Prop symbol_glyph_target: string = 'sys.symbol.arrow_left';
  @Prop color: ResourceStr = $r('app.color.font_color_title');
  @Prop font_weight: FontWeight = FontWeight.Normal;

  build() {
    SymbolGlyph($r(this.symbol_glyph_target))
      .fontWeight(this.font_weight)
      .fontSize(fontSize_Icon_Button())
      .fontColor([this.color])
      .animation(animation_default())
      .clickEffect(click_effect_default())
  }
}

export default linysSymbol