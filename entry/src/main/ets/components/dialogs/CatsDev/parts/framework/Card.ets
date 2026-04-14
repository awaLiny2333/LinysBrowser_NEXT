import { UniContentCard } from '../../../../common/UniContentCard';
import { meowMisc } from '../../../../../catstypicalframework/hosts/meowMisc';
import { meowFlexOptions } from '../../../../settings';
import { hintGC } from '../../../../../catstypicalframework/utils/performance';
import { meowAvoid } from '../../../../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../../../../catstypicalframework/hosts/meowLayout';

/**
 * CatsTypicalFramework stuffs.
 */
@ComponentV2
struct CatsTypicalFrameworkDevCard {
  // catsTypicalFramework
  @Param @Require myLayout: meowLayout;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myMisc: meowMisc;

  build() {
    UniContentCard({ title: 'CatsTypicalFramework' }) {
      Flex(meowFlexOptions) {
        Button('Toggle Free')
          .onClick(() => {
            this.myLayout.freeWindow = !this.myLayout.freeWindow;
          });

        Button('Toggle Wide')
          .onClick(() => {
            this.myLayout.wideMode = !this.myLayout.wideMode;
          });

        Button('Hint GC')
          .onClick(() => {
            hintGC();
          });
      };

      Flex(meowFlexOptions) {
        Text(`[launchTimeUsage] ${this.myMisc.launchEndTime - this.myMisc.launchStartTime} ms`);
        Text(`[Free Window Mode] ${this.myLayout.freeWindow ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Wide / Tablet Mode] ${this.myLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Avoids]  ↑${this.myAvoid.top}  ↓${this.myAvoid.bottom}  ←${this.myAvoid.left}  →${this.myAvoid.right}`);
      };
    };
  }
}

export { CatsTypicalFrameworkDevCard };
