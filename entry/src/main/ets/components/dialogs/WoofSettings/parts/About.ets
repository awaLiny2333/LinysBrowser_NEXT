import { meowUiStatuses } from '../../../../hosts/env/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
import BuildProfile from 'BuildProfile';

@ComponentV2
struct SettingsAbout {
  // Hosts
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_about'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_about'), icon: $r('sys.symbol.edit_badge_star') }) {
        Text(`${BuildProfile.VERSION_NAME} (${BuildProfile.VERSION_CODE}) [${BuildProfile.BUILD_MODE_NAME}]`).attributeModifier(new MooTextModifier(mooTextType.TITLE)); // Version info
        Text(`Built @ ${BuildProfile.LINYS_BUILD_TIME}`).attributeModifier(new MooTextModifier()).opacity(0.75); // Build time
        Text(`${BuildProfile.BUNDLE_NAME}`).attributeModifier(new MooTextModifier()).opacity(0.5); // Bundle name
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_bilibili'),
          clickAction: () => {
            // TODO: Site Bilibili entrance.
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_github'),
          clickAction: () => {
            // TODO: Site Github entrance.
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_site_gitee'),
          clickAction: () => {
            // TODO: Site Gitee entrance.
          }
        });
      };
      
      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_about_update'), icon: $r('sys.symbol.clock_arrow_2_circlepath') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_about_update_history'),
          clickAction: () => {
            // TODO: Update history entrance.
          }
        });
      };
    };
  }
}

export { SettingsAbout };
