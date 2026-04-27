import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { standardSpacing } from '../../settings';
import { generalButtonHeight, meowButtons } from './constants';
import { MeowButton } from './MeowButton';

@ComponentV2
struct MeowButtonsSlot {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
  @Param @Require buttons: meowButtons[] = [];

  build() {
    List({ space: standardSpacing * 0.125 }) {
      Repeat(this.buttons)
        .each((item: RepeatItem<meowButtons>) => {
          ListItem() {
            MeowButton({
              myUi: this.myUi,
              myDialog: this.myDialog,
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
}

export { MeowButtonsSlot };
