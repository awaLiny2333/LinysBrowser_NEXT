import { fontSize_Large } from '../hosts/bunch_of_defaults';

@Component
struct linysTitleText {
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  @Prop align_another_side: boolean = false;

  build() {
    Text(this.text)
      .fontColor(this.color == "" ? this.color_current_font : this.color)
      .width(this.align_another_side ? '100%' : undefined)
      .textAlign(this.align_another_side ? TextAlign.End : TextAlign.Start)
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

export default linysTitleText
