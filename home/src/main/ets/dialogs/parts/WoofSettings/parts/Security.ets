import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { mooTextType, standardSpacing } from '../../../../components/constants';
import { getMySettings } from '../../../../components/settings';
import { openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';
import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';

@ComponentV2
struct SettingsSecurity {
  @Param @Require myUi: meowUiHost;
  @Local mySettings: meowManagedSettings = getMySettings();

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
            requestDialog(this.myUi.myDialog, openDialogRequestType.COOKIES, undefined, true); // Go with no params.
          }
        });
      };
    };
  }
}

export { SettingsSecurity };
