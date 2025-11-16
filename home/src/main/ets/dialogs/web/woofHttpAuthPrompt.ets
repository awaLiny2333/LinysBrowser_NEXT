import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { capsule_bar_height } from '../../hosts/bunch_of_defaults';

@CustomDialog
struct woofHttpAuthPrompt {
  @Link e: OnHttpAuthRequestEvent | undefined;
  username: string = 'Username Meow';
  password: string = 'Password Meow';
  controller: CustomDialogController;
  @StorageLink('woofHttpAuthPrompt_result') woofHttpAuthPrompt_result: boolean = false;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.cancel();
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: this.e?.host + ' [' + this.e?.realm + ']', max_lines: 2 }) // Page url
        .width("100%")

      linysText({ text: $r('app.string.http_auth_desc'), max_lines: 2 }) // Prompt message
        .width("100%")

      TextInput({ text: '', placeholder: $r('app.string.username') }) // Username
        .onChange((value) => {
          this.username = value;
        })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .id('woofHttpAuthPrompt_username')
        .onSubmit(() => {
          focusControl.requestFocus('woofHttpAuthPrompt_password');
        })
        .height(capsule_bar_height())
        .onAppear(() => {
          focusControl.requestFocus('woofHttpAuthPrompt_username');
        })

      TextInput({ text: '', placeholder: $r('app.string.password') }) // Password
        .onChange((value) => {
          this.password = value;
        })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .id('woofHttpAuthPrompt_password')
        .onSubmit(() => {
          // Submit
          this.submit();
          if (this.controller) {
            this.controller.close();
          }
        })
        .height(capsule_bar_height())

      linysConfirmDenyButtons({
        onConfirm: () => {
          this.submit();
          if (this.controller) {
            this.controller.close();
          }
        },
        onDeny: () => {
          this.cancel();
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
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .backgroundColor(this.color_current_primary)
  }

  submit() {
    this.woofHttpAuthPrompt_result = true;
    this.e?.handler.confirm(this.username, this.password);
  }

  cancel() {
    this.woofHttpAuthPrompt_result = false;
    this.e?.handler.cancel();
  }
}

export default woofHttpAuthPrompt;