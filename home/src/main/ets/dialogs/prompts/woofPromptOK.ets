import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysText from '../../components/texts/linysText';
import { animation_default } from '../../hosts/bunch_of_defaults';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofPromptOK {
  controller: CustomDialogController;
  @Prop title: ResourceStr = $r('app.string.Settings_toolbox_import_settings')
  @Prop desc: ResourceStr = $r('app.string.Settings_toolbox_import_settings_ok')
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State content_height: number = 233;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    woofControlFrame({
      title: this.title,
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 15 }) {
          linysText({
            text: this.desc,
            max_lines: 5
          })
            .width("100%")
          linysCapsuleButton({ text: $r('app.string.OK') })
            .onClick(()=>{
              if (this.controller) {
                this.controller.close();
              }
            })
        }
        .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
        .animation(animation_default())
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

export default woofPromptOK;