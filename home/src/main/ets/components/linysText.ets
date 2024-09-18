import { fontSize_Normal } from '../hosts/bunch_of_settings';

@Component
struct linysText {
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Normal())
  }
}

export default linysText