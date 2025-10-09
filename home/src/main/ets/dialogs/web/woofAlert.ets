import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofAlert {
  event: OnAlertEvent | undefined = undefined;
  controller: CustomDialogController;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');

  aboutToDisappear(): void {
    this.event?.result.handleCancel();
    // this.controller?.close();
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: this.event?.url, max_lines: 2 }) // Page url
        .width("100%")

      linysText({ text: this.event?.message, max_lines: 999 }) // Prompt message
        .width("100%")

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            this.event?.result.handleConfirm();
            this.controller.close();
          }
        },
        confirm_double_confirm: true
      }) // Buttons
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofAlert;