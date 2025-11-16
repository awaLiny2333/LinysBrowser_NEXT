import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofAlert {
  @Link event: OnAlertEvent | undefined;
  controller: CustomDialogController;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.event?.result.handleCancel();
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
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
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
  }
}

export default woofAlert;