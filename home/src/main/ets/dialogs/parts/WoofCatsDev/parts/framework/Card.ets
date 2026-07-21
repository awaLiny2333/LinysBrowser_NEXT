import { hintGC } from '../../../../../catstypicalframework/utils/performance';
import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { meowFlexOptions } from '../../../../../components/constants';
import { meowAppHost } from '../../../../../hosts/system/windows/classes/meowAppHost';
import { meowUiHost } from '../../../../../hosts/system/windows/classes/meowUiHost';
import { getCreateMyApp } from '../../../../../hosts/system/windows/scripts/helpers';

/**
 * CatsTypicalFramework stuffs.
 */
@ComponentV2
struct CatsTypicalFrameworkDevCard {
  @Param @Require myUi: meowUiHost;
  @Local myApp: meowAppHost = getCreateMyApp();

  build() {
    UniContentCard({ title: 'CatsTypicalFramework' }) {
      Flex(meowFlexOptions) {
        Button('Toggle Free')
          .onClick(() => {
            this.myApp.freeWindow = !this.myApp.freeWindow;
          });

        Button('Toggle Wide')
          .onClick(() => {
            this.myUi.myLayout.wideMode = !this.myUi.myLayout.wideMode;
          });

        Button('Hint GC')
          .onClick(() => {
            hintGC();
          });
      };

      Flex(meowFlexOptions) {
        Text(`[launchTimeUsage] ${this.myUi.myMisc.launchEndTime - this.myUi.myMisc.launchStartTime} ms`);
        Text(`[Free Window Mode] ${this.myApp.freeWindow ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Wide / Tablet Mode] ${this.myUi.myLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Avoids]  ↑${this.myUi.myAvoid.top}  ↓${this.myUi.myAvoid.bottom}  ←${this.myUi.myAvoid.left}  →${this.myUi.myAvoid.right}`);
      };
    };
  }
}

export { CatsTypicalFrameworkDevCard };
