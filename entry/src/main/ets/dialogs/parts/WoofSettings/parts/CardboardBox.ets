import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../../components/settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { exportEverything, exportSettings, importEverything, importResult, importSettings } from '../../../../hosts/system/storage/scripts/backup';
import { meowUiStatuses } from '../../../../hosts/system/windows/classes/meowUiStatuses';
import { ErrorPromptDetails } from '../../../public/WoofErrorPrompt/errorPromptScripts';

@ComponentV2
struct SettingsCardboardBox {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
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
            requestDialog(this.myDialog, openDialogRequestType.FAULTLOGS, undefined, true);
          }
        });
      };

      // Backup
      UniContentCard({ title: $r('app.string.Settings_category_cardboardBox_backup'), icon: $r('sys.symbol.save') }) {
        // Settings
        Text($r('app.string.Settings_category_cardboardBox_backup_settings_desc')).attributeModifier(new MooTextModifier());
        MooCapsuleButton({
          text: this.myUi.isExportingData ? $r('app.string.General_wait') : $r('app.string.Settings_category_cardboardBox_backup_settings_export'),
          isEnabled: !this.myUi.isExportingData,
          clickAction: async () => {
            this.myUi.isExportingData = true;
            await exportSettings();
            this.myUi.isExportingData = false;
          }
        });
        MooCapsuleButton({
          text: this.myUi.isExportingData ? $r('app.string.General_wait') : $r('app.string.Settings_category_cardboardBox_backup_settings_import'),
          isEnabled: !this.myUi.isExportingData,
          needDoubleConfirm: true,
          clickAction: async () => {
            this.myUi.isExportingData = true;
            const result = await importSettings();
            this.myUi.isExportingData = false;

            switch (result) {
              case (importResult.OK):
                requestDialog(this.myDialog, openDialogRequestType.ERROR_PROMPT, {
                  isError: false,
                  title: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok'),
                  contents: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok_desc'),
                  additional: ['ヽ（´ー｀）┌']
                } as ErrorPromptDetails, true);
              case (importResult.PICK_FAIL):
                break;
              default:
                requestDialog(this.myDialog, openDialogRequestType.ERROR_PROMPT, {
                  isError: true,
                  title: $r('app.string.Settings_category_cardboardBox_backup_import_result_fail'),
                  contents: $r('app.string.Settings_category_cardboardBox_backup_import_result_fail_decode'),
                  additional: ['／(=∵=)＼']
                } as ErrorPromptDetails, true);
            }
          }
        });

        // Everything
        Text($r('app.string.Settings_category_cardboardBox_backup_everything_desc')).attributeModifier(new MooTextModifier());
        MooCapsuleButton({
          text: this.myUi.isExportingData ? $r('app.string.General_wait') : $r('app.string.Settings_category_cardboardBox_backup_everything_export'),
          isEnabled: !this.myUi.isExportingData,
          clickAction: async () => {
            this.myUi.isExportingData = true;
            await exportEverything(this.getUIContext().getHostContext()!);
            this.myUi.isExportingData = false;
          }
        });
        MooCapsuleButton({
          text: this.myUi.isExportingData ? $r('app.string.General_wait') : $r('app.string.Settings_category_cardboardBox_backup_everything_import'),
          isEnabled: !this.myUi.isExportingData,
          needDoubleConfirm: true,
          clickAction: async () => {
            this.myUi.isExportingData = true;
            const result = await importEverything(this.getUIContext().getHostContext()!);
            this.myUi.isExportingData = false;

            // Build status list of files and folders:
            const FOLDER_ICON = '󰃅';
            const FILE_ICON = '󰂼';
            const OK_PREFIX = '󰀓 ';
            const FAIL_PREFIX = '󰁖 ';
            const okString = [
              ...result.importedDirs.map(d => `${OK_PREFIX}${FOLDER_ICON} ${d}`),
              ...result.importedFiles.map(f => `${OK_PREFIX}${FILE_ICON} ${f}`)
            ].join('\n');
            const failString = [
              ...result.failedDirs.map(d => `${FAIL_PREFIX}${FOLDER_ICON} ${d}`),
              ...result.failedFiles.map(f => `${FAIL_PREFIX}${FILE_ICON} ${f}`)
            ].join('\n');

            // Result.
            switch (result.result) {
              case importResult.OK:
                requestDialog(this.myDialog, openDialogRequestType.ERROR_PROMPT, {
                  isError: false,
                  title: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok'),
                  contents: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok_desc'),
                  additional: ['ヽ（´ー｀）┌', okString]
                } as ErrorPromptDetails, true);
                break;
              case importResult.PARTIAL_OK:
                requestDialog(this.myDialog, openDialogRequestType.ERROR_PROMPT, {
                  isError: true,
                  title: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok_partial'),
                  contents: $r('app.string.Settings_category_cardboardBox_backup_import_result_ok_partial_desc'),
                  additional: [okString, failString]
                } as ErrorPromptDetails, true);
                break;
              case importResult.EXTRACT_FAIL:
                requestDialog(this.myDialog, openDialogRequestType.ERROR_PROMPT, {
                  isError: true,
                  title: $r('app.string.Settings_category_cardboardBox_backup_import_result_fail'),
                  contents: $r('app.string.Settings_category_cardboardBox_backup_import_result_fail_extract'),
                  additional: [failString]
                } as ErrorPromptDetails, true);
                break;
              case importResult.PARTIAL_OK:
                // Do nothing. The user may selected nothing.
                break;
            }
          }
        });
      };
    };
  }
}

export { SettingsCardboardBox };
