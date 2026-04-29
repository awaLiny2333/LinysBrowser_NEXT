import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { WoofUniFrame } from '../../WoofUniFrame';
import { WoofHistoryPanel } from './parts/Panel';

@CustomDialog
struct WoofHistoryDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  onSelect: (folder: meowBookmarkItem, path: string) => void = (folder, path) => {
    // Do nothing by default.
    meow(`Selected ${folder.name} at ${path}`, 'WoofHistoryDialog][onSelect', meowLevel.INFO);
  };

  build() {
    WoofUniFrame({
      controller: this.controller,
      shiftBackgroundColor: true,
      title: $r('app.string.History'),
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      WoofHistoryPanel({ myLayout: this.myLayout });
    };
  }
}

export { WoofHistoryDialog };
