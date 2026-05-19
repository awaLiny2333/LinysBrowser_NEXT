import { meowTabsBunch } from '../../../hosts/app/tabs/classes/meowTabsBunch';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { standardSpacing } from '../../constants';
import { meowButtonsOfSlot } from '../../settings';
import { MeowButton } from './MeowButton';

@Builder
export function MeowButtonsSlot(
  myUi: meowUiHost,
  myDialog: meowDialogManager,
  buttonsSlotId: number
) {
  Scroll() {
    Row({ space: standardSpacing * 0.125 }) {
      Repeat(meowButtonsOfSlot(buttonsSlotId))
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
