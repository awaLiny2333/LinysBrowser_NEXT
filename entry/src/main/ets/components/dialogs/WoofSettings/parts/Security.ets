import { meowUiStatuses } from '../../../../hosts/env/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../common/constants';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { MooSwitch } from '../../../common/MooSwitch';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';

@ComponentV2
struct SettingsSecurity {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_security'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      UniContentCard({ title: $r('app.string.Settings_category_security_cookies'), icon: $r('sys.symbol.tracking_cookie_interception') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_security_cookies_intelligentTrackingPrevention'),
          isOn: this.myMeowManagedSettings.settingsData[33].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(33, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_security_cookies_thirdPartyCookies'),
          isOn: this.myMeowManagedSettings.settingsData[34].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(34, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_security_cookies_viewManage'),
          clickAction: () => {
            // TODO: Cookies manager entrance.
          }
        });
      };
    };
  }
}

export { SettingsSecurity };
