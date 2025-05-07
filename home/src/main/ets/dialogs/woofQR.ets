import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import woofControlFrame from './woofControlFrame';

@CustomDialog
struct woofQR {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop title: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    woofControlFrame({
      title: $r('app.string.QR_code'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 5 }) {
          QRCode(this.link)
            .color(this.color_current_font)
            .backgroundColor("transparent")
            .padding(20)

          linysTitleText({
            text: this.title,
            max_lines: 3
          })
            .width("100%")
          linysText({
            text: this.link,
            max_lines: 5
          })
            .width("100%")
            .opacity(0.7)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({ maxHeight: 320 })
    }
  }
}

export default woofQR;