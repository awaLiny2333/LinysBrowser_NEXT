import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { resource2String } from '../../../catstypicalframework/utils/resource';
import { HistoryPanel } from '../../../components/parts/History/Panel';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

/**
 * We have to wrap another @ComponentV2 component in order to refresh the title... :P
 * Theoratically this brings almost no performance loss!
 */
@ComponentV2
struct HistoryPanelWrapped {
  @Param @Require controller: CustomDialogController;
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;
  // Local
  @Local info: string = 'meow';

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true,
      title: `${resource2String($r('app.string.History'), this.getUIContext().getHostContext()!)} ${this.info}`,
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      HistoryPanel({
        myLayout: this.myLayout,
        requestRefreshTitle: (info: string) => {
          this.info = info;
        },
        requestVisit: (url: string) => {
          // Visit
          this.myUi.openNewTab(url);
          this.controller.close();
        }
      });
    };
  }
}

@CustomDialog
struct WoofHistoryDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiHost;

  build() {
    HistoryPanelWrapped({
      controller: this.controller,
      myDialog: this.myDialog,
      myLayout: this.myLayout,
      myUi: this.myUi,
    });
  }
}

export { WoofHistoryDialog };
