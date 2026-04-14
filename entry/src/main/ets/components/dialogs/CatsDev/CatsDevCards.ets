import { AppStorageV2 } from '@kit.ArkUI';
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

  build() {
    Scroll() {
      Column({ space: 5 }) {
        SettingsDevCard();
        CatsTypicalFrameworkDevCard();
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

  build() {
    WoofUniFrame({ controller: this.controller, title: 'CatsDev' }) {
      CatsDevCards();
    };
  }
}

export { CatsDevDialog };
