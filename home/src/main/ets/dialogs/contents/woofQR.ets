import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { click_effect_default } from '../../hosts/bunch_of_defaults';
import { copy } from '../../utils/clipboard_tools';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofQR {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop title: string = '';
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State content_height: number = 233;
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
    woofControlFrame({
      title: $r('app.string.QR_code'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 15 }) {
          QRCode(this.link)
            .color(this.color_current_font)
            .backgroundColor("transparent")
            .padding(20)

          Column({ space: 5 }) {
            linysTextTitle({
              text: this.title,
              max_lines: 5
            })
              .width("100%")
              .clickEffect(click_effect_default())
              .onClick(() => {
                copy(this.title);
              })

            linysText({
              text: this.link,
              font_weight: FontWeight.Bold,
              max_lines: 10
            })
              .width("100%")
              .opacity(0.7)
              .clickEffect(click_effect_default())
              .onClick(() => {
                copy(this.link);
              })
          } // Info

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