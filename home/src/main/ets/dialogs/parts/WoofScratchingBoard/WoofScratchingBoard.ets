import { ScratchingBoardPanel } from '../../../components/parts/ScratchingBoard/Panel';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
export struct WoofScratchingBoardDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, shiftBackgroundColor: true, title: $r('app.string.ScratchingBoard_drop'), myUi: this.myUi }) {
      ScratchingBoardPanel({
        myUi: this.myUi,
        onSearchSubmitOrLoad: () => {
          this.controller.close();
        }
      });
    };
  }
}
