import { fontSize_Normal } from '../hosts/bunch_of_settings';

@Component
struct linysText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');
  @Prop max_lines: number = 1;

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Normal())
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

export default linysText