import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { AppStorageV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { defaultAnimation, mooTextType, standardSpacing } from '../../../../components/settings';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { MooTabSegmentV2 } from '../../../../components/common/MooTabSegmentV2';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';

@ComponentV2
struct SettingsAccessibility {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Param @Require myDialog: meowDialogManager;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_accessibility'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Back
      UniContentCard() {
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_webBack'),
          isOn: this.mySettings.settingsData[10].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(10, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_webEsc'),
          isOn: this.mySettings.settingsData[11].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(11, r);
          }
        });
      };

      // Single hand
      UniContentCard({ title: $r('app.string.Settings_category_accessibility_singleHand'), icon: $r('sys.symbol.phone_and_hand') }) {
        MooTabSegmentV2({
          initSelected: this.selectedOptionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '←' }, { text: '→' },]),
          onSelected: (index) => {
            // 'left' | 'right'
            switch (index) {
              case 0:
                this.mySettings.setByIndex(47, 'left');
                break;
              case 1:
                this.mySettings.setByIndex(47, 'right');
                break;
              default:
                break;
            }
          }
        }).opacity(this.mySettings.settingsData[51].value as boolean ? 0.5 : 1).animation(defaultAnimation());
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_smartReachability'),
          isOn: this.mySettings.settingsData[51].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(51, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseSideMenus'),
          isOn: this.mySettings.settingsData[48].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(48, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseSideBars'),
          isOn: this.mySettings.settingsData[49].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(49, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseHomeShortcuts'),
          isOn: this.mySettings.settingsData[50].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(50, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_accessibility_keyShortcuts'), icon: $r('sys.symbol.keyboard') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_accessibility_keyShortcuts_manage'),
          clickAction: () => {
            // TODO: key shortcuts manage entrance.
            requestDialog(this.myDialog, openDialogRequestType.KEY_SHORTCUTS, undefined, true);
          }
        });
      };
    };
  }

  selectedOptionFromSettings() {
    const value = this.mySettings.settingsData[47].value as string;
    const seq = ['left', 'right'];
    return seq.indexOf(value);
  }
}
export { SettingsAccessibility };