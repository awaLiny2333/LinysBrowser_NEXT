import lazy { Context } from '@ohos.abilityAccessCtrl';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import lazy { pinShortcut } from '../../../catstypicalframework/utils/shortcuts';
import { unlinkFile } from '../../../catstypicalframework/utils/storage';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import lazy { domainOf } from '../../../catstypicalframework/utils/url';
import { openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';
import lazy { ALL_WINDOW_ORIENTATIONS, meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import lazy { AddressBarStatuses } from '../../../hosts/system/windows/scripts/addressBarStatuses';
import { defaultMooSymbolSize, fontSizeSymbol, getButtonIcon, meowThemeColorType, standardSpacing, UnifiedButtonsType } from '../../constants';
import { defaultAnimation, getColor, getMySettings, isTabsStyleVertical, useEffects } from '../../settings';
import { common } from '@kit.AbilityKit';

@ComponentV2
struct MeowButton {
  // Config
  @Param @Require type: string;
  // Hosts
  @Param @Require myUi: meowUiHost;

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
        })
        .onTouch((event: TouchEvent) => {
          if (this.type != UnifiedButtonsType.MOVE) {
            return;
          }
          // Drag
          if (event.type === TouchType.Down) {
            if (canIUse('SystemCapability.Window.SessionManager')) {
              this.myUi.windowObj?.startMoving().then(() => {
                meow('Succeeded in starting moving window', 'MeowButton');
              }).catch((err: BusinessError) => {
                meow(`Failed to start moving. Cause code: ${err.code}, message: ${err.message}`, 'MeowButton', meowLevel.ERROR);
              });
            }
          }
        });
    }
  }

  // Actions

  /**
   * Different things to happen after clicking the button.
   */
  async myClickAction() {
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
          if (this.myUi.showTabs) {
            // OFF => ON
            if (!this.myUi.myLayout.wideMode && this.myUi.showSidebar && isTabsStyleVertical(this.myUi)) {
              this.myUi.showSidebar = false;
              if (this.myUi.showTabs) {
                this.myUi.sideAreaShrinkExpect = false;
              }
            }
          } else {
            // ON => OFF
          }
        });
        getMySettings().setByIndex(22, this.myUi.showTabs);
        getMySettings().setByIndex(82, this.myUi.showSidebar);
        break;
      case UnifiedButtonsType.SIDEBAR:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.showSidebar = !this.myUi.showSidebar;
          if (this.myUi.showSidebar) {
            // OFF => ON
            if (!this.myUi.myLayout.wideMode && this.myUi.showTabs && isTabsStyleVertical(this.myUi)) {
              this.myUi.showTabs = false;
              if (this.myUi.showSidebar) {
                this.myUi.sideAreaShrinkExpect = false;
              }
            }
          } else {
            // ON => OFF
          }
        });
        getMySettings().setByIndex(22, this.myUi.showTabs);
        getMySettings().setByIndex(82, this.myUi.showSidebar);
        break;
      case UnifiedButtonsType.BOOKMARKS:
        requestDialog(this.myUi.myDialog, openDialogRequestType.BOOKMARKS);
        break;
      case UnifiedButtonsType.DOWNLOADS:
        requestDialog(this.myUi.myDialog, openDialogRequestType.DOWNLOADS);
        break;
      case UnifiedButtonsType.SETTINGS:
        requestDialog(this.myUi.myDialog, openDialogRequestType.SETTINGS);
        break;
      case UnifiedButtonsType.ADBLOCKER:
        requestDialog(this.myUi.myDialog, openDialogRequestType.ADBLOCKER, domainOf(this.myUi.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.JAVASCRIPTS:
        requestDialog(this.myUi.myDialog, openDialogRequestType.WEB_JAVASCRIPTS, domainOf(this.myUi.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.IMAGES:
        requestDialog(this.myUi.myDialog, openDialogRequestType.WEB_IMAGES, domainOf(this.myUi.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.DARK:
        requestDialog(this.myUi.myDialog, openDialogRequestType.DARK, domainOf(this.myUi.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.HISTORIES:
        requestDialog(this.myUi.myDialog, openDialogRequestType.HISTORY);
        break;
      case UnifiedButtonsType.COOKIES:
        requestDialog(this.myUi.myDialog, openDialogRequestType.COOKIES, domainOf(this.myUi.myTabs.currentTab?.url));
        break;
      case UnifiedButtonsType.QRCODE:
        requestDialog(this.myUi.myDialog, openDialogRequestType.QR, [this.myUi.myTabs.currentTab?.title || 'Title', this.myUi.myTabs.currentTab?.url || 'URL']);
        break;
      case UnifiedButtonsType.USERAGENTS:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myUi.myDialog, openDialogRequestType.QUICK_UA, this.myUi.myTabs.currentTab);
        break;
      case UnifiedButtonsType.RE_SEARCH:
        this.myUi.requestAddressBarBlur(this.getUIContext());
        requestDialog(this.myUi.myDialog, openDialogRequestType.QUICK_SE);
        break;
      case UnifiedButtonsType.GO:
        this.myUi.submitSearchOrLoad();
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
        this.myUi.requestHideAddressBarOverlay();
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
        this.myUi.requestHideAddressBarOverlay();
        break;
      case UnifiedButtonsType.SCRATCHING_BOARD:
        requestDialog(this.myUi.myDialog, openDialogRequestType.SCRATCHING_BOARD);
        break;
      case UnifiedButtonsType.BACKWARD:
        this.myUi.myTabs.goBackCurrent();
        break;
      case UnifiedButtonsType.FORWARD:
        this.myUi.myTabs.goForwardCurrent();
        break;
      case UnifiedButtonsType.REFRESH:
        this.myUi.myTabs.refreshStopCurrent();
        break;
      case UnifiedButtonsType.HOME:
        this.myUi.myTabs.goHomeCurrent();
        break;
      case UnifiedButtonsType.SEARCH_IN_PAGE:
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.inPageSearchShow = !this.myUi.inPageSearchShow;
        });
        break;
      case UnifiedButtonsType.PRINT:
        this.myUi.myTabs.printCurrent();
        break;
      case UnifiedButtonsType.SAVE:
        this.myUi.myTabs.saveCurrent();
        break;
      case UnifiedButtonsType.ZONES:
        requestDialog(this.myUi.myDialog, openDialogRequestType.ZONES);
        break;
      case UnifiedButtonsType.ZOOM_IN:
        this.myUi.myTabs.zoomInCurrent();
        break;
      case UnifiedButtonsType.ZOOM_OUT:
        this.myUi.myTabs.zoomOutCurrent();
        break;
      case UnifiedButtonsType.SHORTCUT:
        // Grab basic info.
        if (!this.myUi.myTabs.currentTab) return;
        const url = this.myUi.myTabs.currentTab.url;
        if (!url) return;
        let title = this.myUi.myTabs.currentTab.title || domainOf(url);

        // Grab icon path.
        const iconPath = await this.myUi.myTabs.currentTab.pathOfShortcutIcon(this.getUIContext().getHostContext() as Context);
        if (!iconPath) {
          meow(`!iconPath, what happened?`, 'MeowButton', meowLevel.ERROR);
          break;
        }

        // Add and clean.
        await pinShortcut(this.getUIContext().getHostContext() as common.UIAbilityContext, url, `󰊴 ${title || 'meow'}`, iconPath);
        await unlinkFile(iconPath);
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
        return this.myUi.myTabs.currentTab?.isLoading ? $r('sys.symbol.xmark') : getButtonIcon(this.type);
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
      case UnifiedButtonsType.ZOOM_IN:
        return (this.myUi.myTabs.currentTab?.webScale || 100) > 100;
      case UnifiedButtonsType.ZOOM_OUT:
        return (this.myUi.myTabs.currentTab?.webScale || 100) < 100;
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
        return this.myUi.myTabs.currentTabCanBack;
      case UnifiedButtonsType.FORWARD:
        return this.myUi.myTabs.currentTabCanForw;
      case UnifiedButtonsType.PRINT:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.USERAGENTS:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.SAVE:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.QRCODE:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.ZOOM_IN:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.ZOOM_OUT:
        return this.myUi.myTabs.currentTab != undefined;
      case UnifiedButtonsType.SHORTCUT:
        return this.myUi.myTabs.currentTab != undefined && !this.myUi.myTabs.currentTab?.fetchingShortcutIcon;
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
