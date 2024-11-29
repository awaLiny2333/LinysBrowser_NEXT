import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';

@Component
struct linysCapsuleButton {
  @Prop text: ResourceStr = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop color_button: ResourceColor = "";
  @Prop color_text: ResourceColor = "";

  build() {
    Button(this.text)
      .type(ButtonType.Capsule)
      .backgroundColor(this.color_button == "" ? this.color_current_font : this.color_button)
      .fontColor(this.color_text == "" ? this.color_current_primary : this.color_text)
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .clickEffect(click_effect_default())
      .animation(animation_default())
  }
}

export default linysCapsuleButton;