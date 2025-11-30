import { fontSize_Large } from '../../hosts/bunch_of_defaults';

@Component
struct linysTextSubtitleDivision {
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop icon: ResourceStr = '';
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  opa: number = 0.6;

  build() {
    Row({ space: 8 }) {
      if (this.icon) {
        Text(this.icon)
          .fontColor(this.color == "" ? this.color_current_font : this.color)
          .fontSize(fontSize_Large() + 4)
          .fontWeight(FontWeight.Medium)
      }
      Text(this.text)
        .fontColor(this.color == "" ? this.color_current_font : this.color)
        .fontSize(fontSize_Large())
        .fontWeight(FontWeight.Bold)
    }
    .opacity(this.opa)
  }
}

export default linysTextSubtitleDivision;
