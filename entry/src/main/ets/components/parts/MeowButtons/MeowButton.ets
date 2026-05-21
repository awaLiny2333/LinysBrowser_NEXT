import { AppStorageV2 } from '@kit.ArkUI';
import { meow } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
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
  @Param myTab: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;

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
        break;
      case UnifiedButtonsType.SETTINGS:
        requestDialog(this.myDialog, openDialogRequestType.SETTINGS);
        break;
      case UnifiedButtonsType.ADBLOCKER:
        requestDialog(this.myDialog, openDialogRequestType.ADBLOCKER);
        break;
      case UnifiedButtonsType.JAVASCRIPTS:
        requestDialog(this.myDialog, openDialogRequestType.WEB_JAVASCRIPTS);
        break;
      case UnifiedButtonsType.IMAGES:
        requestDialog(this.myDialog, openDialogRequestType.WEB_IMAGES);
        break;
      case UnifiedButtonsType.DARK:
        requestDialog(this.myDialog, openDialogRequestType.DARK);
        break;
      case UnifiedButtonsType.HISTORIES:
        requestDialog(this.myDialog, openDialogRequestType.HISTORY);
        break;
      case UnifiedButtonsType.COOKIES:
        requestDialog(this.myDialog, openDialogRequestType.COOKIES, this.myUi.addressBarContentMajor); // TODO: auto pass in current viewing url.
        break;
      case UnifiedButtonsType.QRCODE:
        requestDialog(this.myDialog, openDialogRequestType.QR, ['Title', this.myUi.addressBarContentMajor]); // TODO: auto pass in current viewing url.
        break;
      case UnifiedButtonsType.USERAGENTS:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_UA, this.myTab.currentTab); // TODO: pass in current web's UA.
        break;
      case UnifiedButtonsType.RE_SEARCH:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myDialog, openDialogRequestType.QUICK_SE, 0); // TODO: pass in current web's search engine.
        break;
      case UnifiedButtonsType.GO:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        meow(`Visit / load [${this.myUi.addressBarContentMajor}]!`);
        // TODO: Visit the site for GO button!
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
        this.myTab.goBackCurrent();
        break;
      case UnifiedButtonsType.FORWARD:
        this.myTab.goForwardCurrent();
        break;
      case UnifiedButtonsType.REFRESH:
        this.myTab.refreshCurrent();
        break;
      case UnifiedButtonsType.HOME:
        this.myTab.goHomeCurrent();
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
    .fontColor(getColor(meowThemeColorType.FONT))
    .backgroundColor(getColor(meowThemeColorType.PRIMARY));
  }
}

export { MeowButton };
