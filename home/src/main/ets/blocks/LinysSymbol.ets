import { fontSize_Icon_Button } from '../hosts/BunchOfSettings';

@Component
struct LinysSymbol {
  @Prop symbol_glyph_target: string = 'sys.symbol.arrow_left';
  @Prop color: ResourceStr = $r('app.color.font_color_title');

  build() {
    SymbolGlyph($r(this.symbol_glyph_target))
      .fontSize(fontSize_Icon_Button())
      .fontColor([this.color])
  }
}

export default LinysSymbol