import { animation_default, click_effect_default, fontSize_Icon_Button } from '../../hosts/bunch_of_defaults';

@Reusable // Will this affect anything? // Weird layout bugs
@Component
struct linysSymbol {
  @Prop symbol_glyph_target: string = 'sys.symbol.arrow_left';
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @Prop color: ResourceColor = "";
  @Prop font_weight: FontWeight = FontWeight.Regular;
  @Prop font_size: number | undefined = undefined;
  // Settings
  can_hover: boolean = false;
  radius: number = 10;
  // UI
  @State isHov: boolean = false;

  build() {
    SymbolGlyph($r(this.symbol_glyph_target))
      .fontWeight(this.font_weight)
      .fontSize(this.font_size || fontSize_Icon_Button())
      .fontColor([this.color == "" ? this.color_current_font : this.color])
      .brightness(this.isHov ? 1.1 : 1)
      .animation(animation_default())
      .padding(this.can_hover ? 5 : 0)
      .borderRadius(this.can_hover ? this.radius : 0)
      .clickEffect(click_effect_default())
      .onHover((isHv) => {
        if (this.can_hover) {
          this.isHov = isHv;
        }
      })
  }
}

export default linysSymbol