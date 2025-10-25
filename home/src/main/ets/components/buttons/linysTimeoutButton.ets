import { animation_default, animation_popup_duration, capsule_bar_height, click_effect_default, fontSize_Large } from '../../hosts/bunch_of_defaults';

@Component
struct linysTimeoutButton {
  @Prop text: ResourceStr = '  󰃈  ';
  // editing
  @State one_more_step: boolean = false;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor =
    $r('app.color.font_color_title');
  // Operations
  onExecution?: () => void;
  // Timeout
  confirm_timeout_id: number | undefined = undefined;

  build() {
    Button(this.text)// Reset
      .opacity(0.9)
      .type(ButtonType.Capsule)
      .backgroundColor(this.one_more_step ? this.color_current_primary : this.color_current_font)
      .fontColor(this.one_more_step ? this.color_current_font : this.color_current_primary)
      .border({
        width: 2,
        color: this.one_more_step ? this.color_current_font : "transparent"
      })
      .animation(animation_default())
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .clickEffect(click_effect_default())
      .onClick(() => {
        if (this.one_more_step) {
          if (this.onExecution) {
            this.onExecution();
          }
          this.one_more_step = false;
          return;
        }
        this.one_more_step = true;
        clearTimeout(this.confirm_timeout_id);
        this.confirm_timeout_id = setTimeout(() => {
          this.one_more_step = false;
        }, animation_popup_duration())
      })
  }
}

export default linysTimeoutButton