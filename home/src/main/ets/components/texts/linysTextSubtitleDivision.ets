import { fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';

@Component
struct linysTextSubtitleDivision {
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop icon: ResourceStr = '';
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;

  build() {
    Row() {
      Row()
        .width('7%')
        .border({ width: { bottom: 1 }, color: this.color == "" ? this.color_current_font : this.color })
      Row({ space: 7 }) {
        if (this.icon) {
          Text(this.icon)
            .fontColor(this.color == "" ? this.color_current_font : this.color)
            .fontSize(fontSize_Large())
            .fontWeight(FontWeight.Normal)
            .maxLines(this.max_lines)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        Text(this.text)
          .fontColor(this.color == "" ? this.color_current_font : this.color)
          .fontSize(fontSize_Normal())
          .fontWeight(FontWeight.Normal)
          .maxLines(this.max_lines)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .padding(7)
      .borderRadius(8)
      .border({ width: 1, color: this.color == "" ? this.color_current_font : this.color })

      Row()
        .layoutWeight(1)
        .border({ width: { bottom: 1 }, color: this.color == "" ? this.color_current_font : this.color })
    }
    .opacity(0.75)
  }
}

export default linysTextSubtitleDivision;
