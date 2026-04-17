import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../components/settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../components/common/UniContentCard';
import { MooSwitch } from '../../../components/common/MooSwitch';
import { MooCapsuleButton } from '../../../components/common/MooCapsuleButton';

@ComponentV2
struct SettingsCardboardBox {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

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
          isOn: this.mySettings.settingsData[75].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(75, r);
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
