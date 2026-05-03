import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { allWindowOrientations, meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { defaultAnimation, getColor, meowThemeColorType } from '../../settings';
import { getButtonIcon, meowButtonsType } from './constants';

@ComponentV2
struct MeowButton {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
  @Param @Require type: meowButtonsType;
  // Local
  @Local showMenu: boolean = false;

  /**
   * Determines if this button should be displayed. (E.g. The Scratching Board button should only show up if it holds contents)
   * @returns True or false!
   */
  showMe() {
    return true;
  }

  build() {
    if (this.showMe()) {
      MooSymbolButton({
        icon: getButtonIcon(this.type),
        isEnabled: this.myEnabled(),
        clickAction: () => {
          this.myClickAction();
        },
        onHold: this.myOnHold(),
      })
        .bindMenu(this.showMenu, this.myMenu, {
          onWillDisappear: () => {
            this.showMenu = false;
          }
        });
    }
  }

  /**
   * Different things to happen after clicking the button.
   */
  myClickAction() {
    // To be continued...
    switch (this.type) {
      case meowButtonsType.MORE:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showMore = !this.myUi.showMore;
        });
        break;
      case meowButtonsType.TABS:
        this.myUi.showTabs = !this.myUi.showTabs;
        break;
      case meowButtonsType.BOOKMARKS:
        requestDialog(this.myDialog, openDialogRequestType.BOOKMARKS);
        break;
      case meowButtonsType.DOWNLOADS:
        break;
      case meowButtonsType.SETTINGS:
        requestDialog(this.myDialog, openDialogRequestType.SETTINGS);
        break;
      case meowButtonsType.ADBLOCKER:
        requestDialog(this.myDialog, openDialogRequestType.ADBLOCKER);
        break;
      case meowButtonsType.JAVASCRIPTS:
        requestDialog(this.myDialog, openDialogRequestType.WEB_JAVASCRIPTS);
        break;
      case meowButtonsType.IMAGES:
        requestDialog(this.myDialog, openDialogRequestType.WEB_IMAGES);
        break;
      case meowButtonsType.DARK:
        requestDialog(this.myDialog, openDialogRequestType.DARK);
        break;
      case meowButtonsType.HISTORY:
        requestDialog(this.myDialog, openDialogRequestType.HISTORY);
        break;
      case meowButtonsType.COOKIES:
        requestDialog(this.myDialog, openDialogRequestType.COOKIES, 'meow.url'); // TODO: auto pass in current viewing url.
        break;
      case meowButtonsType.QRCODE:
        requestDialog(this.myDialog, openDialogRequestType.QR, ['Title', 'meow.url']); // TODO: auto pass in current viewing url.
        break;
      case meowButtonsType.ORIENTATION:
        this.showMenu = !this.showMenu;
        break;
      case meowButtonsType.FULLSCREEN:
        this.showMenu = !this.showMenu;
        break;
      default:
        break;
    }
  }

  /**
   * Determines if this button is highlighted. (E.g. the Tabs button is highlighted if the tabs bar is being displayed)
   * @returns True, false or undefined.
   */
  myOnHold() {
    // To be continued...
    switch (this.type) {
      case meowButtonsType.MORE:
        return this.myUi.showMore;
      case meowButtonsType.TABS:
        return this.myUi.showTabs;
      default:
        return undefined;
    }
  }

  /**
   * Determines if current button is enabled.
   * @returns True or false.
   */
  myEnabled() {
    switch (this.type) {
      case meowButtonsType.EXTENSIONS:
        return false;
      default:
        return true;
    }
  }

  /**
   * The general menu.
   */
  @Builder
  myMenu() {
    if (this.type == meowButtonsType.ORIENTATION) {
      Menu() {
        Repeat(allWindowOrientations).each((ori) => {
          MenuItem({
            content: $r('app.string.Orientation_select_'.concat(ori.index.toString())),
          })
            .onClick(() => {
              this.myUi.setOrientation(ori.item);
            })
            .backgroundColor(ori.item == this.myUi.orientation ? getColor(meowThemeColorType.SECONDARY) : undefined);
        });
      }
      .fontColor(getColor(meowThemeColorType.FONT))
      .backgroundColor(getColor(meowThemeColorType.PRIMARY));

    } else if (this.type == meowButtonsType.FULLSCREEN) {
      Menu() {
        MenuItem({
          content: $r('app.string.Fullscreen_full'),
        })
          .onClick(() => {
            this.myUi.fullscreenFull();
            // FULL fullscreen
          });
        MenuItem({
          content: $r('app.string.Fullscreen_windowed'),
        })
          .onClick(() => {
            this.myUi.fullscreenWindowed();
            // Windowed fullscreen
          });
      }
      .fontColor(getColor(meowThemeColorType.FONT))
      .backgroundColor(getColor(meowThemeColorType.PRIMARY));
    }
  }
}

export { MeowButton };
