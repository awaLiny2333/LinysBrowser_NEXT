import { DownloadsPanel } from '../../../components/parts/Downloads/Panel';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
export struct WoofDownloadsDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, shiftBackgroundColor: true, title: $r('app.string.Downloads_title'), myUi: this.myUi }) {
      DownloadsPanel();
    };
  }
}
