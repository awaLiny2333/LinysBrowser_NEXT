import { animation_default } from '../../hosts/bunch_of_defaults';
import linysCapsuleButton from './linysCapsuleButton';
import linysTimeoutButton from './linysTimeoutButton';

@Component
struct linysConfirmDenyButtons {
  onConfirm?: () => void;
  onDeny?: () => void;
  double_confirm: boolean = false;
  @Prop confirm_enabled: boolean = true;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Row({ space: 10 }) {
      if (this.onDeny) {
        linysCapsuleButton({ text: "  󰁖  " }) // Cancel
          .onClick(() => {
            if (this.onDeny) {
              this.onDeny();
            }
          })
      }
      if (this.onConfirm) {
        if (this.double_confirm) {
          linysTimeoutButton({
            text: "  󰀓  ", onExecution: () => {
              if (this.onConfirm) {
                this.onConfirm();
              }
            }
          })
        } else {
          linysCapsuleButton({ text: "  󰀓  " }) // Submit
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