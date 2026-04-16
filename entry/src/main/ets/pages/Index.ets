import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import lazy { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import lazy { defaultDecorHeight, defaultInnerRadius, shortModeThreshold, wideModeThreshold } from '../catstypicalframework/utils/ui';
import lazy { MooTextModifier } from '../components/common/MooTextModifier';
import lazy { MeowButtonRow } from '../components/parts/Homepage/MeowButtonRow';
import lazy { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import lazy { MeowSearchBar } from '../components/parts/Homepage/MeowSearchBar';
import lazy { heightMeowTitleBar, MeowTitleBar } from '../components/parts/Homepage/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/Homepage/MeowTitleTop';
import lazy { isTabsStyleVertical, defaultAnimation, defaultHorizontalTabsHeight, defaultSidebarWidth, getColor, meowThemeColorType, mooTextType, showGiganticWindowTitle, sidebarShouldBeOnTheRight, standardSpacing, titleBarPositionBottom, useEffects } from '../components/settings';
import lazy { showingSidebar } from '../components/statuses';
import { meowAppStatuses } from '../hosts/env/classes/meowAppStatuses';
import { meowDialogManager } from '../hosts/env/classes/meowDialogManager';
import { meowResources } from '../hosts/env/classes/meowResources';
import { meowUiStatuses } from '../hosts/env/classes/meowUiStatuses';
import { getLastWindowId } from '../hosts/env/scripts/multiwindows';
import { meowManagedSettings } from '../hosts/settings/classes/meowManagedSettings';

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

  onBackPress(): boolean | void {
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

        // Main
        // This is ugly.
        Column() {
          Stack() {
            Image(this.myResources.backgroundImage)
              .opacity(useEffects() ? 0.5 : 1)
              .grayscale(useEffects() ? 1 : 0)
              .animation(defaultAnimation());

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
                myAvoid: this.myAvoid,
              });
            }
            if (this.myUi.showMore) {
              MeowButtonRow({
                myAvoid: this.myAvoid,
              });
            }
          }
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .backgroundColor(getColor(meowThemeColorType.SECONDARY))
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .translate({ y: defaultDecorHeight })
          .padding(!titleBarPositionBottom() ? { bottom: standardSpacing } : 0)
          .width('100%');
        }

        // Bottom
        if (titleBarPositionBottom()) {
          Column({ space: standardSpacing }) {
            if (this.myUi.showMore) {
              MeowButtonRow({
                myAvoid: this.myAvoid,
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
          .translate({ y: (titleBarPositionBottom() || useEffects() ? - this.myAvoid.bottom - (this.myLayout.freeWindow ? standardSpacing : 0) : 0) }) // Bottom avoid.
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
      if (o.width != n.width) {
        this.myLayout.width = n.width as number;
        this.myLayout.wideMode = this.myLayout.width > wideModeThreshold;
      }
      if (o.height != n.height) {
        this.myLayout.height = n.height as number;
        this.myLayout.shortMode = this.myLayout.height < shortModeThreshold;
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
    const slimCompensation = this.myLayout.wideMode ? 0 : heightMeowTitleBar + standardSpacing; // For double layer title bar on phones / slim windows.
    const tabsHorizontalCompensation = this.myUi.showTabs && !isTabsStyleVertical(this.myLayout) ? defaultHorizontalTabsHeight : 0;

    let top: number;
    let bottom: number;
    if (titleBarPositionBottom()) {
      // Bottom
      const freeWindowCompensation = (this.myLayout.freeWindow ? standardSpacing : 0);
      top = this.myAvoid.top;
      bottom = this.myAvoid.bottom + freeWindowCompensation + (heightMeowTitleBar + standardSpacing) + slimCompensation + tabsHorizontalCompensation;
    } else {
      // Top
      top = this.myAvoid.top + (heightMeowTitleBar + standardSpacing) + slimCompensation + tabsHorizontalCompensation;
      bottom = this.myAvoid.bottom + (useEffects() ? standardSpacing : 0);
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
}