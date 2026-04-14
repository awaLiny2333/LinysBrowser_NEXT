import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowFreeWindowModeStatus } from '../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowLayoutModeStatus } from '../catstypicalframework/hosts/meowLayoutModeStatus';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import { defaultDecorHeight, defaultInnerRadius, shortModeThreshold, wideModeThreshold } from '../catstypicalframework/utils/ui';
import { MooTextModifier } from '../components/common/MooTextModifier';
import lazy { MeowButtonRow } from '../components/parts/MeowButtonRow';
import { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import { MeowSearchBar } from '../components/parts/MeowSearchBar';
import lazy { heightMeowTitleBar, MeowTitleBar } from '../components/parts/MeowTitleBar';
import lazy { MeowTitleTop } from '../components/parts/MeowTitleTop';
import { defaultAnimation, getColor, meowThemeColorType, mooTextType, showGiganticWindowTitle, standardSpacing, titleBarPositionBottom, useEffects } from '../components/settings';
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
  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Local myMeowAppStatuses: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!; // Should be initialized by flows.
  // Hosts (private)
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses, `meowUiStatuses_${this.myWindowId}`)!;
  @Local myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myWindowId}`)!;
  // catsTypicalFramework (private)
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus, `meowLayoutModeStatus_${this.myWindowId}`)!;
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect(meowFreeWindowModeStatus, `meowFreeWindowModeStatus_${this.myWindowId}`)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${this.myWindowId}`)!;
  @Local myMeowMisc: meowMisc = AppStorageV2.connect(meowMisc, `meowMisc_${this.myWindowId}`)!;
  // Runtime
  context: Context = this.getUIContext().getHostContext()!;
  uiContext: UIContext = this.getUIContext();
  // Render control
  @Local render: boolean = false;

  build() {
    RelativeContainer() {
      if (this.render) {
        // Dialog handler
        MeowPlaceForDialogs({
          myMeowDialogManager: this.myMeowDialogManager,
          myMeowUiStatuses: this.myMeowUiStatuses, 
          myMeowLayoutModeStatus: this.myMeowLayout,
          myMeowFreeWindowModeStatus: this.myMeowFreeWindowModeStatus,
          myMeowAvoid: this.myMeowAvoid,
          myMeowMisc: this.myMeowMisc
        });

        // Main
        // This is ugly.
        Column() {
          Stack() {
            Image(this.myMeowResources.backgroundImage)
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
          myMeowFreeWindowModeStatus: this.myMeowFreeWindowModeStatus,
          myMeowAvoid: this.myMeowAvoid,
          myMeowLayout: this.myMeowLayout,
          myMeowDialogManager: this.myMeowDialogManager,
        });

        // Top
        if (!titleBarPositionBottom()) {
          Column({ space: standardSpacing }) {
            MeowTitleBar({
              myMeowUiStatuses: this.myMeowUiStatuses,
              myMeowAvoid: this.myMeowAvoid,
              myMeowLayout: this.myMeowLayout,
              myMeowDialogManager: this.myMeowDialogManager,
            });
            if (!this.myMeowLayout.wideMode) {
              MeowSearchBar({
                myMeowAvoid: this.myMeowAvoid,
              });
            }
            MeowButtonRow({
              myMeowUiStatuses: this.myMeowUiStatuses,
              myMeowAvoid: this.myMeowAvoid,
            });
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
            MeowButtonRow({
              myMeowUiStatuses: this.myMeowUiStatuses,
              myMeowAvoid: this.myMeowAvoid,
            });
            MeowTitleBar({
              myMeowUiStatuses: this.myMeowUiStatuses,
              myMeowAvoid: this.myMeowAvoid,
              myMeowLayout: this.myMeowLayout,
              myMeowDialogManager: this.myMeowDialogManager,
            });
            if (!this.myMeowLayout.wideMode) {
              MeowSearchBar({
                myMeowAvoid: this.myMeowAvoid,
              });
            }
          }
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .backgroundColor(getColor(meowThemeColorType.SECONDARY))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .translate({ y: (titleBarPositionBottom() || useEffects() ? - this.myMeowAvoid.bottom - (this.myMeowFreeWindowModeStatus.on ? standardSpacing : 0) : 0) }) // Bottom avoid.
          .padding(titleBarPositionBottom() ? { top: standardSpacing } : 0)
          .width('100%');
        }

        // Gigantic window title
        if (showGiganticWindowTitle(this.myMeowFreeWindowModeStatus)) {
          Text('Gigantic Window Title')
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
        this.myMeowLayout.width = n.width as number;
        this.myMeowLayout.wideMode = this.myMeowLayout.width > wideModeThreshold;
      }
      if (o.height != n.height) {
        this.myMeowLayout.height = n.height as number;
        this.myMeowLayout.shortMode = this.myMeowLayout.height < shortModeThreshold;
      }
    });
  }

  // Actions

  actionsOnAppear() {
    this.myMeowMisc.launchEndTime = Date.now();
    meow(`---`, 'Index][launch', meowLevel.INFO);
    meow(`Successfully launched the app. (${Date.now() - this.myMeowMisc.launchStartTime} ms)`, 'Index][launch', meowLevel.INFO);
    meow(`Window ID: ${this.myMeowUiStatuses.windowId}`, 'Index][launch', meowLevel.INFO);
    meow(`---`, 'Index][launch', meowLevel.INFO);
    setTimeout(() => {
      this.render = true;
    }, 1);
  }

  // Values

  mainFrameMargin(): Margin {
    // Vertical
    let top: number;
    let bottom: number;
    const slimCompensation = this.myMeowLayout.wideMode ? 0 : heightMeowTitleBar + standardSpacing; // For double layer title bar on phones / slim windows.
    if (titleBarPositionBottom()) {
      // Bottom
      const freeWindowCompensation = (this.myMeowFreeWindowModeStatus.on ? standardSpacing : 0);
      top = this.myMeowAvoid.top;
      bottom = this.myMeowAvoid.bottom + freeWindowCompensation + (heightMeowTitleBar + standardSpacing) + slimCompensation;
    } else {
      // Top
      top = this.myMeowAvoid.top + (heightMeowTitleBar + standardSpacing) + slimCompensation;
      bottom = this.myMeowAvoid.bottom + (useEffects() ? standardSpacing : 0);
    }

    // Horizontal
    let left: number;
    let right: number;
    if (useEffects()) {
      left = this.myMeowAvoid.left;
      right = this.myMeowAvoid.right;
    } else {
      left = 0;
      right = 0;
    }
    return { top, bottom, left, right };
  }
}