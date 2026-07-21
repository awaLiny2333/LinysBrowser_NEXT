import { standardSpacing } from '../../../components/constants';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';
import { BookmarksDevCard } from './parts/bookmarks/Card';
import { CatsTypicalFrameworkDevCard } from './parts/framework/Card';
import { HistoryDevCard } from './parts/history/Card';
import { ResourcesDevCard } from './parts/resources/Card';
import { SettingsDevCard } from './parts/settings/Card';

@ComponentV2
struct CatsDevCards {
  @Param @Require myUi: meowUiHost;

  build() {
    Scroll() {
      Column({ space: 5 }) {
        SettingsDevCard();
        CatsTypicalFrameworkDevCard({ myUi: this.myUi });
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
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: 'CatsDev', myUi: this.myUi }) {
      CatsDevCards({ myUi: this.myUi });
    };
  }
}

export { WoofCatsDevDialog };
