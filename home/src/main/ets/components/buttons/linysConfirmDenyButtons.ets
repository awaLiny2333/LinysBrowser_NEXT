import { animation_default } from '../../hosts/bunch_of_defaults';
import linysCapsuleButton from './linysCapsuleButton';
import linysTimeoutButton from './linysTimeoutButton';

// @Reusable
@Component
struct linysConfirmDenyButtons {
  onConfirm?: () => void;
  onDeny?: () => void;
  confirm_double_confirm: boolean = false;
  deny_double_confirm: boolean = false;
  confirm_text: ResourceStr = '  󰀓  ';
  deny_text: ResourceStr = '  󰁖  '
  @Prop confirm_enabled: boolean = true;
  @Prop deny_enabled: boolean = true;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Row({ space: 10 }) {
      if (this.onDeny) {
        if (this.deny_double_confirm) {
          linysTimeoutButton({
            text: this.deny_text, onExecution: () => {
              if (this.onDeny) {
                this.onDeny();
              }
            }
          })
        } else {
          linysCapsuleButton({ text: this.deny_text }) // Deny
            .onClick(() => {
              if (this.onDeny) {
                this.onDeny();
              }
            })
            .enabled(this.deny_enabled)
            .opacity(this.deny_enabled ? 1 : 0.7)
        }
      }

      if (this.onConfirm) {
        if (this.confirm_double_confirm) {
          linysTimeoutButton({
            text: this.confirm_text, onExecution: () => {
              if (this.onConfirm) {
                this.onConfirm();
              }
            }
          })
        } else {
          linysCapsuleButton({ text: this.confirm_text }) // Submit
            .onClick(() => {
              if (this.onConfirm) {
                this.onConfirm();
              }
            })
            .enabled(this.confirm_enabled)
            .opacity(this.confirm_enabled ? 1 : 0.7)
        }
      }
    }
    .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
    .animation(animation_default())
    .width('100%')
  }
}

export default linysConfirmDenyButtons;