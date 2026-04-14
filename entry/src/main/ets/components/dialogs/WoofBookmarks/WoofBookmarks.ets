import { meowBookmarkStash } from '../../../hosts/bookmarks/classes/meowBookmarkStash';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { WoofUniFrame } from '../common/WoofUniFrame';

/**
 * Be the most convenient bookmark manager in the industry!!! :O
 */
@ComponentV2
struct WoofBookmarks {
  @Local mySettings: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;

  build() {

  }
}


@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Bookmarks'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WoofBookmarks();
    };
  }
}

export { WoofBookmarksDialog };
