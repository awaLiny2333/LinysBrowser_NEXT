import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { defaultAnimation } from '../../settings';
import { getButtonIcon, meowButtons } from './constants';

@ComponentV2
struct MeowButton {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
  @Param @Require type: meowButtons;

  build() {
    if (this.showMe()) {
      MooSymbolButton({
        icon: getButtonIcon(this.type),
        clickAction: () => {
          this.clickAction();
        },
        onHold: this.onHold(),
      });
    }
  }

  /**
   * Different things to happen after clicking the button.
   */
  clickAction() {
    // To be continued...
    switch (this.type) {
      case meowButtons.MORE:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showMore = !this.myUi.showMore;
        });
        break;
      case meowButtons.TABS:
        this.myUi.showTabs = !this.myUi.showTabs;
        break;
      case meowButtons.BOOKMARKS:
        requestDialog(this.myDialog, openDialogRequestType.BOOKMARKS);
        break;
      case meowButtons.DOWNLOADS:
        break;
      case meowButtons.SETTINGS:
        requestDialog(this.myDialog, openDialogRequestType.SETTINGS);
        break;
      case meowButtons.ADBLOCKER:
        requestDialog(this.myDialog, openDialogRequestType.ADBLOCKER);
        break;
      case meowButtons.JAVASCRIPTS:
        requestDialog(this.myDialog, openDialogRequestType.WEB_JAVASCRIPTS);
        break;
      case meowButtons.IMAGES:
        requestDialog(this.myDialog, openDialogRequestType.WEB_IMAGES);
        break;
      default:
        break;
    }
  }

  /**
   * Determines if this button is highlighted. (E.g. the Tabs button is highlighted if the tabs bar is being displayed)
   * @returns True, false or undefined.
   */
  onHold() {
    // To be continued...
    switch (this.type) {
      case meowButtons.MORE:
        return this.myUi.showMore;
      case meowButtons.TABS:
        return this.myUi.showTabs;
      default:
        return undefined;
    }
  }

  /**
   * Determines if this button should be displayed. (E.g. The Scratching Board button should only show up if it holds contents)
   * @returns True or false!
   */
  showMe() {
    return true;
  }
}

export { MeowButton };
