import meowUAManager from '../blocks/meowUAManager';
import linysTitleText from '../components/linysTitleText';
import { animation_default } from '../hosts/bunch_of_defaults';

@CustomDialog
struct woofUAswitch {
  controller: CustomDialogController;
  // Color
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');

  build() {
    Scroll() {
      Column({ space: 15 }) {
        linysTitleText({ text: $r('app.string.Settings_general_custom_ua') })
          .margin({ top: 5 })
          .width('100%')
        meowUAManager()
      }
    }
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.color_current_primary)
    .padding(15)
  }
}

export default woofUAswitch;