import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { resource2String } from '../../../catstypicalframework/utils/resource';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofUniFrame } from '../../WoofUniFrame';
import { HistoryPanel } from '../../../components/parts/History/Panel';

/**
 * We have to wrap another @ComponentV2 component in order to refresh the title... :P
 * Theoratically this brings almost no performance loss!
 */
@ComponentV2
struct HistoryPanelWrapped {
  @Param @Require controller: CustomDialogController;
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
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
          meow(`Visit: [${url}]`, 'HistoryPanel', meowLevel.INFO);
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

  build() {
    HistoryPanelWrapped({
      controller: this.controller,
      myDialog: this.myDialog,
      myLayout: this.myLayout,
    });
  }
}

export { WoofHistoryDialog };
