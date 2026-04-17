import { AppStorageV2 } from '@kit.ArkUI';
import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { meowDialogManager } from '../../hosts/env/classes/meowDialogManager';
import { meowResources } from '../../hosts/env/classes/meowResources';
import { standardSpacing } from '../../components/settings';
import { WoofUniFrame } from '../WoofUniFrame';
import { BookmarksDevCard } from './parts/bookmarks/Card';
import { CatsTypicalFrameworkDevCard } from './parts/framework/Card';
import { HistoryDevCard } from './parts/history/Card';
import { ResourcesDevCard } from './parts/resources/Card';
import { SettingsDevCard } from './parts/settings/Card';

@ComponentV2
struct CatsDevCards {
  @Local myResources: meowResources = AppStorageV2.connect(meowResources)!;
  @Param @Require myLayout: meowLayout;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myMisc: meowMisc;

  build() {
    Scroll() {
      Column({ space: 5 }) {
        SettingsDevCard();
        CatsTypicalFrameworkDevCard({
          myLayout: this.myLayout,
          myAvoid: this.myAvoid,
          myMisc: this.myMisc
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
struct WoofCatsDevDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myAvoid: meowAvoid;
  @Require myMisc: meowMisc;

  build() {
    WoofUniFrame({ controller: this.controller, title: 'CatsDev', myLayout: this.myLayout, myDialog: this.myDialog }) {
      CatsDevCards({
        myLayout: this.myLayout,
        myAvoid: this.myAvoid,
        myMisc: this.myMisc
      });
    };
  }
}

export { WoofCatsDevDialog };
