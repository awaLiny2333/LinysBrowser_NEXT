import { fontSize_Normal } from '../hosts/bunch_of_settings';
import { LengthMetrics } from '@kit.ArkUI';

@Component
struct linysText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');
  @Prop max_lines: number = 1;
  @Prop font_weight: FontWeight = FontWeight.Normal;

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Normal())
      .fontWeight(this.font_weight)
      .maxLines(this.max_lines)
      .lineSpacing(LengthMetrics.vp(4))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

export default linysText