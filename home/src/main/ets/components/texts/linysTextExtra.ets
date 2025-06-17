import { fontSize_Extra } from '../../hosts/bunch_of_defaults';

@Component
struct linysTextExtra {
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;

  build() {
    Text(this.text)
      .fontColor(this.color == "" ? this.color_current_font : this.color)
      .fontSize(fontSize_Extra())
      .fontWeight(FontWeight.Bold)
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

export default linysTextExtra;
