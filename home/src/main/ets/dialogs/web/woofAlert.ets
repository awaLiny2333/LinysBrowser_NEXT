import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofAlert {
  event: OnAlertEvent | undefined = undefined;
  controller: CustomDialogController;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');

  aboutToDisappear(): void {
    this.event?.result.handleCancel();
    // this.controller?.close();
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: this.event?.url }) // Page url
        .width("100%")

      linysText({ text: this.event?.message }) // Prompt message
        .width("100%")

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            this.event?.result.handleConfirm();
            this.controller.close();
          }
        },
        double_confirm: true
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