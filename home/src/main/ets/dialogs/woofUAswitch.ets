import meowUAManager from '../blocks/meowUAManager';
import woofControlFrame from './woofControlFrame';

@CustomDialog
struct woofUAswitch {
  controller: CustomDialogController;
  // Color
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_general_custom_ua'),
      controller: this.controller
    }) {
      Scroll() {
        meowUAManager()
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(this.color_current_primary)

      // .padding(15)
    }
  }
}

export default woofUAswitch;