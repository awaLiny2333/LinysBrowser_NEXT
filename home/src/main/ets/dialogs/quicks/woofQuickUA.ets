import meowUAManager from '../../blocks/panels/meowUAManager';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import lazy woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofQuickUA {
  controller: CustomDialogController;
  // Color
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // Count
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
      // .backgroundColor(this.color_current_primary)
      .constraintSize({ maxHeight: 92.5 + 48.5 * bunch_of_user_agents.list_of_user_agents.length })
      .animation(animation_default())
    }
  }
}

export default woofQuickUA;