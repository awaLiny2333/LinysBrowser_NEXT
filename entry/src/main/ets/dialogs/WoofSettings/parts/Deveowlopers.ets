import { bundleManager } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import BuildProfile from 'BuildProfile';
import { MooCapsuleButton } from '../../../components/common/MooCapsuleButton';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../components/common/UniContentCard';
import { mooTextType, standardSpacing } from '../../../components/settings';
import { meowManagedSettings } from '../../../hosts/data/settings/classes/meowManagedSettings';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';

@ComponentV2
struct SettingsDeveowlopers {
  // Hosts
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Param @Require myDialog: meowDialogManager;
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
            requestDialog(this.myDialog, openDialogRequestType.DEV, undefined, true);
          }
        });
      };
    };
  }
}

export { SettingsDeveowlopers };
