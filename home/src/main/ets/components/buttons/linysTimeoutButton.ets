import { animation_default, capsule_bar_height, click_effect_default, fontSize_Large } from '../../hosts/bunch_of_defaults';

@Component
struct linysTimeoutButton {
  @Prop text: ResourceStr = '  󰃈  ';
  // editing
  @State delete_confirm: number = 0;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor =
    $r('app.color.font_color_title');
  // Operations
  onExecution?: () => void;

  build() {
    Button(this.text)// Reset
      .opacity(0.9)
      .type(ButtonType.Capsule)
      .backgroundColor(this.delete_confirm > 0 ? this.color_current_primary : this.color_current_font)
      .fontColor(this.delete_confirm > 0 ? this.color_current_font : this.color_current_primary)
      .border({
        width: 2,
        color: this.delete_confirm > 0 ? this.color_current_font : "transparent"
      })
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .onClick(() => {
        this.delete_confirm += 300;
        if (this.delete_confirm >= 301) {
          if (this.onExecution) {
            this.onExecution();
          }
          this.delete_confirm = 0;
        }
      })
      .clickEffect(click_effect_default())
      .animation(animation_default())
      .onAppear(() => {
        setInterval(() => {
          if (this.delete_confirm > 0) {
            this.delete_confirm -= 1;
          }
          // Reset delete confirm
        }, 10)
      })
  }
}

export default linysTimeoutButton