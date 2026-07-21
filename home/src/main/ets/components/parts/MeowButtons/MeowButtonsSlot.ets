import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { standardSpacing } from '../../constants';
import { meowButtonsOfSlot } from '../../settings';
import { MeowButton } from './MeowButton';

@Builder
export function MeowButtonsSlot(myUi: meowUiHost, buttonsSlotId: number) {
  Scroll() {
    Row({ space: standardSpacing * 0.125 }) {
      Repeat(meowButtonsOfSlot(buttonsSlotId))
        .each((item: RepeatItem<string>) => {
          MeowButton({ myUi: myUi, type: item.item });
        });
    };
  }
  .clip(false)
  .scrollBar(BarState.Off);
}
