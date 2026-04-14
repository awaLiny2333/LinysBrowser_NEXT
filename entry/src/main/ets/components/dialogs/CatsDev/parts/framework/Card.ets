import { UniContentCard } from '../../../../common/UniContentCard';
import { meowMisc } from '../../../../../catstypicalframework/hosts/meowMisc';
import { meowFlexOptions } from '../../../../settings';
import { hintGC } from '../../../../../catstypicalframework/utils/performance';
import { meowAvoid } from '../../../../../catstypicalframework/hosts/meowAvoid';
import { meowFreeWindowModeStatus } from '../../../../../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowLayoutModeStatus } from '../../../../../catstypicalframework/hosts/meowLayoutModeStatus';

/**
 * CatsTypicalFramework stuffs.
 */
@ComponentV2
struct CatsTypicalFrameworkDevCard {
  // catsTypicalFramework
  @Param @Require myMeowLayout: meowLayoutModeStatus;
  @Param @Require myMeowFreeWindowModeStatus: meowFreeWindowModeStatus;
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowMisc: meowMisc;

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
