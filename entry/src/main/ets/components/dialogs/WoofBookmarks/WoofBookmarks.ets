import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { MeowBookmarksPanel } from '../../parts/Bookmarks/MeowBookmarksPanel';
import { WoofUniFrame } from '../common/WoofUniFrame';

@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Bookmarks'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      MeowBookmarksPanel({ controller: this.controller });
    };
  }
}

export { WoofBookmarksDialog };
