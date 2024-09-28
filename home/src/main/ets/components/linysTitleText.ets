import { fontSize_Large } from '../hosts/bunch_of_defaults';

@Component
struct linysTitleText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');
  @Prop max_lines: number = 1;

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

  }
}

export default linysTitleText
