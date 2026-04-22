import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../../components/settings';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';

@ComponentV2
struct SettingsSecurity {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

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
          isOn: this.mySettings.settingsData[33].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(33, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_security_cookies_thirdPartyCookies'),
          isOn: this.mySettings.settingsData[34].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(34, r);
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
