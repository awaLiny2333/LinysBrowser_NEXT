import { meow } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { allWindowOrientations, meowUiHost, SidebarContentsStatus } from '../../../hosts/system/windows/classes/meowUiHost';
import { AddressBarStatuses } from '../../../hosts/system/windows/scripts/addressBarStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { defaultAnimation, fontSizeSymbol, getColor, meowThemeColorType, useEffects, standardSpacing } from '../../settings';
import { getButtonIcon, meowButtonsType } from './constants';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
struct MeowButton {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiHost;
  @Param @Require type: meowButtonsType;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    if (this.showMe) {
      // We write a SymbolGlyph instead of using the existing MooSymbolButton because we need the bindMenu to work, but we don't want extra __common__ layers on the custom components.
      SymbolGlyph(this.myIcon)
        .opacity(this.myEnabled ? 1 : 0.4)
        .enabled(this.myEnabled)
        .margin(this.myOnHold ? { left: standardSpacing / 4, right: standardSpacing / 4 } : 0)
        .brightness(this.myOnHold && useEffects() ? 1.1 : 1)
        .backgroundColor(this.myOnHold && !useEffects() ? getColor(meowThemeColorType.FONT) : Color.Transparent)
        .animation(defaultAnimation())
        .padding(3.5)
        .borderRadius(defaultInnerRadius)
        .fontSize(fontSizeSymbol)
        .hoverEffect(HoverEffect.Highlight)
        .onClick(() => {
          this.myClickAction();
        })
        .fontColor([this.myOnHold && !useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.FONT)])
        .bindMenu(this.hasMenu ? this.myMenu : undefined);
    }
  }

  // Actions

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
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showTabs = !this.myUi.showTabs;
        });
        this.mySettings.setByIndex(22, this.myUi.showTabs);
        break;
      case meowButtonsType.SIDEBAR:
        animateToImmediately(defaultAnimation(), () => {
          if (this.myUi.sidebarStatus == SidebarContentsStatus.HIDDEN) {
            this.myUi.sidebarStatus = SidebarContentsStatus.NONE;
          } else {
            this.myUi.sidebarStatus = SidebarContentsStatus.HIDDEN;
          }
        });
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
        requestDialog(this.myDialog, openDialogRequestType.COOKIES, this.myUi.addressBarContent); // TODO: auto pass in current viewing url.
        break;
      case meowButtonsType.QRCODE:
        requestDialog(this.myDialog, openDialogRequestType.QR, ['Title', this.myUi.addressBarContent]); // TODO: auto pass in current viewing url.
        break;
      case meowButtonsType.USERAGENTS:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_UA, 0); // TODO: pass in current web's UA.
        break;
      case meowButtonsType.RE_SEARCH:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_SE, 0); // TODO: pass in current web's search engine.
        break;
      case meowButtonsType.GO:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        meow(`Visit / load [${this.myUi.addressBarContent}]!`);
        // TODO: Visit the site for GO button!
        break;
      case meowButtonsType.ADDRESS_KEYWORD_SWITCH:
        const needFocus = this.myUi.addressBarFocused;
        animateToImmediately(defaultAnimation(), () => {
          if (this.myUi.addressBarStatus == AddressBarStatuses.CAN_SHIFT) {
            this.myUi.addressBarStatus = AddressBarStatuses.SHIFTED;
          } else if (this.myUi.addressBarStatus == AddressBarStatuses.SHIFTED) {
            this.myUi.addressBarStatus = AddressBarStatuses.CAN_SHIFT;
          }
        });
        if (needFocus) {
          this.myUi.requestAddressBarFocus(this.getUIContext());
        }
        break;
      case meowButtonsType.ADDRESS_KEYWORD_EXPAND:
        const needFocus2 = this.myUi.addressBarFocused;
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.searchKeywordEntriesExpanded = !this.myUi.searchKeywordEntriesExpanded;
        });
        if (needFocus2) {
          this.myUi.requestAddressBarFocus(this.getUIContext());
        }
        break;
      default:
        break;
    }
  }

  // Getters

  /**
   * Determines if this button should be displayed. (E.g. The Scratching Board button should only show up if it holds contents)
   * @returns True or false!
   */
  // @Computed
  get showMe() {
    switch (this.type) {
      case meowButtonsType.ADDRESS_KEYWORD_SWITCH:
        return this.myUi.searchKeywordEntries.length > 0;
      case meowButtonsType.ADDRESS_KEYWORD_EXPAND:
        return this.myUi.addressBarStatus == AddressBarStatuses.SHIFTED;
      default:
        return true;
    }
  }

  /**
   * Gets my icon.
   * @returns The Icon (Resource)
   */
  // @Computed
  get myIcon() {
    switch (this.type) {
      case meowButtonsType.ADDRESS_KEYWORD_SWITCH:
        return this.myUi.addressBarStatus == AddressBarStatuses.SHIFTED ? $r('sys.symbol.text_and_t') : getButtonIcon(this.type);
      case meowButtonsType.ADDRESS_KEYWORD_EXPAND:
        return this.myUi.searchKeywordEntriesExpanded ? $r('sys.symbol.line') : getButtonIcon(this.type);
      default:
        return getButtonIcon(this.type);
    }
  }

  /**
   * Determines if this button is highlighted. (E.g. the Tabs button is highlighted if the tabs bar is being displayed)
   * @returns True, false or undefined.
   */
  // @Computed
  get myOnHold() {
    // To be continued...
    switch (this.type) {
      case meowButtonsType.MORE:
        return this.myUi.showMore;
      case meowButtonsType.TABS:
        return this.myUi.showTabs;
      case meowButtonsType.SIDEBAR:
        return this.myUi.sidebarStatus != SidebarContentsStatus.HIDDEN;
      case meowButtonsType.ADDRESS_KEYWORD_SWITCH:
        return true;
      default:
        return undefined;
    }
  }

  /**
   * Determines if current button is enabled.
   * @returns True or false.
   */
  // @Computed
  get myEnabled() {
    switch (this.type) {
      case meowButtonsType.EXTENSIONS:
        return false;
      default:
        return true;
    }
  }

  /**
   * Determines if current button has a menu.
   */
  get hasMenu() {
    return this.type == meowButtonsType.ORIENTATION || this.type == meowButtonsType.FULLSCREEN;
  }

  // Builders

  /**
   * The general menu.
   */
  @Builder
  myMenu() {
    Menu() {
      if (this.type == meowButtonsType.ORIENTATION) {
        Repeat(allWindowOrientations).each((ori) => {
          MenuItem({
            content: $r('app.string.Orientation_select_'.concat(ori.index.toString())),
          })
            .onClick(() => {
              this.myUi.setOrientation(ori.item);
            })
            .backgroundColor(ori.item == this.myUi.orientation ? getColor(meowThemeColorType.SECONDARY) : undefined);
        });
      } else if (this.type == meowButtonsType.FULLSCREEN) {
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
    }
    .fontColor(getColor(meowThemeColorType.FONT))
    .backgroundColor(getColor(meowThemeColorType.PRIMARY));
  }
}

export { MeowButton };
