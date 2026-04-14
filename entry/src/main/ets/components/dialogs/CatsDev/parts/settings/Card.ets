import { defaultInnerRadius } from '../../../../../catstypicalframework/utils/ui';
import { UniContentCard } from '../../../../common/UniContentCard';
import { SimpleSettingsExamples } from './SimpleSettingsExamples';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../../../hosts/settings/classes/meowManagedSettings';
import { meowFlexOptions } from '../../../../settings';

/**
 * Settings status and control examples.
 */
@ComponentV2
struct SettingsDevCard {
  // Environment
  context: Context = this.getUIContext().getHostContext()!;
  // App
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // Should be initialized by flows.

  build() {
    UniContentCard({ title: 'meowManagedSettings' }) {
      Flex(meowFlexOptions) {
        Text(`[Ready] ${this.mySettings.ready ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[settingsFileSavePath] ${this.mySettings.settingsFileSavePath}`);
        Text(`[timeoutIdSaveToDisk] ${this.mySettings.timeoutIdSaveToDisk}`);
      }; // Statuses

      Flex(meowFlexOptions) {
        Button('(Re) Load from Disk')
          .onClick(() => {
            this.mySettings?.initFrom(`${this.context.filesDir}/settings.json.browsercatsettings.txt`);
          });
        Button('Save Instantly')
          .onClick(() => {
            this.mySettings.requestSaveToDisk(0);
          });
        Button('Save Through Request in 500 ms')
          .onClick(() => {
            this.mySettings.requestSaveToDisk();
          });
      }; // Load and save buttons

      TextArea({ text: `${this.mySettings.prebuiltReadOnly}` }).height(200).border({ radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') }); // Settings file

      SimpleSettingsExamples();
    }; // Settings
  }
}

export { SettingsDevCard };