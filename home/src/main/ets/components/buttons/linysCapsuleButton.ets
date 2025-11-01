import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../../hosts/bunch_of_defaults';

@Reusable // Can I?
@Component
struct linysCapsuleButton {
  @Prop text: ResourceStr = "";
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop color_button: ResourceColor = "";
  @Prop color_text: ResourceColor = "";
  opa: number = 0.9;
  build() {
    Button(this.text)
      .opacity(this.opa)
      .type(ButtonType.Capsule)
      .backgroundColor(this.color_button == "" ? this.color_current_font : this.color_button)
      .fontColor(this.color_text == "" ? this.color_current_primary : this.color_text)
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .border({
        width: 2,
        color: "transparent"
      })
      .clickEffect(click_effect_default())
      .animation(animation_default())
  }
}

export default linysCapsuleButton;