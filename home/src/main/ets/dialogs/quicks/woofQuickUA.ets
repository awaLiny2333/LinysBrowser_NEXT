import meowUAManager from '../../blocks/panels/meowUAManager';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofQuickUA {
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
      .borderRadius(13.5)
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(this.color_current_primary)
      .constraintSize({ maxHeight: 92.5 + 48.5 * bunch_of_user_agents.list_of_user_agents.length })
      .animation(animation_default())
    }
  }
}

export default woofQuickUA;