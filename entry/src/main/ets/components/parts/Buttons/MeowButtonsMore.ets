import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../../../catstypicalframework/hosts/meowAvoid';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { isPreferRightHand } from '../../settings';
import { meowButtonsType } from './constants';
import { MeowButtonsSlot } from './MeowButtonsSlot';

@ComponentV2
export struct MeowButtonsMore {
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myUi: meowUiStatuses;
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    MeowButtonsSlot({
      myDialog: this.myDialog,
      myUi: this.myUi,
      buttons: this.mySettings.settingsData[80].value as meowButtonsType[]
    })
      .alignSelf(isPreferRightHand() ? ItemAlign.End : ItemAlign.Start)
      .padding({ left: this.myAvoid.left, right: this.myAvoid.right });
  }
}