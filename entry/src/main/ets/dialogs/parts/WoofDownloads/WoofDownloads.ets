import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { DownloadsPanel } from '../../../components/parts/Downloads/Panel';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
export struct WoofDownloadsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true,
      title: $r('app.string.Downloads_title'),
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      DownloadsPanel();
    };
  }
}
