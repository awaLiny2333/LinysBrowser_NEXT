import { animation_default } from '../../hosts/bunch_of_defaults';
import linysText from '../texts/linysText';
import linysTimeoutButton from './linysTimeoutButton';

@Component
struct linysTimeoutButtonWithText {
  // Info
  @State desc_text: ResourceStr = 'desc'; // @Param
  @State button_text: ResourceStr = ' OwO '; // @Param
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand: string = 'right';
  onExecution?: () => void;

  build() {
    Row({ space: 10 }) {
      Row() {
        linysText({ text: this.desc_text, max_lines: 10 })
      } // Text
      .justifyContent(this.preferred_hand == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .layoutWeight(1)

      linysTimeoutButton({
        text: this.button_text,
        onExecution: () => {
          if (this.onExecution) {
            this.onExecution();
          }
        }
      }) // Button
    }
    .justifyContent(this.preferred_hand == 'right' ? FlexAlign.End : FlexAlign.Start)
    .direction(this.preferred_hand == 'right' ? Direction.Ltr : Direction.Rtl)
    .animation(animation_default())
    .width('100%')
  }
}

export default linysTimeoutButtonWithText;