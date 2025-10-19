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
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI display
  @LocalStorageLink('screen_height') screen_height: number = 0;

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
    .backgroundColor(this.color_current_primary)
  }
}

export default woofWantResources;