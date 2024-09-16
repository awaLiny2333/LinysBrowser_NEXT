import { fontSize_Normal } from '../hosts/BunchOfSettings';

@Component
struct LinysText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Normal())
  }
}

export default LinysText