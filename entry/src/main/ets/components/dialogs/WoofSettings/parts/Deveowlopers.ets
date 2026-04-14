import { meowUiStatuses } from '../../../../hosts/env/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../common/constants';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
import { bundleManager } from '@kit.AbilityKit';
import BuildProfile from 'BuildProfile';
import { requestDialog } from '../../../../hosts/env/scripts/dialog';
import { openDialogRequestType } from '../../../../hosts/env/classes/meowDialogManager';

@ComponentV2
struct SettingsDeveowlopers {
  // Hosts
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;
  // Information
  @Local versionName: string = "Version Name";
  @Local versionNo: number = 0;
  @Local buildTime: string = BuildProfile.LINYS_BUILD_TIME;

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
        MooCapsuleButton({
          text: $r('app.string.Settings_category_deveowlopers_openPanel'),
          clickAction: () => {
            requestDialog(openDialogRequestType.DEV, undefined, true);
          }
        });
      };
    };
  }
}

export { SettingsDeveowlopers };
