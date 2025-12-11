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
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;
  @State fixed_height_title: number = 0;
  @State fixed_height_quest: number = 0;
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.LinkJumper_webpage_asks_for_jump') })// This page is asking for a jump
        .width("100%")
        .onAreaChange((o, n) => {
          this.fixed_height_title = n.height as number;
        })

      linysTextArea({ init_text: this.link, text: this.link }) // Edit
        .constraintSize({
          maxHeight: Math.max(0, this.screen_height * 0.9 - this.fixed_height_quest - this.fixed_height_title - 35 - 45 - 40)
        })

      linysText({ text: $r('app.string.LinkJumper_allow_jump') })// allow?
        .width("100%")
        .onAreaChange((o, n) => {
          this.fixed_height_quest = n.height as number;
        })

      linysConfirmDenyButtons({
        onConfirm: () => {
          if (this.controller) {
            this.controller.close();
          }
          jump_external_link(this.link, this.getUIContext().getHostContext()!);
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
    .backgroundColor(this.effects ? undefined : this.color_current_primary)
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
  }
}

export default woofWantJump;