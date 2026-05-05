import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { meowMisc } from '../../../../../catstypicalframework/hosts/meowMisc';
import { meowFlexOptions } from '../../../../../components/settings';
import { hintGC } from '../../../../../catstypicalframework/utils/performance';
import { meowAvoid } from '../../../../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../../../../catstypicalframework/hosts/meowLayout';
import { meowAppStatuses } from '../../../../../hosts/system/windows/classes/meowAppStatuses';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * CatsTypicalFramework stuffs.
 */
@ComponentV2
struct CatsTypicalFrameworkDevCard {
  // catsTypicalFramework
  @Param @Require myLayout: meowLayout;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myMisc: meowMisc;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;

  build() {
    UniContentCard({ title: 'CatsTypicalFramework' }) {
      Flex(meowFlexOptions) {
        Button('Toggle Free')
          .onClick(() => {
            this.myApp.freeWindow = !this.myApp.freeWindow;
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
        Text(`[Free Window Mode] ${this.myApp.freeWindow ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Wide / Tablet Mode] ${this.myLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
        Text(`[Avoids]  ↑${this.myAvoid.top}  ↓${this.myAvoid.bottom}  ←${this.myAvoid.left}  →${this.myAvoid.right}`);
      };
    };
  }
}

export { CatsTypicalFrameworkDevCard };
