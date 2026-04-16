import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/env/classes/meowUiStatuses';
import { MeowBookmarksPanel } from '../../parts/Bookmarks/MeowBookmarksPanel';
import { WoofUniFrame } from '../common/WoofUniFrame';

@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Bookmarks'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      MeowBookmarksPanel({
        myUi: this.myUi,
        requestVisit: (url: string) => {
          meow(`Visiting: ${url}`, 'WoofBookmarksDialog][requestVisit', meowLevel.INFO);
          this.controller.close();
        }
      });
    };
  }
}

export { WoofBookmarksDialog };
