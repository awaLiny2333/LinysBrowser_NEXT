import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { jump_external_link } from '../../utils/url_tools';

@CustomDialog
struct woofWantJump {
  controller: CustomDialogController;
  @Prop link: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI display
  @StorageLink('screen_height') screen_height: number = 0;

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.LinkJumper_webpage_asks_for_jump') })// This page is asking for a jump
        .width("100%")

      TextArea({ text: this.link })// linysText({ text: this.link, max_lines: 5 })// link
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .backgroundColor(this.color_current_secondary)
        .width("100%")
        .padding(10)
        .borderRadius(13.5)
        .clickEffect(click_effect_default())
        .constraintSize({ maxHeight: Math.max(0, this.screen_height - 160) })

      linysText({ text: $r('app.string.LinkJumper_allow_jump') })// allow?
        .width("100%")
      Row({ space: 10 }) {
        linysCapsuleButton({ text: "  󰁖  " })// Cancel
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          })
        linysCapsuleButton({ text: "  󰀓  " })// Submit
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
            jump_external_link(this.link);
          })
      }
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .width('100%')
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofWantJump;