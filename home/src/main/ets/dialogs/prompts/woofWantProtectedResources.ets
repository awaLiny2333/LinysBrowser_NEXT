import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { click_effect_default } from '../../hosts/bunch_of_defaults';
import { desc_for_ProtectedResourceTypes, permissions_for_ProtectedResourceTypes, request_user_permission } from '../../utils/permission_tools';
import { common } from '@kit.AbilityKit';

@CustomDialog
struct woofWantResources {
  controller: CustomDialogController;
  @Prop protected_resource_types: string[] = [];
  @Prop source: string = 'source';
  onPermit?: () => void;
  onDeny?: () => void;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;
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
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.Permission_Manager_webpage_asks_for_permission'), max_lines: 3 })// This page is asking for a jump
        .width("100%")
      linysText({ text: this.source })

      Column({ space: 10 }) {
        ForEach(desc_for_ProtectedResourceTypes(this.protected_resource_types), ((desc: ResourceStr) => {
          linysText({
            text: desc,
            max_lines: 5
          })
            .padding(10)
            .borderRadius(13.5)
            .clickEffect(click_effect_default())
            .backgroundColor(this.color_current_secondary)
        }))
      }

      linysText({ text: $r('app.string.Permission_Manager_grant_permission') })// allow?
        .width("100%")

      linysConfirmDenyButtons({
        onConfirm: () => {
          request_user_permission(this.getUIContext().getHostContext() as common.UIAbilityContext,
            permissions_for_ProtectedResourceTypes(this.protected_resource_types));
          if (this.onPermit) {
            this.onPermit();
          }
          if (this.controller) {
            this.controller.close();
          }
        },
        onDeny: () => {
          if (this.onDeny) {
            this.onDeny();
          }
          if (this.controller) {
            this.controller.close();
          }
        }
      }) // Buttons
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.effects ? undefined : this.color_current_primary)
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
  }
}

export default woofWantResources;