import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextArea from '../../components/texts/linysTextArea';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofPrompt {
  @State title: ResourceStr = 'Title Meow';
  @State message: ResourceStr = 'Message Meow';
  @State value: string = 'Value Meow';
  @Link promptResult: string;
  controller: CustomDialogController;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;
  // Actions
  onConfirm?: () => void;
  onDeny?: () => void;

  aboutToDisappear(): void {
    if (this.onDeny) {
      this.onDeny();
    }
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: this.title }) // Page url
        .width("100%")

      linysText({ text: this.message }) // Prompt message
        .width("100%")

      linysTextArea({ init_text: this.value, text: this.promptResult }) // Edit
        .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            if (this.onConfirm) {
              this.onConfirm();
            }
            this.controller.close();
          }
        },
        onDeny: () => {
          if (this.controller) {
            if (this.onDeny) {
              this.onDeny();
            }
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