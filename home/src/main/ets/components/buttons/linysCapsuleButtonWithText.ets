import { animation_default } from '../../hosts/bunch_of_defaults';
import linysText from '../texts/linysText';
import linysCapsuleButton from './linysCapsuleButton';

@Component
struct linysCapsuleButtonWithText {
  // Info
  @Prop desc_text: ResourceStr = 'desc';
  @Prop button_text: ResourceStr = ' OwO ';
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand: string = 'right';
  onExecution?: () => void;

  build() {
    Row({ space: 10 }) {
      Row() {
        linysText({ text: this.desc_text, max_lines: 10 })
          .animation(animation_default())
      } // Text
      // .opacity(0.9)
      .justifyContent(this.preferred_hand == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .layoutWeight(1)

      linysCapsuleButton({ text: this.button_text })// Button
        .onClick(() => {
          if (this.onExecution) {
            this.onExecution();
          }
        })
    }
    .justifyContent(this.preferred_hand == 'right' ? FlexAlign.End : FlexAlign.Start)
    .direction(this.preferred_hand == 'right' ? Direction.Ltr : Direction.Rtl)
    .animation(animation_default())
    .width('100%')
  }
}

export default linysCapsuleButtonWithText;