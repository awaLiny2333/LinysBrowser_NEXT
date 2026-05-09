import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import lazy { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import lazy { defaultWindowTopDecorHeight, defaultInnerRadius, shortModeThreshold, updateNavigationIndicator, wideModeThreshold } from '../catstypicalframework/utils/ui';
import lazy { MooTextModifier } from '../components/common/MooTextModifier';
import { UnifiedButtonsType } from '../components/common/constants';
import { MeowButtonsSlot } from '../components/parts/MeowButtons/MeowButtonsSlot';
import lazy { MeowAddressBar } from '../components/parts/Homepage/MeowAddressBar';
import { MeowDestination } from '../components/parts/Homepage/MeowDestination';
import { MeowResMonitor } from '../components/parts/Homepage/MeowResMonitor';
import lazy { MeowShortcutsPanel } from '../components/parts/Homepage/MeowShortcuts';
import { MeowSidebar } from '../components/parts/Sidebar/MeowSidebar';
import { MeowSuggestions } from '../components/parts/Homepage/MeowSuggestions';
import lazy { MeowTitleBar, MeowTitleBarHeight } from '../components/parts/Homepage/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/Homepage/MeowTitleTop';
import { MeowWindowInfoBar } from '../components/parts/Homepage/MeowWindowInfoBar';
import lazy { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import { MeowPlaceForKeyShortcuts } from '../components/parts/MeowPlaceForKeyShortcuts';
import { MeowTabsHorizontal } from '../components/parts/Tabs/Horizontal';
import { MeowTabsVertical } from '../components/parts/Tabs/Vertical';
import lazy { defaultAnimation, getColor, isPreferRightHand, isTabsStyleVertical, meowThemeColorType, mooTextType, showGiganticWindowTitle, sidebarShouldBeOnTheRight, standardComponentHeight, standardSpacing, titleBarPositionBottom, useEffects } from '../components/settings';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';
import { meowResources } from '../hosts/system/storage/classes/meowResources';
import { meowAppStatuses } from '../hosts/system/windows/classes/meowAppStatuses';
import { meowUiFullscreenStatus, meowUiGoBackSource, meowUiHost } from '../hosts/system/windows/classes/meowUiHost';
import { meowAppMessageType } from '../hosts/system/windows/scripts/messaging';
import { getLastWindowId } from '../hosts/system/windows/scripts/multiwindows';
import { meowKeyboardMan } from '../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { meowManagedSettings } from '../hosts/userdata/settings/classes/meowManagedSettings';

@Entry
@ComponentV2
struct Index {
  @Local myWindowId: string = getLastWindowId(); // To know who I am!
  // Hosts (public)
  @Local myResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // Should be initialized by flows.
  @Local myKey: meowKeyboardMan = AppStorageV2.connect(meowKeyboardMan)!;
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
        MeowPlaceForKeyShortcuts(this.myDialog, this.myUi, this.myKey, this.mySettings, this.getUIContext());

        // This is ugly.
        // Main frame
        Stack({ alignContent: sidebarShouldBeOnTheRight() ? Alignment.End : Alignment.Start }) {
          // Web frame
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
          .margin(this.mainFrameSpace)
          .border(useEffects() ? { radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') } : { width: 0, radius: 0 })
          .clip(true);

          // Sidebars
          Row({ space: standardSpacing }) {
            if (this.showingVerticalTab) {
              MeowTabsVertical({ myUi: this.myUi, myLayout: this.myLayout });
            }
            if (this.myUi.showSidebar) {
              MeowSidebar({ myLayout: this.myLayout, myUi: this.myUi });
            }
          }
          .direction(sidebarShouldBeOnTheRight() ? Direction.Ltr : Direction.Rtl)
          .justifyContent(FlexAlign.Center)
          // NOTE: We add the padding and then translate this a unit of standardSpacing to catch the hover action in order to expand the vertical tabs.
          .padding(this.sideAreaPadding)
          .translate(useEffects() ? (sidebarShouldBeOnTheRight() ? { x: standardSpacing } : { x: -standardSpacing }) : undefined)
          // END NOTE
          .height('100%')
          .backgroundColor(useEffects() ? getColor(meowThemeColorType.SECONDARY) : getColor(meowThemeColorType.PRIMARY))
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .onAreaChange((o, n) => {
            if (o.width != n.width) {
              let newW = n.width as number;
              if (useEffects()) {
                newW -= standardSpacing;
              }
              animateToImmediately(defaultAnimation(), () => {
                this.myUi.sideAreaWidth = Math.max(0, newW);
              });
            }
          })
          .onHover((isHover) => {
            if (!(this.mySettings.settingsData[14].value as boolean)) {
              return;
            }
            // Auto shrink
            animateToImmediately(defaultAnimation(), () => {
              if (isHover) {
                this.myUi.verticalTabsShrunk = false;
              } else {
                this.myUi.verticalTabsShrunk = true;
              }
            });
          });
        }
        .padding(this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE ? this.outerFrameSpace : 0);

        if (this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE) {
          // Top bar
          MeowTitleTop(this.myLayout, this.myDialog, this.myUi, this.myApp, this.getUIContext());

          // Title bar
          Scroll() {
            Column({ space: standardSpacing }) {
              if (this.myUi.addressBarFocused && titleBarPositionBottom()) {
                MeowSuggestions({ myUi: this.myUi, myLayout: this.myLayout });
                MeowDestination(this.myUi, this.getUIContext());
              }

              // Tabs (Horizontal)
              if (this.showingHorizontalTab) {
                MeowTabsHorizontal();
              }

              // Title bar
              MeowTitleBar(this.myUi, this.myLayout, this.myDialog, this.mySettings);

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
                MeowSuggestions({ myUi: this.myUi, myLayout: this.myLayout });
              }

              // More
              if (this.myUi.showMore) {
                // Meow buttons
                if ((this.mySettings.settingsData[80].value as UnifiedButtonsType[]).length > 0) {
                  Scroll() {
                    MeowButtonsSlot(this.myUi, this.myDialog, 80);
                  }
                  .scrollBar(BarState.Off)
                  .scrollable(ScrollDirection.Horizontal)
                  .edgeEffect(EdgeEffect.Spring);
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
          .scrollBar(BarState.Off)
          .translate({ y: !titleBarPositionBottom() ? this.topAvoidHeight : -this.bottomAvoidHeight }) // Bottom avoid.
          .constraintSize({ maxHeight: this.maxHeightTitleArea })
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
      if (o.width != n.width) {
        this.myLayout.width = n.width as number;
        const newWideMode = this.myLayout.width > wideModeThreshold;
        const wideModeChanged = this.myLayout.wideMode != newWideMode;
        const needRefocus = this.myUi.addressBarFocused && wideModeChanged;
        if (wideModeChanged) {
          animateToImmediately(defaultAnimation(), () => {
            this.myLayout.wideMode = newWideMode;
          });
        }
        if (needRefocus) {
          this.myUi.requestAddressBarFocus(this.getUIContext());
        }
      }
      if (o.height != n.height) {
        this.myLayout.height = n.height as number;
        animateToImmediately(defaultAnimation(), () => {
          this.myLayout.shortMode = this.myLayout.height < shortModeThreshold;
        });
      }
    });
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

  /**
   * Get the bottom avoid height for title bar.
   * @returns The bottom avoid height.
   */
  get bottomAvoidHeight() {
    const h = this.myApp.freeWindow ? standardSpacing : this.myAvoid.bottom; // No bottom avoid for free windows.
    return (titleBarPositionBottom() || useEffects() ? h : 0);
  }

  /**
   * Get the top avoid height for title bar.
   * @returns The top avoid height.
   */
  get topAvoidHeight() {
    return this.myApp.freeWindow ? defaultWindowTopDecorHeight : this.myAvoid.top;
  }

  /**
   * Whether to show horizontal tabs.
   */
  get showingHorizontalTab() {
    return this.myUi.showTabs && !isTabsStyleVertical(this.myLayout);
  }

  /**
   * Whether to show vertical tabs.
   */
  get showingVerticalTab() {
    return this.myUi.showTabs && isTabsStyleVertical(this.myLayout);
  }

  /**
   * If showing any side panels (either sidebar or vertical tab).
   */
  get showingSideArea() {
    return this.showingVerticalTab || this.myUi.showSidebar;
  }

  /**
   * The padding for the side area.
   */
  get sideAreaPadding(): Padding | number {
    if (!this.showingSideArea) {
      return 0;
    }
    if (useEffects()) {
      if (sidebarShouldBeOnTheRight()) {
        return { left: standardSpacing - 1, right: standardSpacing };
      } else {
        return { right: standardSpacing - 1, left: standardSpacing };
      }
    } else {
      return standardSpacing;
    }
  }

  /**
   * Get the maximum height of the Title Bar (Entire).
   * @returns The maximum height of the Title Bar (Entire).
   */
  get maxHeightTitleArea() {
    // Total area
    const avoids = this.bottomAvoidHeight + this.topAvoidHeight;
    const effectsCorrection = useEffects() ? standardSpacing : 0;
    const maxHeightTitleArea = this.myLayout.height - avoids + effectsCorrection;
    this.myLayout.heightTitleArea = maxHeightTitleArea;

    // Title bar
    const tabsComp = this.showingHorizontalTab ? standardComponentHeight + standardSpacing : 0;
    const newTitleHeight = tabsComp + (this.myLayout.wideMode ? MeowTitleBarHeight + standardSpacing : 2 * (MeowTitleBarHeight + standardSpacing));
    if (newTitleHeight != this.myLayout.heightTitleBar) {
      this.myLayout.heightTitleBar = newTitleHeight;
    }

    return maxHeightTitleArea;
  }

  /**
   * The space between the outer window border and the main frame.
   */
  get outerFrameSpace(): Margin {
    // Vertical
    let top: number;
    let bottom: number;
    if (titleBarPositionBottom()) {
      // Bottom
      const freeWindowCompensation = (this.myApp.freeWindow ? standardSpacing : 0);
      top = this.myAvoid.top;
      bottom = this.myAvoid.bottom + freeWindowCompensation + this.myLayout.heightTitleBar + 1; // + 1 is for the 1vp border of the main frame when effects are on.
    } else {
      // Top
      top = this.myAvoid.top + this.myLayout.heightTitleBar + 1; // Same.
      const showBottomAvoid = this.mySettings.settingsData[5].value as boolean; // Allow user to disable bottom avoid.
      bottom = (showBottomAvoid ? this.myAvoid.bottom : 0) + (useEffects() ? standardSpacing : 0);
    }

    // Horizontal
    let left: number;
    let right: number;
    if (useEffects()) {
      left = this.myAvoid.left;
      right = this.myAvoid.right;
    } else {
      left = 0;
      right = 0;
    }
    return { top, bottom, left, right };
  }

  /**
   * The space between the main frame and the available web frame.
   * The sidebar and stuffs are between them.
   */
  get mainFrameSpace(): Margin {
    // side bar compensation
    const sidebarOnR = sidebarShouldBeOnTheRight();
    const borderShift = useEffects() ? 1 : 0;
    const sideAreaShift = this.myLayout.wideMode ? this.myUi.sideAreaWidth + borderShift : 0;
    const left = sidebarOnR ? 0 : sideAreaShift;
    const right = sidebarOnR ? sideAreaShift : 0;

    return {
      top: 0,
      bottom: 0,
      left,
      right,
    };
  }

  // LISTENERS

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
