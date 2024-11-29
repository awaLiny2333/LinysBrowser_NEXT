import { animation_default, click_effect_default, fontSize_Icon_Button } from '../hosts/bunch_of_defaults';

@Component
struct linysSymbol {
  @Prop symbol_glyph_target: string = 'sys.symbol.arrow_left';
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop color: ResourceColor = "";
  @Prop font_weight: FontWeight = FontWeight.Normal;

  build() {
    SymbolGlyph($r(this.symbol_glyph_target))
      .fontWeight(this.font_weight)
      .fontSize(fontSize_Icon_Button())
      .fontColor([this.color == "" ? this.color_current_font : this.color])
      .animation(animation_default())
      .clickEffect(click_effect_default())
  }
}

export default linysSymbol