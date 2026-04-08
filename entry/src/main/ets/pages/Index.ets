import { AppStorageV2 } from '@kit.ArkUI';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import { defaultDecorHeight, defaultInnerRadius, meowAvoid, meowFreeWindowModeStatus, meowLayoutModeStatus } from '../catstypicalframework/utils/ui';
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, titleBarPositionBottom, useEffects } from '../components/common/constants';
import { heightMeowTitleBar, MeowTitleBar } from '../components/parts/MeowTitleBar';
import { MeowButtonRow } from '../components/parts/MeowButtonRow';
import { MeowTitleTop } from '../components/parts/MeowTitleTop';
import { meowResources } from '../hosts/resources/classes/meowResources';
import { meowManagedSettings } from '../hosts/settings/classes/meowManagedSettings';
import { meowUiStatuses } from '../hosts/ui/meowUiStatuses';

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
        // Main
        // This is ugly.
        Column() {
          Column() {
            Image(this.myMeowResources.backgroundImage)
              .opacity(useEffects() ? 0.5 : 1)
              .animation(defaultAnimation());
          }
          .border(useEffects() ? { radius: defaultInnerRadius, width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
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
          }
          .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
          .backgroundColor(getColor(meowThemeColorType.SECONDARY))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .translate({ y: -(titleBarPositionBottom() || useEffects() ? this.myMeowAvoid.bottom : 0) }) // Bottom avoid.
          .padding(titleBarPositionBottom() ? { top: standardSpacing } : 0)
          .width('100%');
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
        this.myMeowLayout.wideMode = this.myMeowLayout.width > 900;
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
    if (titleBarPositionBottom()) {
      top = defaultDecorHeight;
      bottom = heightMeowTitleBar + 2 * standardSpacing;
    } else {
      top = defaultDecorHeight + heightMeowTitleBar + standardSpacing;
      bottom = useEffects() ? standardSpacing : 0;
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