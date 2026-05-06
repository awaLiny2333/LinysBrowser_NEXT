import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import lazy { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import lazy { defaultDecorHeight, defaultInnerRadius, shortModeThreshold, updateNavigationIndicator, wideModeThreshold } from '../catstypicalframework/utils/ui';
import lazy { MooTextModifier } from '../components/common/MooTextModifier';
import { meowButtonsType } from '../components/parts/Buttons/constants';
import { MeowButtonsSlot } from '../components/parts/Buttons/MeowButtonsSlot';
import { MeowDestination } from '../components/parts/Homepage/MeowDestination';
import { MeowResMonitor } from '../components/parts/Homepage/MeowResMonitor';
import lazy { MeowAddressBar } from '../components/parts/Homepage/MeowAddressBar';
import lazy { MeowShortcutsPanel } from '../components/parts/Homepage/MeowShortcuts';
import lazy { MeowTitleBar, MeowTitleBarHeight } from '../components/parts/Homepage/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/Homepage/MeowTitleTop';
import { MeowWindowInfoBar } from '../components/parts/Homepage/MeowWindowInfoBar';
import lazy { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import { MeowPlaceForKeyShortcuts } from '../components/parts/MeowPlaceForKeyShortcuts';
import lazy { defaultAnimation, defaultHorizontalTabsHeight, defaultSidebarWidth, getColor, isPreferRightHand, isTabsStyleVertical, meowThemeColorType, mooTextType, showGiganticWindowTitle, sidebarShouldBeOnTheRight, standardSpacing, titleBarPositionBottom, useEffects } from '../components/settings';
import lazy { showingSidebar } from '../components/statuses';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';
import { meowResources } from '../hosts/system/storage/classes/meowResources';
import { meowAppStatuses } from '../hosts/system/windows/classes/meowAppStatuses';
import { meowUiFullscreenStatus, meowUiGoBackSource, meowUiHost } from '../hosts/system/windows/classes/meowUiHost';
import { meowAppMessageType } from '../hosts/system/windows/scripts/messaging';
import { getLastWindowId } from '../hosts/system/windows/scripts/multiwindows';
import { meowManagedSettings } from '../hosts/userdata/settings/classes/meowManagedSettings';

@Entry
@ComponentV2
struct Index {
  @Local myWindowId: string = getLastWindowId(); // To know who I am!
  // Hosts (public)
  @Local myResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // Should be initialized by flows.
  // Hosts (private)
  @Local myUi: meowUiHost = AppStorageV2.connect(meowUiHost, `meowUiHost_${this.myWindowId}`)!;
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
    return this.myUi.goBackUni(meowUiGoBackSource.BACK, this.getUIContext());
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
        MeowPlaceForKeyShortcuts(this.myDialog, this.myUi, this.getUIContext());

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
            MeowShortcutsPanel({ myLayout: this.myLayout, myDialog: this.myDialog });
          }
          .border(useEffects() ? { radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') } : { width: 0, radius: 0 })
          .backgroundColor(getColor(meowThemeColorType.PRIMARY))
          .clip(true)
          .width('100%')
          .height('100%');
        }
        .padding(this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE ? this.mainFrameSpace : 0)
        .animation(defaultAnimation());

        if (this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE) {
          // Top bar
          MeowTitleTop(this.myLayout, this.myDialog, this.myUi, this.myApp, this.getUIContext());

          // Title bar
          Scroll() {
            Column({ space: standardSpacing }) {
              // Title bar
              MeowTitleBar(this.myUi, this.myLayout, this.myDialog, this.mySettings);

              if (this.myUi.addressBarFocused && titleBarPositionBottom()) {
                MeowDestination(this.myUi, this.getUIContext());
              }

              // Address
              if (!this.myLayout.wideMode) {
                MeowAddressBar({
                  myUi: this.myUi,
                  myLayout: this.myLayout,
                  myDialog: this.myDialog,
                });
              }

              if (this.myUi.addressBarFocused && !titleBarPositionBottom()) {
                MeowDestination(this.myUi, this.getUIContext());
              }

              // More
              if (this.myUi.showMore) {
                // Meow buttons
                if ((this.mySettings.settingsData[80].value as meowButtonsType[]).length > 0) {
                  MeowButtonsSlot(this.myUi, this.myDialog, 80);
                }
                // Majorly the window alias
                MeowWindowInfoBar({
                  myUi: this.myUi,
                });
                // Resource monitor
                if (this.mySettings.settingsData[75].value as boolean) {
                  MeowResMonitor();
                }
              }
            }
            .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
            .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
            .backgroundColor(getColor(meowThemeColorType.SECONDARY))
            .padding(!titleBarPositionBottom() ? { bottom: standardSpacing, top: 1, left: this.myAvoid.left, right: this.myAvoid.right } : { top: standardSpacing, bottom: 1, left: this.myAvoid.left, right: this.myAvoid.right })
            .width('100%');
          }
          .alignRules(!titleBarPositionBottom()
            ? {
              top: { anchor: '__container__', align: VerticalAlign.Top },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            }
            : {
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
          .translate({ y: !titleBarPositionBottom() ? this.topAvoidHeight : -this.bottomAvoidHeight }) // Bottom avoid.
          .constraintSize({ maxHeight: this.maxHeightTitleBar() })
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring);
        }

        // Gigantic window title
        if (showGiganticWindowTitle(this.myUi)) {
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
        if (this.myUi.addressBarFocused) {
          this.getUIContext().getFocusController().clearFocus();
          animateToImmediately(defaultAnimation(), () => {
            this.myUi.addressBarFocused = false;
          });
        }
      }
    });
  }

  /**
   * Get the bottom avoid height for title bar.
   * @returns The bottom avoid height.
   */
  // @Computed
  get bottomAvoidHeight() {
    const h = this.myApp.freeWindow ? standardSpacing : this.myAvoid.bottom; // No bottom avoid for free windows.
    return (titleBarPositionBottom() || useEffects() ? h : 0);
  }

  /**
   * Get the top avoid height for title bar.
   * @returns The top avoid height.
   */
  // @Computed
  get topAvoidHeight() {
    return this.myApp.freeWindow ? defaultDecorHeight : this.myAvoid.top;
  }

  /**
   * Get the maximum height of the Title Bar (Entire).
   * @returns The maximum height of the Title Bar (Entire).
   */
  maxHeightTitleBar() {
    const avoids = this.bottomAvoidHeight + this.topAvoidHeight;
    const effectsCorrection = useEffects() ? standardSpacing : 0;
    return this.myLayout.height - avoids - standardSpacing + effectsCorrection;
  }

  // Actions

  actionsOnAppear() {
    this.myMisc.launchEndTime = Date.now();
    meow(`---`, 'Index][launch', meowLevel.INFO);
    meow(`Successfully launched the app. (${Date.now() - this.myMisc.launchStartTime} ms)`, 'Index][launch', meowLevel.INFO);
    meow(`Window ID: ${this.myUi.windowId}`, 'Index][launch', meowLevel.INFO);
    meow(`Window Alias: ${this.myUi.windowAlias}`, 'Index][launch', meowLevel.INFO);
    meow(`---`, 'Index][launch', meowLevel.INFO);
    setTimeout(() => {
      this.render = true;
    }, 1);
  }

  // Values

  @Computed
  get mainFrameSpace(): Margin {
    // Vertical
    const slimCompensation = this.myLayout.wideMode ? 0 : MeowTitleBarHeight + standardSpacing; // For double layer title bar on phones / slim windows.
    const tabsHorizontalCompensation = this.myUi.showTabs && !isTabsStyleVertical(this.myLayout) ? defaultHorizontalTabsHeight : 0;

    let top: number;
    let bottom: number;
    if (titleBarPositionBottom()) {
      // Bottom
      const freeWindowCompensation = (this.myApp.freeWindow ? standardSpacing : 0);
      top = this.myAvoid.top;
      bottom = this.myAvoid.bottom + freeWindowCompensation + (MeowTitleBarHeight + standardSpacing) + slimCompensation + tabsHorizontalCompensation + 1; // + 1 is for the 1vp border of the main frame when effects are on.
    } else {
      // Top
      top = this.myAvoid.top + (MeowTitleBarHeight + standardSpacing) + slimCompensation + tabsHorizontalCompensation + 1; // Same.
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
