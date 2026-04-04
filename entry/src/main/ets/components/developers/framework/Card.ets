import { meowAvoid, meowFreeWindowModeStatus, meowLayoutModeStatus } from '../../../catstypicalframework/utils/ui';
import { UniContentCard } from '../common/UniContentCard';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { meowMisc } from '../../../catstypicalframework/hosts/meowMisc';

/**
 * CatsTypicalFramework stuffs.
 */
@ComponentV2
struct CatsTypicalFrameworkDevCard {
  // catsTypicalFramework
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect<meowLayoutModeStatus>(meowLayoutModeStatus)!;
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local myMeowMisc: meowMisc = AppStorageV2.connect<meowMisc>(meowMisc)!;

  build() {
    UniContentCard({ title: 'CatsTypicalFramework' }) {
      Text(`[launchTimeUsage] ${this.myMeowMisc.launchEndTime - this.myMeowMisc.launchStartTime} ms`);
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        Button('Toggle Free')
          .onClick(() => {
            this.myMeowFreeWindowModeStatus.on = !this.myMeowFreeWindowModeStatus.on;
          })
          .margin({ bottom: 5 });

        Button('Toggle Wide')
          .onClick(() => {
            this.myMeowLayout.wideMode = !this.myMeowLayout.wideMode;
          })
          .margin({ bottom: 5 });
      };

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(5), cross: LengthMetrics.vp(8) } }) {
        Text(`[Free Window Mode] ${this.myMeowFreeWindowModeStatus.on ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Wide / Tablet Mode] ${this.myMeowLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Avoids]  ↑${this.myMeowAvoid.top}  ↓${this.myMeowAvoid.bottom}  ←${this.myMeowAvoid.left}  →${this.myMeowAvoid.right}`);
      };
    };
  }
}

export { CatsTypicalFrameworkDevCard };
