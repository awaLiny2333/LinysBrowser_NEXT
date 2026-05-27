import { AppStorageV2 } from '@kit.ArkUI';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import lazy { domainOf } from '../../../catstypicalframework/utils/url';
import { meowTabsBunch } from '../../../hosts/app/tabs/classes/meowTabsBunch';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import { ALL_WINDOW_ORIENTATIONS, meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { AddressBarStatuses } from '../../../hosts/system/windows/scripts/addressBarStatuses';
import { defaultMooSymbolSize, fontSizeSymbol, getButtonIcon, meowThemeColorType, standardSpacing, UnifiedButtonsType } from '../../constants';
import { defaultAnimation, getColor, getMySettings, useEffects } from '../../settings';

@ComponentV2
struct MeowButton {
  // Config
  @Param @Require type: string;
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiHost;
  @Param myTabs: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;

  build() {
    if (this.showMe) {
      // We write a SymbolGlyph instead of using the existing MooSymbolButton because we need the bindMenu to work, but we don't want extra __common__ layers on the custom components.
      SymbolGlyph(this.myIcon)
        .width(defaultMooSymbolSize)
        .height(defaultMooSymbolSize)
        .align(Alignment.Center)
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
        .bindMenu(this.hasMenu ? this.myMenu : undefined, {
          backgroundColor: useEffects() ? Color.Transparent : getColor(meowThemeColorType.PRIMARY),
          backgroundBlurStyle: useEffects() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
        });
    }
  }

  // Actions

  /**
   * Different things to happen after clicking the button.
   */
  myClickAction() {
    // To be continued...
    switch (this.type) {
      case UnifiedButtonsType.MORE:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showMore = !this.myUi.showMore;
        });
        break;
      case UnifiedButtonsType.TABS:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showTabs = !this.myUi.showTabs;
        });
        getMySettings().setByIndex(22, this.myUi.showTabs);
        break;
      case UnifiedButtonsType.SIDEBAR:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showSidebar = !this.myUi.showSidebar;
        });
        getMySettings().setByIndex(82, this.myUi.showSidebar);
        break;
      case UnifiedButtonsType.BOOKMARKS:
        requestDialog(this.myDialog, openDialogRequestType.BOOKMARKS);
        break;
      case UnifiedButtonsType.DOWNLOADS:
        requestDialog(this.myDialog, openDialogRequestType.DOWNLOADS);
        break;
      case UnifiedButtonsType.SETTINGS:
        requestDialog(this.myDialog, openDialogRequestType.SETTINGS);
        break;
      case UnifiedButtonsType.ADBLOCKER:
        requestDialog(this.myDialog, openDialogRequestType.ADBLOCKER, domainOf(this.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.JAVASCRIPTS:
        requestDialog(this.myDialog, openDialogRequestType.WEB_JAVASCRIPTS, domainOf(this.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.IMAGES:
        requestDialog(this.myDialog, openDialogRequestType.WEB_IMAGES, domainOf(this.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.DARK:
        requestDialog(this.myDialog, openDialogRequestType.DARK, domainOf(this.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.HISTORIES:
        requestDialog(this.myDialog, openDialogRequestType.HISTORY);
        break;
      case UnifiedButtonsType.COOKIES:
        requestDialog(this.myDialog, openDialogRequestType.COOKIES, domainOf(this.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.QRCODE:
        requestDialog(this.myDialog, openDialogRequestType.QR, [this.myTabs.currentTab?.title || 'Title', this.myTabs.currentTab?.url || 'URL']);
        break;
      case UnifiedButtonsType.USERAGENTS:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_UA, this.myTabs.currentTab);
        break;
      case UnifiedButtonsType.RE_SEARCH:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_SE);
        break;
      case UnifiedButtonsType.GO:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        break;
      case UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH:
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
      case UnifiedButtonsType.ADDRESS_KEYWORD_EXPAND:
        const needFocus2 = this.myUi.addressBarFocused;
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.searchKeywordEntriesExpanded = !this.myUi.searchKeywordEntriesExpanded;
        });
        if (needFocus2) {
          this.myUi.requestAddressBarFocus(this.getUIContext());
          this.myUi.setCurrentFieldContent(this.myUi.searchKeywordEntries[0][1]); // Or the last input field of keywords would set this, as its onChange callback would be triggered.
        }
        break;
      case UnifiedButtonsType.SCRATCHING_BOARD:
        requestDialog(this.myDialog, openDialogRequestType.SCRATCHING_BOARD);
        break;
      case UnifiedButtonsType.BACKWARD:
        this.myTabs.goBackCurrent();
        break;
      case UnifiedButtonsType.FORWARD:
        this.myTabs.goForwardCurrent();
        break;
      case UnifiedButtonsType.REFRESH:
        this.myTabs.refreshStopCurrent();
        break;
      case UnifiedButtonsType.HOME:
        this.myTabs.goHomeCurrent();
        break;
      case UnifiedButtonsType.SEARCH_IN_PAGE:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.inPageSearchShow = !this.myUi.inPageSearchShow;
        });
        break;
      case UnifiedButtonsType.PRINT:
        this.myTabs.printCurrent();
        break;
      case UnifiedButtonsType.SAVE:
        this.myTabs.saveCurrent();
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
      case UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH:
        return this.myUi.searchKeywordEntries.length > 0;
      case UnifiedButtonsType.ADDRESS_KEYWORD_EXPAND:
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
      case UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH:
        return this.myUi.addressBarStatus == AddressBarStatuses.SHIFTED ? $r('sys.symbol.text_and_t') : getButtonIcon(this.type);
      case UnifiedButtonsType.ADDRESS_KEYWORD_EXPAND:
        return this.myUi.searchKeywordEntriesExpanded ? $r('sys.symbol.line') : getButtonIcon(this.type);
      case UnifiedButtonsType.REFRESH:
        return this.myTabs.currentTab?.isLoading ? $r('sys.symbol.xmark') : getButtonIcon(this.type);
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
      case UnifiedButtonsType.MORE:
        return this.myUi.showMore;
      case UnifiedButtonsType.TABS:
        return this.myUi.showTabs;
      case UnifiedButtonsType.SIDEBAR:
        return this.myUi.showSidebar;
      case UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH:
        return true;
      case UnifiedButtonsType.SEARCH_IN_PAGE:
        return this.myUi.inPageSearchShow;
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
      case UnifiedButtonsType.EXTENSIONS:
        return false;
      case UnifiedButtonsType.BACKWARD:
        return this.myTabs.currentTabCanBack;
      case UnifiedButtonsType.FORWARD:
        return this.myTabs.currentTabCanForw;
      case UnifiedButtonsType.PRINT:
        return this.myTabs.currentTab != undefined;
      case UnifiedButtonsType.USERAGENTS:
        return this.myTabs.currentTab != undefined;
      case UnifiedButtonsType.SAVE:
        return this.myTabs.currentTab != undefined;
      case UnifiedButtonsType.QRCODE:
        return this.myTabs.currentTab != undefined;
      default:
        return true;
    }
  }

  /**
   * Determines if current button has a menu.
   */
  get hasMenu() {
    return this.type == UnifiedButtonsType.ORIENTATION || this.type == UnifiedButtonsType.FULLSCREEN;
  }

  // Builders

  /**
   * The general menu.
   */
  @Builder
  myMenu() {
    Menu() {
      if (this.type == UnifiedButtonsType.ORIENTATION) {
        Repeat(ALL_WINDOW_ORIENTATIONS).each((ori) => {
          MenuItem({
            content: $r('app.string.Orientation_select_'.concat(ori.index.toString())),
          })
            .onClick(() => {
              this.myUi.setOrientation(ori.item);
            })
            .backgroundColor(ori.item == this.myUi.orientation ? getColor(meowThemeColorType.SECONDARY) : undefined);
        });
      } else if (this.type == UnifiedButtonsType.FULLSCREEN) {
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
    .fontColor(getColor(meowThemeColorType.FONT));
  }
}

export { MeowButton };
