import { fontSize_Normal } from '../hosts/bunch_of_defaults';
import { LengthMetrics } from '@kit.ArkUI';

@Component
struct linysLink {
  // Colors
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  @Prop font_weight: FontWeight = FontWeight.Normal;
  @State link: string = "huawei.com";
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";
  // In fact this param is designed for closing some opened panel
  @Link will_be_reversed_boolean: boolean;

  build() {
    Text(this.text)
      .fontColor(this.color == "" ? this.color_current_font : this.color)
      .fontSize(fontSize_Normal())
      .fontWeight(this.font_weight)
      .textAlign(TextAlign.Start)
      .maxLines(this.max_lines)
      .lineSpacing(LengthMetrics.vp(4))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => {
        this.universal_new_tab_gateway = this.link;
        this.will_be_reversed_boolean = !this.will_be_reversed_boolean;
      })
      .accessibilityText(this.text + ',' + this.link)
      .accessibilityDescription($r('app.string.Accessibility_desc_linysLink'))
  }
}

export default linysLink