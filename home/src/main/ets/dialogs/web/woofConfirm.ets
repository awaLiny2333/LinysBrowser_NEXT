import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextArea from '../../components/texts/linysTextArea';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofConfirm {
  // @Link event: OnConfirmEvent | undefined;
  controller: CustomDialogController;
  @LocalStorageLink('screen_height') screen_height: number = 0;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];
  // Actions
  title: ResourceStr = '';
  desc: string = '';
  @State desc_edit: string = ''; // To fool the TextArea
  onConfirm?: () => void;
  onDeny?: () => void;

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    if (this.onDeny) {
      this.onDeny();
    }
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: this.title, max_lines: 2 }) // Page url
        .width("100%")

      linysTextArea({
        init_text:this.desc,
        text: this.desc_edit
      })
        .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.onConfirm) {
            this.onConfirm();
          }
          if (this.controller) {
            this.controller.close();
          }
        },
        onDeny: () => {
          if (this.onDeny) {
            this.onDeny();
          }
          if (this.controller) {
            this.controller.close();
          }
        },
        deny_double_confirm: true,
        confirm_double_confirm: true,
      }) // Buttons
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofConfirm;