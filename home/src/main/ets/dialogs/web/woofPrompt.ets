import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextArea from '../../components/texts/linysTextArea';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofPrompt {
  event: OnPromptEvent | undefined = undefined;
  @State promptResult: string = '';
  controller: CustomDialogController;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // UI display
  @StorageLink('screen_height') screen_height: number = 0;

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

      linysTextArea({ init_text: this.event?.value, text: this.promptResult }) // Edit
        .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            this.event?.result.handlePromptConfirm(this.promptResult);
            this.controller.close();
          }
        },
        onDeny: () => {
          if (this.controller) {
            this.event?.result.handleCancel();
            this.controller.close();
          }
        }
      }) // Buttons
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofPrompt;