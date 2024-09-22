import {
  animation_default,
  capsule_bar_height, click_effect_default, fontSize_Large } from '../hosts/bunch_of_settings';

@Component
struct linysCapsuleButton {
  @Prop text: ResourceStr = "";
  build() {
    Button(this.text)
      .type(ButtonType.Capsule)
      .backgroundColor($r("app.color.font_color_title"))
      .fontColor($r('app.color.start_window_background'))
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .clickEffect(click_effect_default())
      .animation(animation_default())
  }
}

export default linysCapsuleButton;