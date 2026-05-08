import { AppStorageV2 } from '@kit.ArkUI';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { standardSpacing } from '../../settings';
import { MeowButton } from './MeowButton';

@Builder
export function MeowButtonsSlot(
  myUi: meowUiHost,
  myDialog: meowDialogManager,
  buttons: number
) {
  Scroll() {
    Row({ space: standardSpacing * 0.125 }) {
      Repeat(AppStorageV2.connect(meowManagedSettings)!.settingsData[buttons].value as string[])
        .each((item: RepeatItem<string>) => {
          MeowButton({
            myUi: myUi,
            myDialog: myDialog,
            type: item.item
          });
        });
    };
  }
  .scrollBar(BarState.Off);
}
