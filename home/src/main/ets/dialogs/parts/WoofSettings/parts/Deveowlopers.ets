import { bundleManager } from '@kit.AbilityKit';
import BuildProfile from 'BuildProfile';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooSwitch } from '../../../../components/common/MooSwitch';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { standardSpacing,mooTextType } from '../../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../../components/settings';
import lazy { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';

@ComponentV2
struct SettingsDeveowlopers {
  // Hosts
  @Local mySettings: meowManagedSettings = getMySettings();
  @Param @Require myDialog: meowDialogManager;
  // Information
  @Local versionName: string = "Version Name";
  @Local versionNo: number = 0;
  @Local buildTime: string = BuildProfile.LINYS_BUILD_TIME;
  // Local
  timeoutToTurnOff: number | undefined = undefined;

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    });
  }

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_deveowlopers'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Debug
      UniContentCard({ title: $r('app.string.Settings_category_deveowlopers'), icon: $r('sys.symbol.figure_fishing') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_deveowlopers_on'),
          isOn: this.mySettings.settingsData[74].value as boolean,
          onChange: (r) => {
            clearTimeout(this.timeoutToTurnOff);
            this.timeoutToTurnOff = setTimeout(() => {
              animateToImmediately(defaultAnimation(), () => {
                this.mySettings.setByIndex(74, r);
              });
            }, 1000);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_deveowlopers_openPanel'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.DEV, undefined, true);
          }
        });
        MooCapsuleButton({
          text: 'JS Crash  󰃴',
          clickAction: () => {
            JSON.parse('');
          }
        });
      };
    };
  }
}

export { SettingsDeveowlopers };
