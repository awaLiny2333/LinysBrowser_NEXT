import { AppStorageV2 } from '@kit.ArkUI';
import { meowHistorian } from '../../../../hosts/userdata/history/classes/meowHistorian';
import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../../components/constants';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { getMySettings } from '../../../../components/settings';

@ComponentV2
struct SettingsHistory {
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = getMySettings();
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
          isOn: this.mySettings.settingsData[69].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(69, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_history'), icon: $r('sys.symbol.arrow_counterclockwise_clock') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_history_view'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.HISTORY, undefined, true);
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
        //   value: this.mySettings.settingsData[71].value as number,
        //   min: 0,
        //   max: 24,
        //   step: 1,
        //   onChange: (r) => {
        //     this.mySettings.setByIndex(71, r);
        //   }
        // });
      };
    };
  }
}

export { SettingsHistory };
