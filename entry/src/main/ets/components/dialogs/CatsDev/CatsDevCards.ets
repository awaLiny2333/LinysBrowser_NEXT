import { AppStorageV2 } from '@kit.ArkUI';
import { meowFreeWindowModeStatus } from '../../../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowAvoid } from '../../../catstypicalframework/hosts/meowAvoid';
import { meowLayoutModeStatus } from '../../../catstypicalframework/hosts/meowLayoutModeStatus';
import { meowMisc } from '../../../catstypicalframework/hosts/meowMisc';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { meowResources } from '../../../hosts/env/classes/meowResources';
import { standardSpacing } from '../../settings';
import { WoofUniFrame } from '../common/WoofUniFrame';
import { BookmarksDevCard } from './parts/bookmarks/Card';
import { CatsTypicalFrameworkDevCard } from './parts/framework/Card';
import { HistoryDevCard } from './parts/history/Card';
import { ResourcesDevCard } from './parts/resources/Card';
import { SettingsDevCard } from './parts/settings/Card';

@ComponentV2
struct CatsDevCards {
  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Param @Require myMeowLayout: meowLayoutModeStatus;
  @Param @Require myMeowFreeWindowModeStatus: meowFreeWindowModeStatus;
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowMisc: meowMisc;

  build() {
    Scroll() {
      Column({ space: 5 }) {
        SettingsDevCard();
        CatsTypicalFrameworkDevCard({
          myMeowLayout: this.myMeowLayout,
          myMeowFreeWindowModeStatus: this.myMeowFreeWindowModeStatus,
          myMeowAvoid: this.myMeowAvoid,
          myMeowMisc: this.myMeowMisc
        });
        BookmarksDevCard();
        ResourcesDevCard();
        HistoryDevCard();
      }
      .padding(standardSpacing)
      .alignItems(HorizontalAlign.Start)
      .width('100%');
    }
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring);
  }
}

@CustomDialog
struct CatsDevDialog {
  controller: CustomDialogController;
  @Require myMeowDialogManager: meowDialogManager;
  @Require myMeowLayoutModeStatus: meowLayoutModeStatus;
  @Require myMeowFreeWindowModeStatus: meowFreeWindowModeStatus;
  @Require myMeowAvoid: meowAvoid;
  @Require myMeowMisc: meowMisc;

  build() {
    WoofUniFrame({ controller: this.controller, title: 'CatsDev', myMeowLayoutModeStatus: this.myMeowLayoutModeStatus, myMeowDialogManager: this.myMeowDialogManager }) {
      CatsDevCards({
        myMeowLayout: this.myMeowLayoutModeStatus,
        myMeowFreeWindowModeStatus: this.myMeowFreeWindowModeStatus,
        myMeowAvoid: this.myMeowAvoid,
        myMeowMisc: this.myMeowMisc
      });
    };
  }
}

export { CatsDevDialog };
