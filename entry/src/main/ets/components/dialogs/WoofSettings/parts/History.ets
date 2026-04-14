import { AppStorageV2 } from '@kit.ArkUI';
import { meowHistorian } from '../../../../hosts/history/classes/meowHistorian';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../settings';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
// import { MooSlider } from '../../../common/MooSlider';
import { MooSwitch } from '../../../common/MooSwitch';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';

@ComponentV2
struct SettingsHistory {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect(meowHistorian)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_history'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      UniContentCard() {
        MooSwitch({
          text: $r('app.string.Settings_category_history_recordNew'),
          isOn: this.myMeowManagedSettings.settingsData[69].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(69, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_history'), icon: $r('sys.symbol.arrow_counterclockwise_clock') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_history_view'),
          clickAction: () => {
            // TODO: view history entrance
          }
        });
        MooCapsuleButton({
          text: this.myMeowHistorian.isRebuilding ? $r('app.string.Settings_category_history_indexing') : $r('app.string.Settings_category_history_indexNow'),
          needDoubleConfirm: true,
          clickAction: () => {
            this.myMeowHistorian.rebuildIndex();
          },
          isEnabled: !this.myMeowHistorian.busy
        });
        // Text($r('app.string.Settings_category_history_indexLoadQuantity')).attributeModifier(new MooTextModifier());
        // MooSlider({
        //   value: this.myMeowManagedSettings.settingsData[71].value as number,
        //   min: 0,
        //   max: 24,
        //   step: 1,
        //   onChange: (r) => {
        //     this.myMeowManagedSettings.setByIndex(71, r);
        //   }
        // });
      };
    };
  }
}

export { SettingsHistory };
