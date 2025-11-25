import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextArea from '../../components/texts/linysTextArea';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { capsule_bar_height } from '../../hosts/bunch_of_defaults';

@CustomDialog
struct woofPrompt {
  @State title: ResourceStr = 'Title Meow';
  @State message: ResourceStr = 'Message Meow';
  @State value: string = 'Value Meow';
  @Link promptResult: string;
  single_line: boolean = false;
  controller: CustomDialogController;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;
  // Actions
  onConfirm?: () => void;
  onDeny?: () => void;
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];
  // Focus
  my_id: string = 'woofHistory_search_input_' + Date.now().toString();

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

      linysText({ text: this.message, max_lines: 999 }) // Prompt message
        .width("100%")

      if (this.single_line) {
        TextInput({ text: this.value })
          .onChange((value) => {
            this.promptResult = value;
          })
          .fontWeight(FontWeight.Regular)
          .fontColor(this.color_current_font)
          .caretColor(this.color_current_font)
          .selectedBackgroundColor(this.color_current_font)
          .onSubmit(() => {
            if (this.controller) {
              if (this.onConfirm) {
                this.onConfirm();
              }
              this.controller.close();
            }
          })
          .height(capsule_bar_height())
          .id(this.my_id)
          .onAppear(() => {
            // Auto focus on history
            if (AppStorage.get('free_window_mode') as boolean) {
              this.focus_input();
            }
          })
      } else {
        linysTextArea({ init_text: this.value, text: this.promptResult }) // Edit
          .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })
          .id(this.my_id)
          .onAppear(() => {
            // Auto focus on history
            if (AppStorage.get('free_window_mode') as boolean) {
              this.focus_input();
            }
          })
      }

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
        },
        deny_double_confirm: true,
        confirm_double_confirm: true,
      }) // Buttons
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.effects ? undefined : this.color_current_primary)
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
  }

  /**
   * Focus on the search input.
   * */
  focus_input() {
    focusControl.requestFocus(this.my_id);
  }
}

export default woofPrompt;