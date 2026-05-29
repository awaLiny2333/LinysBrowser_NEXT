import BuildProfile from 'BuildProfile';
import { MeowLinks } from '../../../../catstypicalframework/utils/meow';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { mooTextType, standardSpacing } from '../../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../../components/settings';
import { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';

@ComponentV2
struct SettingsAbout {
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiHost;
  // Local
  @Local clickCount: number = 0;
  timeoutId: number | undefined = undefined;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_about'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_about'), icon: $r('sys.symbol.edit_badge_star') }) {
        Text(`${BuildProfile.VERSION_NAME} (${BuildProfile.VERSION_CODE}) [${BuildProfile.BUILD_MODE_NAME}]`).attributeModifier(new MooTextModifier(mooTextType.TITLE))
          .onClick(() => {
            // Turn on Deveowlopers Options
            this.clickCount++;
            if (this.clickCount == 7) {
              animateToImmediately(defaultAnimation(), () => {
                getMySettings().setByIndex(74, true);
              });
            }
            clearTimeout(this.timeoutId);
            this.timeoutId = setTimeout(() => {
              this.clickCount = 0;
            }, 2000);
          }); // Version info

        Text(`Built @ ${BuildProfile.LINYS_BUILD_TIME}`).attributeModifier(new MooTextModifier()).opacity(0.75); // Build time
        Text(`${BuildProfile.BUNDLE_NAME}`).attributeModifier(new MooTextModifier()).opacity(0.5); // Bundle name

        // Contacts
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_bilibili'),
          clickAction: () => {
            this.myUi.openUrlAuto(MeowLinks.BILI);
            this.myDialog.closeAll();
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_github'),
          clickAction: () => {
            this.myUi.openUrlAuto(MeowLinks.GITHUB);
            this.myDialog.closeAll();
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_gitee'),
          clickAction: () => {
            this.myUi.openUrlAuto(MeowLinks.GITEE);
            this.myDialog.closeAll();
          }
        });

        // Credits
        Text($r('app.string.Settings_category_about_thank')).attributeModifier(new MooTextModifier());
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_credits'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.CREDITS, undefined, true);
          }
        });
      };

      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_about_update'), icon: $r('sys.symbol.clock_arrow_2_circlepath') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_update_history'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.UPDATES, undefined, true);
          }
        });
      };
    };
  }
}

export { SettingsAbout };
