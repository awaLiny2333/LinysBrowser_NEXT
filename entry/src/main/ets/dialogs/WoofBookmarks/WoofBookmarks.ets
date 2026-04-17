import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import { meowDialogManager } from '../../hosts/env/classes/meowDialogManager';
import { meowUiStatuses } from '../../hosts/env/classes/meowUiStatuses';
import { MeowBookmarksPanel } from '../../components/parts/Bookmarks/MeowBookmarksPanel';
import { WoofUniFrame } from '../WoofUniFrame';
import lazy { meowBookmarkItem } from '../../hosts/bookmarks/classes/meowBookmarkItem';

@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;
  @Require selectMode: boolean;
  onSelect: (folder: meowBookmarkItem, path: string) => void = (folder, path) => {
    // Do nothing by default.
    meow(`Selected ${folder.name} at ${path}`, 'WoofBookmarksDialog][onSelect', meowLevel.INFO);
  };

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Bookmarks'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      MeowBookmarksPanel({
        myUi: this.myUi,
        selectMode: this.selectMode,
        requestVisit: (url: string) => {
          meow(`Visiting: ${url}`, 'WoofBookmarksDialog][requestVisit', meowLevel.INFO);
          this.controller.close();
        },
        onSelect: (folder, path) => {
          this.onSelect(folder, path);
          this.controller.close();
        }
      });
    };
  }
}

export { WoofBookmarksDialog };
