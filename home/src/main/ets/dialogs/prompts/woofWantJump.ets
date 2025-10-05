import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextArea from '../../components/texts/linysTextArea';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { jump_external_link } from '../../utils/url_tools';

@CustomDialog
struct woofWantJump {
  controller: CustomDialogController;
  @Prop link: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.LinkJumper_webpage_asks_for_jump') })// This page is asking for a jump
        .width("100%")

      linysTextArea({ init_text: this.link, text: this.link }) // Edit
        .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })

      linysText({ text: $r('app.string.LinkJumper_allow_jump') })// allow?
        .width("100%")

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            this.controller.close();
          }
          jump_external_link(this.link);
        },
        onDeny: () => {
          if (this.controller) {
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

export default woofWantJump;