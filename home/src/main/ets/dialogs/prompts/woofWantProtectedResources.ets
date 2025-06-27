import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { desc_for_ProtectedResourceTypes, permissions_for_ProtectedResourceTypes, request_user_permission } from '../../utils/permission_tools';

@CustomDialog
struct woofWantResources {
  controller: CustomDialogController;
  @Prop protected_resource_types: string[] = [];
  onPermit?: () => void;
  onDeny?: () => void;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI display
  @StorageLink('screen_height') screen_height: number = 0;

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.Permission_Manager_webpage_asks_for_permission') })// This page is asking for a jump
        .width("100%")

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
      Row({ space: 10 }) {
        linysCapsuleButton({ text: "  󰁖  " })// Cancel
          .onClick(() => {
            if (this.onDeny) {
              this.onDeny();
            }
            if (this.controller) {
              this.controller.close();
            }
          })
        linysCapsuleButton({ text: "  󰀓  " })// Submit
          .onClick(() => {
            request_user_permission(permissions_for_ProtectedResourceTypes(this.protected_resource_types));
            if (this.onPermit) {
              this.onPermit();
            }
            if (this.controller) {
              this.controller.close();
            }
          })
      }
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .width('100%')
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }
}

export default woofWantResources;