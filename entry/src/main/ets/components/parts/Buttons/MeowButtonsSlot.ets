import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { standardSpacing } from '../../settings';
import { generalButtonHeight, meowButtonsType } from './constants';
import { MeowButton } from './MeowButton';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MeowButtonsSlot(
  myUi: meowUiStatuses,
  myDialog: meowDialogManager,
  buttons: number
) {
  List({ space: standardSpacing * 0.125 }) {
    Repeat(AppStorageV2.connect(meowManagedSettings)!.settingsData[buttons].value as meowButtonsType[])
      .each((item: RepeatItem<meowButtonsType>) => {
        ListItem() {
          MeowButton({
            myUi: myUi,
            myDialog: myDialog,
            type: item.item
          });
        };
      });
  }
  .scrollBar(BarState.Off)
  .width('auto')
  .height(generalButtonHeight)
  .listDirection(Axis.Horizontal);
}
