import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import lazy { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import lazy { defaultDecorHeight, defaultInnerRadius, shortModeThreshold, updateNavigationIndicator, wideModeThreshold } from '../catstypicalframework/utils/ui';
import lazy { MooTextModifier } from '../components/common/MooTextModifier';
import lazy { MeowButtonsMore } from '../components/parts/Buttons/MeowButtonsMore';
import lazy { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import lazy { MeowSearchBar } from '../components/parts/Homepage/MeowSearchBar';
import lazy { MeowTitleBarHeight, MeowTitleBar } from '../components/parts/Homepage/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/Homepage/MeowTitleTop';
import lazy { isTabsStyleVertical, defaultAnimation, defaultHorizontalTabsHeight, defaultSidebarWidth, getColor, meowThemeColorType, mooTextType, showGiganticWindowTitle, sidebarShouldBeOnTheRight, standardSpacing, titleBarPositionBottom, useEffects } from '../components/settings';
import lazy { showingSidebar } from '../components/statuses';
import lazy { MeowShortcutsPanel } from '../components/parts/Homepage/MeowShortcuts';
import { meowManagedSettings } from '../hosts/userdata/settings/classes/meowManagedSettings';
import { meowDialogManager, openDialogRequestType } from '../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../hosts/system/dialogs/scripts/dialog';
import { meowResources } from '../hosts/system/storage/classes/meowResources';
import { meowAppStatuses } from '../hosts/system/windows/classes/meowAppStatuses';
import { meowUiGoBackSource, meowUiStatuses } from '../hosts/system/windows/classes/meowUiStatuses';
import { getLastWindowId } from '../hosts/system/windows/scripts/multiwindows';
import { MeowPlaceForKeyShortcuts } from '../components/parts/MeowPlaceForKeyShortcuts';
import { meowAppMessageType } from '../hosts/system/windows/scripts/messaging';

@Entry
@ComponentV2
struct Index {
  @Local myWindowId: string = getLastWindowId(); // To know who I am!
  // Hosts (public)
  @Local myResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // Should be initialized by flows.
  // Hosts (private)
  @Local myUi: meowUiStatuses = AppStorageV2.connect(meowUiStatuses, `meowUiStatuses_${this.myWindowId}`)!;
  @Local myDialog: meowDialogManager = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myWindowId}`)!;
  // catsTypicalFramework (private)
  @Local myLayout: meowLayout = AppStorageV2.connect(meowLayout, `meowLayout_${this.myWindowId}`)!;
  @Local myAvoid: meowAvoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${this.myWindowId}`)!;
  @Local myMisc: meowMisc = AppStorageV2.connect(meowMisc, `meowMisc_${this.myWindowId}`)!;
  // Render control
  @Local render: boolean = false;

  /**
   * Things that would happen when the user presses the back button.
   * @returns Whether the back button was handled.
   */
  onBackPress(): boolean | void {
    return this.myUi.goBackUni(meowUiGoBackSource.BACK);
  }

  build() {
    RelativeContainer() {
      if (this.render) {
        // Dialog handler
        MeowPlaceForDialogs({
          myDialog: this.myDialog,
          myLayout: this.myLayout,
          myAvoid: this.myAvoid,
          myUi: this.myUi,
          myMisc: this.myMisc
        });

        // Shortcuts handler
        MeowPlaceForKeyShortcuts({
          myUi: this.myUi
        });

        // Main
        // This is ugly.
        Column() {
          Stack() {
            // Backdrop
            if (this.myResources.backgroundImage) {
              Image(this.myResources.backgroundImage)
                .opacity(useEffects() ? 0.5 : 1)
                .grayscale(useEffects() ? 1 : 0)
                .animation(defaultAnimation());
            }
            // Shortcuts
            MeowShortcutsPanel({
              myLayout: this.myLayout
            })
              .onClick(() => {
                requestDialog(this.myDialog, openDialogRequestType.HOMEPAGE);
              });
          }
          .border(useEffects() ? { radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') } : { width: 0, radius: 0 })
          .backgroundColor(getColor(meowThemeColorType.PRIMARY))
          .clip(true)
          .width('100%')
          .height('100%');
        }
        .padding(this.mainFrameMargin())
        .animation(defaultAnimation());

        MeowTitleTop({
          myAvoid: this.myAvoid,
          myLayout: this.myLayout,
          myDialog: this.myDialog,
          myUi: this.myUi
        });

        // Top
        if (!titleBarPositionBottom()) {
          Column({ space: standardSpacing }) {
            MeowTitleBar({
              myUi: this.myUi,
              myAvoid: this.myAvoid,
              myLayout: this.myLayout,
              myDialog: this.myDialog,
            });
            if (!this.myLayout.wideMode) {
              MeowSearchBar({
                needFullPadding: true,
                myUi: this.myUi,
                myDialog: this.myDialog,
                myAvoid: this.myAvoid,
              });
            }
            if (this.myUi.showMore) {
              MeowButtonsMore({
                myUi: this.myUi,
                myAvoid: this.myAvoid,
                myDialog: this.myDialog
              });
            }
          }
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .backgroundColor(getColor(meowThemeColorType.SECONDARY))
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .translate({ y: this.myLayout.freeWindow ? defaultDecorHeight : this.myAvoid.top })
          .padding(!titleBarPositionBottom() ? { bottom: standardSpacing } : 0)
          .width('100%');
        }

        // Bottom
        if (titleBarPositionBottom()) {
          Column({ space: standardSpacing }) {
            if (this.myUi.showMore) {
              MeowButtonsMore({
                myUi: this.myUi,
                myAvoid: this.myAvoid,
                myDialog: this.myDialog
              });
            }
            MeowTitleBar({
              myUi: this.myUi,
              myAvoid: this.myAvoid,
              myLayout: this.myLayout,
              myDialog: this.myDialog,
            });
            if (!this.myLayout.wideMode) {
              MeowSearchBar({
                needFullPadding: true,
                myUi: this.myUi,
                myDialog: this.myDialog,
                myAvoid: this.myAvoid,
              });
            }
          }
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .backgroundColor(getColor(meowThemeColorType.SECONDARY))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .translate({ y: (titleBarPositionBottom() || useEffects() ? -this.myAvoid.bottom - (this.myLayout.freeWindow ? standardSpacing : 0) : 0) }) // Bottom avoid.
          .padding(titleBarPositionBottom() ? { top: standardSpacing } : 0)
          .width('100%');
        }

        // Gigantic window title
        if (showGiganticWindowTitle(this.myLayout)) {
          Text(this.myUi.windowAlias)
            .attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .fontSize(128)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Center)
            .textVerticalAlign(TextVerticalAlign.CENTER)
            .opacity(0.5);
        }
      }
    } // Base
    .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
    .backgroundColor(getColor(meowThemeColorType.SECONDARY))
    .height('100%')
    .width('100%')
    .onAppear(() => {
      this.actionsOnAppear();
    })
    .onAreaChange((o, n) => {
      let somethingChanged = false;
      if (o.width != n.width) {
        somethingChanged = true;
        this.myLayout.width = n.width as number;
        animateToImmediately(defaultAnimation(), () => {
          this.myLayout.wideMode = this.myLayout.width > wideModeThreshold;
        });
      }
      if (o.height != n.height) {
        somethingChanged = true;
        this.myLayout.height = n.height as number;
        animateToImmediately(defaultAnimation(), () => {
          this.myLayout.shortMode = this.myLayout.height < shortModeThreshold;
        });
      }

      // If window resize then disable focus.
      if (somethingChanged) {
        if (this.myUi.searchBarFocused) {
          this.getUIContext().getFocusController().clearFocus();
          animateToImmediately(defaultAnimation(), () => {
            this.myUi.searchBarFocused = false;
          });
        }
      }
    });
  }

  // Actions

  actionsOnAppear() {
    this.myMisc.launchEndTime = Date.now();
    meow(`---`, 'Index][launch', meowLevel.INFO);
    meow(`Successfully launched the app. (${Date.now() - this.myMisc.launchStartTime} ms)`, 'Index][launch', meowLevel.INFO);
    meow(`Window ID: ${this.myUi.windowId}`, 'Index][launch', meowLevel.INFO);
    meow(`---`, 'Index][launch', meowLevel.INFO);
    setTimeout(() => {
      this.render = true;
    }, 1);
  }

  // Values

  mainFrameMargin(): Margin {
    // Vertical
    const slimCompensation = this.myLayout.wideMode ? 0 : MeowTitleBarHeight + standardSpacing; // For double layer title bar on phones / slim windows.
    const tabsHorizontalCompensation = this.myUi.showTabs && !isTabsStyleVertical(this.myLayout) ? defaultHorizontalTabsHeight : 0;

    let top: number;
    let bottom: number;
    if (titleBarPositionBottom()) {
      // Bottom
      const freeWindowCompensation = (this.myLayout.freeWindow ? standardSpacing : 0);
      top = this.myAvoid.top;
      bottom = this.myAvoid.bottom + freeWindowCompensation + (MeowTitleBarHeight + standardSpacing) + slimCompensation + tabsHorizontalCompensation;
    } else {
      // Top
      top = this.myAvoid.top + (MeowTitleBarHeight + standardSpacing) + slimCompensation + tabsHorizontalCompensation;
      const showBottomAvoid = this.mySettings.settingsData[5].value as boolean; // Allow user to disable bottom avoid.
      bottom = (showBottomAvoid ? this.myAvoid.bottom : 0) + (useEffects() ? standardSpacing : 0);
    }

    // Horizontal
    const sidebarOnR = sidebarShouldBeOnTheRight();
    const sidebarCompensation = showingSidebar(this.myUi, this.myLayout) ? defaultSidebarWidth : 0;
    const sidebarCompL = sidebarOnR ? 0 : sidebarCompensation;
    const sidebarCompR = sidebarOnR ? sidebarCompensation : 0;

    let left: number;
    let right: number;
    if (useEffects()) {
      left = this.myAvoid.left + sidebarCompL;
      right = this.myAvoid.right + sidebarCompR;
    } else {
      left = 0 + sidebarCompL;
      right = 0 + sidebarCompR;
    }
    return { top, bottom, left, right };
  }

  /**
   * Updates the display of navigation indicator on receiving the broadcast message.
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msg = this.myApp.crossAppMessageTunnel!;
    if (msg.type == meowAppMessageType.SETTINGS_NAV_INDICATOR_UPDATE) {
      updateNavigationIndicator(this.myUi.windowObj!);
    }
  }
}
