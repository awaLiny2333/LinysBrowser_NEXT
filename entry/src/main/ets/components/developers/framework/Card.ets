import { meowAvoid, meowFreeWindowModeStatus, meowLayoutModeStatus } from '../../../catstypicalframework/utils/ui';
import { UniContentCard } from '../common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowMisc } from '../../../catstypicalframework/hosts/meowMisc';
import { meowFlexOptions } from '../../common/constants';
import { hintGC } from '../../../catstypicalframework/utils/performance';

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
      Flex(meowFlexOptions) {
        Button('Toggle Free')
          .onClick(() => {
            this.myMeowFreeWindowModeStatus.on = !this.myMeowFreeWindowModeStatus.on;
          });

        Button('Toggle Wide')
          .onClick(() => {
            this.myMeowLayout.wideMode = !this.myMeowLayout.wideMode;
          });

        Button('Hint GC')
          .onClick(() => {
            hintGC();
          });
      };

      Flex(meowFlexOptions) {
        Text(`[launchTimeUsage] ${this.myMeowMisc.launchEndTime - this.myMeowMisc.launchStartTime} ms`);
        Text(`[Free Window Mode] ${this.myMeowFreeWindowModeStatus.on ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Wide / Tablet Mode] ${this.myMeowLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Avoids]  ↑${this.myMeowAvoid.top}  ↓${this.myMeowAvoid.bottom}  ←${this.myMeowAvoid.left}  →${this.myMeowAvoid.right}`);
      };
    };
  }
}

export { CatsTypicalFrameworkDevCard };
