import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import lazy { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import lazy { defaultInnerRadius, defaultWindowTopDecorHeight, shortModeThreshold, updateNavigationIndicator, wideModeThreshold } from '../catstypicalframework/utils/ui';
import lazy { MooTextModifier } from '../components/common/MooTextModifier';
import lazy { defaultSidebarShrunkWidth, defaultSidebarWidth, defaultTabsVerticalShrunkWidth, defaultTabsVerticalWidth, meowThemeColorType, mooTextType, standardComponentHeight, standardSpacing } from '../components/constants';
import lazy { MeowAddressBar } from '../components/parts/Homepage/MeowAddressBar';
import lazy { MeowDestination } from '../components/parts/Homepage/MeowDestination';
import lazy { MeowResMonitor } from '../components/parts/Homepage/MeowResMonitor';
import lazy { MeowShortcutsPanel } from '../components/parts/Homepage/MeowShortcuts';
import lazy { MeowSuggestions } from '../components/parts/Homepage/MeowSuggestions';
import lazy { MeowTitleBar, MeowTitleBarHeight } from '../components/parts/Homepage/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/Homepage/MeowTitleTop';
import lazy { MeowWindowInfoBar } from '../components/parts/Homepage/MeowWindowInfoBar';
import lazy { MeowButtonsSlot } from '../components/parts/MeowButtons/MeowButtonsSlot';
import lazy { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import lazy { MeowPlaceForKeyShortcuts } from '../components/parts/MeowPlaceForKeyShortcuts';
import lazy { MeowSidebar } from '../components/parts/Sidebar/MeowSidebar';
import lazy { MeowTabsHorizontal } from '../components/parts/Tabs/Horizontal';
import lazy { MeowTabsVertical } from '../components/parts/Tabs/Vertical';
import lazy { defaultAnimation, getColor, isPreferRightHand, isTabsStyleVertical, meowButtonsMore, showBottomAvoid, showGiganticWindowTitle, showResourceMonitor, sideAreaShrinkAuto, sideAreaShrinkExpandNoPush, sidebarShouldBeOnTheRight, titleBarPositionBottom, useEffects } from '../components/settings';
import { meowDialogManager } from '../hosts/system/dialogs/classes/meowDialogManager';
import { getMyResource } from '../hosts/system/storage/scripts/helpers';
import { meowAppHost } from '../hosts/system/windows/classes/meowAppHost';
import { meowUiFullscreenStatus, meowUiGoBackSource, meowUiHost } from '../hosts/system/windows/classes/meowUiHost';
import { getMyApp } from '../hosts/system/windows/scripts/helpers';
import { meowAppMessageType } from '../hosts/system/windows/scripts/messaging';
import { getLastWindowId } from '../hosts/system/windows/scripts/multiwindows';
import { meowKeyboardMan } from '../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { unifiedDataChannel } from '@kit.ArkData';
import { getMyBoard } from '../hosts/app/scratchingboard/scripts/helpers';
import { meowTabsBunch } from '../hosts/app/tabs/classes/meowTabsBunch';

@Entry
@ComponentV2
struct Index {
  @Local myWindowId: string = getLastWindowId(); // To know who I am!
  // Hosts (public)
  @Local myApp: meowAppHost = getMyApp();
  @Local myKey: meowKeyboardMan = AppStorageV2.connect(meowKeyboardMan)!;
  // Hosts (private)
  @Local myUi: meowUiHost = AppStorageV2.connect(meowUiHost, `meowUiHost_${this.myWindowId}`)!;
  @Local myDialog: meowDialogManager = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myWindowId}`)!;
  // catsTypicalFramework (private)
  @Local myLayout: meowLayout = AppStorageV2.connect(meowLayout, `meowLayout_${this.myWindowId}`)!;
  @Local myAvoid: meowAvoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${this.myWindowId}`)!;
  @Local myMisc: meowMisc = AppStorageV2.connect(meowMisc, `meowMisc_${this.myWindowId}`)!;
  @Local myTabs: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myWindowId}`)!;
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
        MeowPlaceForKeyShortcuts(this.myDialog, this.myUi, this.myKey, this.getUIContext());

        // This is ugly.
        // Main frame
        Stack({ alignContent: sidebarShouldBeOnTheRight() ? Alignment.End : Alignment.Start }) {
          // Web frame
          Stack() {
            // Backdrop
            if (getMyResource().backgroundImage) {
              Image(getMyResource().backgroundImage)
                .opacity(useEffects() ? 0.5 : 1)
                .grayscale(useEffects() ? 1 : 0)
                .animation(defaultAnimation());
            }
            // Shortcuts
            MeowShortcutsPanel({ myLayout: this.myLayout, myDialog: this.myDialog });

            if (this.myTabs.currentNode && this.myTabs.currentTab?.url) {
              NodeContainer(this.myTabs.currentNode);
            }
          }
          .margin(this.mainFrameSpace)
          .border(useEffects() && this.isNotAnySortOfFullscreen ? { radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') } : { width: 0, radius: 0 })
          .clip(true);

          // Sidebars
          Row({ space: standardSpacing }) {
            if (this.myUi.showingVerticalTab) {
              MeowTabsVertical({ myUi: this.myUi, myLayout: this.myLayout, myTabs: this.myTabs });
            }
            if (this.myUi.showSidebar) {
              MeowSidebar({
                myLayout: this.myLayout, myUi: this.myUi,
                onItemDragStart: () => {
                  this.onDragFromSideArea();
                },
                onDropSidebar: () => {
                  this.onDropSideArea();
                },
                onDragEnterSidebar: () => {
                  // meow(`Drag entered Sidebar!`, 'Index', meowLevel.WARN);
                  this.onDragEnterSideArea();
                },
                onDragLeaveSidebar: () => {
                  // meow(`Drag left Sidebar!`, 'Index', meowLevel.WARN);
                  this.onDragLeaveSideArea();
                }
              });
            }
          }
          .direction(sidebarShouldBeOnTheRight() ? Direction.Ltr : Direction.Rtl)
          .justifyContent(FlexAlign.Center)
          // NOTE: We add the padding and then translate this a unit of standardSpacing to catch the hover action in order to expand the vertical tabs.
          .padding(this.sideAreaPadding)
          .translate(useEffects() && this.isNotAnySortOfFullscreen ? (sidebarShouldBeOnTheRight() ? { x: standardSpacing } : { x: -standardSpacing }) : undefined)
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
              if (sideAreaShrinkAuto() && sideAreaShrinkExpandNoPush()) {
                // Auto shrink, and we don't want to push the web contents away everytime the mouse travels across the tabs bar.
                if (this.myUi.showingVerticalTab && !this.myUi.sideAreaShrunkSummarized) {
                  newW -= (defaultTabsVerticalWidth - defaultTabsVerticalShrunkWidth);
                }
                if (this.myUi.showSidebar && !this.myUi.sideAreaShrunkSummarized) {
                  newW -= (defaultSidebarWidth - defaultSidebarShrunkWidth);
                }
              }
              animateToImmediately(defaultAnimation(), () => {
                this.myUi.sideAreaWidth = Math.ceil(Math.max(0, newW));
              });
              // meow(`New sideAreaWidth: ${this.myUi.sideAreaWidth}!`, 'Index', meowLevel.INFO);
            }
          })
          .onHover((isHover) => {
            if (!(sideAreaShrinkAuto())) {
              return;
            }
            // Auto shrink
            if (isHover) {
              animateToImmediately(defaultAnimation(), () => {
                this.myUi.sideAreaShrunkExpect = false;
              });
            } else {
              setTimeout(() => {
                animateToImmediately(defaultAnimation(), () => {
                  this.myUi.sideAreaShrunkExpect = true;
                });
              }, 10);
            }
          })
          .onDrop((e) => {
            this.onDropSideArea();
            this.dropToScratchingBoard(e);
          })
          .onDragEnter(() => {
            // meow(`Drag entered Side area!`, 'Index', meowLevel.WARN);
            this.onDragEnterSideArea();
          })
          .onDragLeave(() => {
            // meow(`Drag left Side area!`, 'Index', meowLevel.WARN);
            this.onDragLeaveSideArea();
          });
        }
        .padding(this.isNotAnySortOfFullscreen ? this.outerFrameSpace : 0);

        if (this.isNotAnySortOfFullscreen) {
          // Top bar
          MeowTitleTop(this.myLayout, this.myUi, this.myApp, this.myMisc, this.myTabs, this.getUIContext());

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
              MeowTitleBar(this.myUi, this.myLayout, this.myDialog);

              // Address
              if (!this.myLayout.wideMode) {
                if (this.myUi.dropHover) {
                  Text($r('app.string.ScratchingBoard_drop')).attributeModifier(new MooTextModifier()).width('100%').textAlign(TextAlign.Center);
                } else {
                  MeowAddressBar({
                    myUi: this.myUi,
                    myLayout: this.myLayout,
                    myDialog: this.myDialog,
                  });
                }
              }

              if (this.myUi.addressBarFocused && !titleBarPositionBottom()) {
                MeowDestination(this.myUi, this.getUIContext());
                MeowSuggestions({ myUi: this.myUi, myLayout: this.myLayout });
              }

              // More
              if (this.myUi.showMore) {
                // Meow buttons
                if (meowButtonsMore().length > 0) {
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
                if (showResourceMonitor()) {
                  MeowResMonitor();
                }
              }
            }
            .opacity(this.myUi.dropHover ? 0.5 : 1)
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
    .onDragEnter(() => {
      this.onDragEnterAnyArea();
    })
    .onDragLeave(() => {
      this.onDragLeaveAnyArea();
    })
    .onDrop((e) => {
      this.onDropAnyArea();
      this.dropToScratchingBoard(e);
    })
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
    }, 10);
  }

  // Drag drop side area

  /**
   * Something is dragged away from the side area.
   * We set the drag block.
   */
  onDragFromSideArea() {
    this.myUi.sideAreaShrinkBlock_drag = true;
  }

  /**
   * Something is dragged into the side area.
   * Set the drag block.
   */
  onDragEnterSideArea() {
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.sideAreaShrinkBlock_drag = true;
    });
    this.onDragEnterAnyArea();
  }

  /**
   * Something is dragged out of the side area.
   * Release the drag block.
   */
  onDragLeaveSideArea() {
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.sideAreaShrinkBlock_drag = false;
    });
    this.onDragLeaveAnyArea();
  }

  /**
   * Something is dropped to the side area.
   * We switch the status back to a true expectation and release the drag block.
   */
  onDropSideArea() {
    this.onDropAnyArea();
    this.myUi.sideAreaShrunkExpect = false;
    setTimeout(() => {
      this.myUi.sideAreaShrinkBlock_drag = false;
    }, 10);
  }

  // Drag drop ANY area

  onDragEnterAnyArea() {
    clearTimeout(this.myUi.dropHoverFlipTimeoutId);
    this.myUi.dropHoverFlipTimeoutId = setTimeout(() => {
      animateToImmediately(defaultAnimation(), () => {
        this.myUi.dropHover = true;
      });
    }, 10);
  }

  onDragLeaveAnyArea() {
    clearTimeout(this.myUi.dropHoverFlipTimeoutId);
    this.myUi.dropHoverFlipTimeoutId = setTimeout(() => {
      animateToImmediately(defaultAnimation(), () => {
        this.myUi.dropHover = false;
      });
    }, 10);
  }

  onDropAnyArea() {
    clearTimeout(this.myUi.dropHoverFlipTimeoutId);
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.dropHover = false;
    });
  }

  // Scratching board

  /**
   * Something is dropped to the scratching board.
   * @param e The event to be processed.
   */
  dropToScratchingBoard(e: DragEvent) {
    console.log(' ');
    meow(`Into Scratching Board! 快到碗裡來！`, 'Index][SideArea][onDrop', meowLevel.WARN);
    let records: unifiedDataChannel.UnifiedRecord[] = [];
    try {
      records = e.getData().getRecords();
      meow(`Received ${records.length} records from drag event.`, 'Index][dropToScratchingBoard');
    } catch (e) {
      meow(`Failed to get records from drag event: ${e}`, 'Index][dropToScratchingBoard', meowLevel.ERROR);
    }

    const myBoard = getMyBoard();
    // Process them!
    animateToImmediately(defaultAnimation(), () => {
      myBoard.addEntries(records, `${this.getUIContext().getHostContext()!.tempDir}/scratching-board`);
    });
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
   * Whether the app is not in any sort of fullscreen.
   */
  get isNotAnySortOfFullscreen() {
    return this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE;
  }

  /**
   * Whether to show horizontal tabs.
   */
  get showingHorizontalTab() {
    return this.myUi.showTabs && !isTabsStyleVertical(this.myLayout);
  }

  /**
   * The padding for the side area.
   */
  get sideAreaPadding(): Padding | number {
    if (!(this.myUi.showingVerticalTab || this.myUi.showSidebar)) {
      return 0;
    }
    if (useEffects() && this.isNotAnySortOfFullscreen) {
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
      bottom = (showBottomAvoid() ? this.myAvoid.bottom : 0) + (useEffects() ? standardSpacing : 0);
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
   * The side area and stuffs are between them.
   */
  get mainFrameSpace(): Margin {
    // side bar compensation
    const sidebarOnR = sidebarShouldBeOnTheRight();
    const baseSideAreaWidth = this.myUi.sideAreaWidth; // The base width of side area in an ideal way.
    const borderShift = useEffects() ? 1 : 0;
    const sideAreaShift = this.myLayout.wideMode ? baseSideAreaWidth + borderShift : 0;
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
    switch (msg.type) {
      case meowAppMessageType.SETTINGS_NAV_INDICATOR_UPDATE:
        updateNavigationIndicator(this.myUi.windowObj!);
        break;
      case meowAppMessageType.BOOKMARKS_DRAGGED:
        // Find the folder dragged...
        const index = this.myUi.openedStack.findIndex(folder => msg.payload === folder);
        if (index !== -1) {
          meow(`Folder #${index} [${msg.payload}] Dragged! Closing folders from it on (inclusive)!`, `Index][${this.myWindowId}`, meowLevel.WARN);
          this.myUi.openedStack = this.myUi.openedStack.slice(0, index);
          this.myUi.openedIndexOfLevels = this.myUi.openedIndexOfLevels.slice(0, index);
          this.myUi.openedIndexOfLevels[index - 1] = undefined; // the folder at index 0 is always the root foldr. We cannot drag the root folder, so this is always safe.
        }
    }
  }
}
