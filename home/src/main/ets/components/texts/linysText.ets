import { fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { LengthMetrics } from '@kit.ArkUI';

@Component
struct linysText {
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  @Prop font_weight: FontWeight = FontWeight.Regular;
  @Prop align_another_side: boolean = false;

  build() {
    Text(this.text)
      .fontColor(this.color == "" ? this.color_current_font : this.color)
      .fontSize(fontSize_Normal())
      .fontWeight(this.font_weight)
      .width(this.align_another_side ? '100%' : undefined)
      .textAlign(this.align_another_side ? TextAlign.End : TextAlign.Start)
      .maxLines(this.max_lines)
      .lineSpacing(LengthMetrics.vp(4))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

export default linysText