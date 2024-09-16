import { fontSize_Large } from '../hosts/BunchOfSettings';

@Component
struct LinysTitleText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
  }
}

export default LinysTitleText
