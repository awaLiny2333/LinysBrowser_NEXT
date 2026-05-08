import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { MeowBookmarksPanel } from '../../../components/parts/Bookmarks/Panel';
import { WoofUniFrame } from '../../WoofUniFrame';
import lazy { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';

@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiHost;
  @Require selectMode: boolean;
  onSelect: (folder: meowBookmarkItem, path: string) => void = (folder, path) => {
    // Do nothing by default.
    meow(`Selected ${folder.title} at ${path}`, 'WoofBookmarksDialog][onSelect', meowLevel.INFO);
  };

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true, 
      title: this.selectMode ? $r('app.string.Bookmarks_selectFolder') : $r('app.string.Bookmarks'), 
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
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
