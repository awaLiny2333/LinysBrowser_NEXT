import { resource2String } from '../../../catstypicalframework/utils/resource';
import { HistoryPanel } from '../../../components/parts/History/Panel';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

/**
 * We have to wrap another @ComponentV2 component in order to refresh the title... :P
 * Theoratically this brings almost no performance loss!
 */
@ComponentV2
struct HistoryPanelWrapped {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Local
  @Local info: string = 'meow';

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true,
      title: `${resource2String($r('app.string.History'), this.getUIContext().getHostContext()!)} ${this.info}`,
      myUi: this.myUi
    }) {
      HistoryPanel({
        myUi: this.myUi,
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
  @Require myUi: meowUiHost;

  build() {
    HistoryPanelWrapped({ controller: this.controller, myUi: this.myUi });
  }
}

export { WoofHistoryDialog };
