import meowUAManager from '../../blocks/panels/meowUAManager';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofUAswitch {
  controller: CustomDialogController;
  // Color
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();

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
      .constraintSize({ maxHeight: 100 + 48.5 * this.bunch_of_user_agents.list_of_user_agents.length })
      .animation(animation_default())

      // .padding(15)
    }
  }
}

export default woofUAswitch;