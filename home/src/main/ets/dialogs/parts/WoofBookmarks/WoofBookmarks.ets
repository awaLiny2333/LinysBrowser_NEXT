import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { MeowBookmarksPanel } from '../../../components/parts/Bookmarks/Panel';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import lazy { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
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
      myUi: this.myUi
    }) {
      MeowBookmarksPanel({
        myUi: this.myUi,
        selectMode: this.selectMode,
        requestVisit: (url: string) => {
          this.myUi.openNewTab(url);
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
