import linysCapsuleButton from '../components/linysCapsuleButton';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import { jump_external_link } from '../utils/url_tools';

@CustomDialog
struct woofLinkJumper {
  controller: CustomDialogController;
  @Prop link: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 15 }) {
      linysTitleText({ text: $r('app.string.LinkJumper_webpage_asks_for_jump') })// This page is asking for a jump
        .width("100%")

      linysText({ text: this.link, max_lines: 5 })// link
        .width("100%")
        .padding(10)
        .borderRadius(13.5)
        .backgroundColor(this.color_current_secondary)

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
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofLinkJumper;