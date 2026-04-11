import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { AppStorageV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { defaultAnimation, mooTextType, standardSpacing } from '../../../common/constants';
import { MooSwitch } from '../../../common/MooSwitch';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { MooTabSegmentV2 } from '../../../common/MooTabSegmentV2';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
import { resource2String } from '../../../../catstypicalframework/utils/resource';

@ComponentV2
struct SettingsAccessibility {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
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
          isOn: this.myMeowManagedSettings.settingsData[10].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(10, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_webEsc'),
          isOn: this.myMeowManagedSettings.settingsData[11].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(11, r);
          }
        });
      };

      // Single hand
      UniContentCard({ title: $r('app.string.Settings_category_accessibility_singleHand') }) {
        MooTabSegmentV2({
          initSelected: this.selectedOptionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '←' }, { text: '→' },]),
          onSelected: (index) => {
            // 'left' | 'right'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(47, 'left');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(47, 'right');
                break;
              default:
                break;
            }
          }
        }).opacity(this.myMeowManagedSettings.settingsData[51].value as boolean ? 0.5 : 1).animation(defaultAnimation());
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_smartReachability'),
          isOn: this.myMeowManagedSettings.settingsData[51].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(51, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseSideMenus'),
          isOn: this.myMeowManagedSettings.settingsData[48].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(48, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseSideBars'),
          isOn: this.myMeowManagedSettings.settingsData[49].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(49, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_accessibility_singleHand_reverseHomeShortcuts'),
          isOn: this.myMeowManagedSettings.settingsData[50].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(50, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_accessibility_keyShortcuts') }) {
        MooCapsuleButton({
          text: `${resource2String($r('app.string.Settings_category_accessibility_keyShortcuts_manage'), this.getUIContext().getHostContext()!)}  󰌐`,
          clickAction: () => {
            // TODO: key shortcuts manage entrance.
          }
        });
      };
    };
  }

  selectedOptionFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[47].value as string;
    const seq = ['left', 'right'];
    return seq.indexOf(value);
  }
}
export { SettingsAccessibility };