import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofQR {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop title: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State content_height: number = 233;

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

          linysTextTitle({
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
        .onAreaChange((_o, n) => {
          this.content_height = n.height as number;
        })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({ maxHeight: this.content_height })
    }
  }
}

export default woofQR;