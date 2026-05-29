import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { ScratchingBoardPanel } from '../../../components/parts/ScratchingBoard/Panel';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
export struct WoofScratchingBoardDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true,
      title: $r('app.string.ScratchingBoard_drop'),
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      ScratchingBoardPanel({
        myUi: this.myUi,
        onSearchSubmitOrLoad: () => {
          this.controller.close();
        }
      });
    };
  }
}
