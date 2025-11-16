import { animation_default } from '../../hosts/bunch_of_defaults';
import linysText from '../texts/linysText';

@Component
struct linysSwitchWithText {
  // Links
  @Prop text: ResourceStr = "";
  @Link toggle_state: boolean;
  onExecution?: () => void;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand: string = 'right';
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('color_current_back') color_current_back: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('effects') effects: boolean = false;

  build() {
    Row({ space: 10 }) {
      Row() {
        linysText({ text: this.text, max_lines: 5 })
      }
      // .opacity(0.9)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)

      Toggle({ isOn: this.toggle_state, type: ToggleType.Switch })
        .switchPointColor(this.effects ? this.color_current_font : this.color_current_secondary)
        .opacity(!this.toggle_state && this.effects ? 0.5 : 1)
        .selectedColor(this.effects ? $r('sys.color.comp_background_secondary') : this.color_current_back)
        .onChange(isOn => {
          this.toggle_state = isOn;
          if (this.onExecution) {
            this.onExecution();
          }
        })
    } // Toggle
    .direction(this.preferred_hand == 'right' ? Direction.Ltr : Direction.Rtl)
    .animation(animation_default())
    .width("100%")
  }
}

export default linysSwitchWithText;