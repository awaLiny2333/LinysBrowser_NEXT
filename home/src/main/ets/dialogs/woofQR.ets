import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';

@CustomDialog
struct woofQR {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop title: string = '';

  build() {
    Scroll() {
      Column({ space: 10 }) {
        QRCode(this.link)
          .color($r('app.color.font_color_title'))
          .backgroundColor("transparent")
          .padding({ bottom: 20 })

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
      .padding(40)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width("100%")
    }
    .backgroundColor($r('app.color.start_window_background'))
    .edgeEffect(EdgeEffect.Spring)
  }
}

export default woofQR;