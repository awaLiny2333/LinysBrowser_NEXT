import { AppStorageV2 } from '@kit.ArkUI';
import { meowResources } from '../../../hosts/env/classes/meowResources';
import { standardSpacing } from '../../common/constants';
import { WoofUniFrame } from '../common/WoofUniFrame';
import { BookmarksDevCard } from './bookmarks/Card';
import { CatsTypicalFrameworkDevCard } from './framework/Card';
import { HistoryDevCard } from './history/Card';
import { ResourcesDevCard } from './resources/Card';
import { SettingsDevCard } from './settings/Card';

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
