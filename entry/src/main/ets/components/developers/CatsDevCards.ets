import { CatsTypicalFrameworkDevCard } from './framework/Card';
import { SettingsDevCard } from './settings/Card';
import { HistoryDevCard } from './history/Card';
import { meowResources } from '../../hosts/resources/classes/meowResources';
import { AppStorageV2 } from '@kit.ArkUI';
import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { ResourcesDevCard } from './resources/Card';
import { BookmarksDevCard } from './bookmarks/Card';

@ComponentV2
struct CatsDevCards {
  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;

  build() {
    Stack() {
      Image(this.myMeowResources.backgroundImage)
        .opacity(0.5);

      Scroll() {
        Column({ space: 5 }) {
          CatsTypicalFrameworkDevCard();
          BookmarksDevCard();
          ResourcesDevCard();
          SettingsDevCard();
          HistoryDevCard();
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%');
      }
      .padding(5)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    }
    .border({ radius: defaultRoundedRadius + 4, width: 1, color: $r('sys.color.icon_fourth') })
    .clip(true);
  }
}

export { CatsDevCards };
