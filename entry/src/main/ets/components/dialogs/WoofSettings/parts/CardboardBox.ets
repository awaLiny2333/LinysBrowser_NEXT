import { meowUiStatuses } from '../../../../hosts/env/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { MooSwitch } from '../../../common/MooSwitch';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';

@ComponentV2
struct SettingsCardboardBox {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_cardboardBox'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_cardboardBox_debug'), icon: $r('sys.symbol.pawprint') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_cardboardBox_debug_resourceMonitor'),
          isOn: this.myMeowManagedSettings.settingsData[75].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(75, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_cardboardBox_debug_faultLogs'),
          clickAction: () => {
            // TODO: Fault logs display entrance.
          }
        });
      };

      // Backup
      UniContentCard({ title: $r('app.string.Settings_category_cardboardBox_backup'), icon: $r('sys.symbol.save') }) {
        // Settings
        Text($r('app.string.Settings_category_cardboardBox_backup_settings_desc')).attributeModifier(new MooTextModifier());
        MooCapsuleButton({
          text: $r('app.string.Settings_category_cardboardBox_backup_settings_export'),
          clickAction: () => {
            // TODO: Backup settings entrance.
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_cardboardBox_backup_settings_import'),
          needDoubleConfirm: true,
          clickAction: () => {
            // TODO: Import settings entrance.
          }
        });
        
        // Everything
        Text($r('app.string.Settings_category_cardboardBox_backup_everything_desc')).attributeModifier(new MooTextModifier());
        MooCapsuleButton({
          text: $r('app.string.Settings_category_cardboardBox_backup_everything_export'),
          clickAction: () => {
            // TODO: Backup everything entrance.
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_cardboardBox_backup_everything_import'),
          needDoubleConfirm: true,
          clickAction: () => {
            // TODO: Backup everything entrance.
          }
        });
      };
    };
  }
}

export { SettingsCardboardBox };
