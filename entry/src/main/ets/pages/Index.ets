import { AppStorageV2 } from '@kit.ArkUI';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import { defaultDecorHeight, defaultInnerRadius } from '../catstypicalframework/utils/ui';
import { defaultAnimation, getColor, meowThemeColorType, mooTextType, showGiganticWindowTitle, standardSpacing, titleBarPositionBottom, useEffects } from '../components/common/constants';
import lazy { heightMeowTitleBar, MeowTitleBar } from '../components/parts/MeowTitleBar';
import lazy { MeowButtonRow } from '../components/parts/MeowButtonRow';
import lazy { MeowTitleTop } from '../components/parts/MeowTitleTop';
import { meowResources } from '../hosts/env/classes/meowResources';
import { meowManagedSettings } from '../hosts/settings/classes/meowManagedSettings';
import { meowUiStatuses } from '../hosts/env/classes/meowUiStatuses';
import { meowAvoid } from '../catstypicalframework/hosts/meowAvoid';
import { meowFreeWindowModeStatus } from '../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowLayoutModeStatus } from '../catstypicalframework/hosts/meowLayoutModeStatus';
import { MeowSearchBar } from '../components/parts/MeowSearchBar';
import { MeowPlaceForDialogs } from '../components/parts/MeowPlaceForDialogs';
import { MooTextModifier } from '../components/common/MooTextModifier';

@Entry
@ComponentV2
struct Index {
  // catsTypicalFramework
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect<meowLayoutModeStatus>(meowLayoutModeStatus)!;
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local myMeowMisc: meowMisc = AppStorageV2.connect<meowMisc>(meowMisc)!;
  // Hosts
  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Local meowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect<meowManagedSettings>(meowManagedSettings)!; // Should be initialized by flows.
  // Runtime
  context: Context = this.getUIContext().getHostContext()!;
  uiContext: UIContext = this.getUIContext();
  // Render control
  @Local render: boolean = false;

  build() {
    RelativeContainer() {
      if (this.render) {
        // Dialog handler
        MeowPlaceForDialogs();

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

        MeowTitleTop();

        // Top
        if (!titleBarPositionBottom()) {
          Column({ space: standardSpacing }) {
            MeowTitleBar();
            if (!this.myMeowLayout.wideMode) {
              MeowSearchBar();
            }
            MeowButtonRow();
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
            MeowButtonRow();
            MeowTitleBar();
            if (!this.myMeowLayout.wideMode) {
              MeowSearchBar();
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
        if (showGiganticWindowTitle()) {
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
        this.myMeowLayout.wideMode = this.myMeowLayout.width > 700;
      }
      if (o.height != n.height) {
        this.myMeowLayout.height = n.height as number;
      }
    });
  }

  // Actions

  actionsOnAppear() {
    this.myMeowMisc.launchEndTime = Date.now();
    meow(`---`, 'Index][launch', meowLevel.INFO);
    meow(`Successfully launched the app. (${Date.now() - this.myMeowMisc.launchStartTime} ms)`, 'Index][launch', meowLevel.INFO);
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