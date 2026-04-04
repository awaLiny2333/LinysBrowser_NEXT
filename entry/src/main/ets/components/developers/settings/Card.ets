import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { UniContentCard } from '../common/UniContentCard';
import { SimpleSettingsExamples } from './SimpleSettingsExamples';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';

/**
 * Settings status and control examples.
 */
@ComponentV2
struct SettingsDevCard {
  // Environment
  context: Context = this.getUIContext().getHostContext()!;
  // App
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect<meowManagedSettings>(meowManagedSettings)!; // Should be initialized by flows.

  build() {
    UniContentCard({ title: 'meowManagedSettings' }) {
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(5), cross: LengthMetrics.vp(8) } }) {
        Text(`[Ready] ${this.myMeowManagedSettings.ready ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[${this.myMeowManagedSettings.settingsFileSavePath}]`);
        Text(`[timeoutIdSaveToDisk] ${this.myMeowManagedSettings.timeoutIdSaveToDisk}`);
      }; // Statuses

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        Button('(Re) Load from Disk')
          .onClick(() => {
            this.myMeowManagedSettings?.initFrom(`${this.context.filesDir}/settings.json.browsercatsettings.txt`);
          });
        Button('Save Instantly')
          .onClick(() => {
            this.myMeowManagedSettings.requestSaveToDisk(0);
          });
        Button('Save Through Request in 500 ms')
          .onClick(() => {
            this.myMeowManagedSettings.requestSaveToDisk();
          });
      }; // Load and save buttons

      TextArea({ text: `${this.myMeowManagedSettings.prebuiltReadOnly}` }).height(200).border({ radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') }); // Settings file

      SimpleSettingsExamples();
    }; // Settings
  }
}

export { SettingsDevCard };